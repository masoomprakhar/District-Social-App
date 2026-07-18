import Foundation

enum AppRoute: Hashable {
    case socialize
    case planDetail(UUID)
    case roomDetail(UUID)
    case myRooms
    case socializeCategory(SocializeCategory)
    case socializeListing(UUID)
    case matchListing(UUID)
    case matchChat(UUID)
    case movieSeats(listingID: UUID, roomID: UUID)
    case groupExperience(UUID)
}
