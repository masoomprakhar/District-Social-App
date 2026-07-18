import Foundation
import SwiftUI

struct UserProfile: Identifiable, Hashable {
    let id: UUID
    let name: String
    let handle: String
    let bio: String
    let isVerified: Bool
    let symbolName: String
    let accentColor: Color

    init(
        id: UUID = UUID(),
        name: String,
        handle: String,
        bio: String = "",
        isVerified: Bool = false,
        symbolName: String,
        accentColor: Color
    ) {
        self.id = id
        self.name = name
        self.handle = handle
        self.bio = bio
        self.isVerified = isVerified
        self.symbolName = symbolName
        self.accentColor = accentColor
    }
}
