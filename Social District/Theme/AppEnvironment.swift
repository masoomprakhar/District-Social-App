import SwiftUI

private struct OpenBookingsActionKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

private struct OpenSocializeActionKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

private struct OpenHomeActionKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    /// Switches to the Bookings tab and clears the current Socialize stack.
    var openBookings: () -> Void {
        get { self[OpenBookingsActionKey.self] }
        set { self[OpenBookingsActionKey.self] = newValue }
    }

    /// Switches to the Socialize tab.
    var openSocialize: () -> Void {
        get { self[OpenSocializeActionKey.self] }
        set { self[OpenSocializeActionKey.self] = newValue }
    }

    /// Switches to the Home tab.
    var openHome: () -> Void {
        get { self[OpenHomeActionKey.self] }
        set { self[OpenHomeActionKey.self] = newValue }
    }
}
