import Foundation
import FoundationModels

struct IcebreakerSuggestion: Sendable {
    let text: String
    let usedOnDeviceModel: Bool
}

enum AppleIntelligenceMatchService {
    static func icebreaker(
        listing: SocializeListing,
        profile: MatchProfile
    ) async -> IcebreakerSuggestion {
        let fallback = fallbackIcebreaker(listing: listing, profile: profile)
        let model = SystemLanguageModel.default

        guard model.isAvailable else {
            return IcebreakerSuggestion(
                text: fallback,
                usedOnDeviceModel: false
            )
        }

        let session = LanguageModelSession(
            model: model,
            instructions: """
            You write friendly, safe icebreakers for two people meeting at a public venue.
            Return one natural sentence under 18 words. Never mention private data.
            """
        )

        do {
            let response = try await session.respond(
                to: """
                Create an icebreaker for \(profile.name) and the user.
                Plan: \(listing.title) at \(listing.venueName).
                Shared interests: \(profile.interests.joined(separator: ", ")).
                """
            )
            let cleanText = response.content
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard !cleanText.isEmpty else {
                return IcebreakerSuggestion(
                    text: fallback,
                    usedOnDeviceModel: false
                )
            }

            return IcebreakerSuggestion(
                text: cleanText,
                usedOnDeviceModel: true
            )
        } catch {
            return IcebreakerSuggestion(
                text: fallback,
                usedOnDeviceModel: false
            )
        }
    }

    private static func fallbackIcebreaker(
        listing: SocializeListing,
        profile: MatchProfile
    ) -> String {
        let sharedInterest = profile.interests.first ?? listing.category.title
        return "What got you into \(sharedInterest.lowercased()), and what are you most excited about for \(listing.title)?"
    }
}

