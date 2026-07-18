import SwiftUI

/// Large dark search bar used on the home screen.
struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String = "Search for events, movies, restaurants…"

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.districtTextSecondary)

            TextField(
                "",
                text: $text,
                prompt: Text(placeholder).foregroundStyle(Color.districtTextSecondary)
            )
            .font(.system(.callout))
            .foregroundStyle(Color.districtTextPrimary)
            #if os(iOS)
            .textInputAutocapitalization(.never)
            #endif
            .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.districtTextSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: DistrictRadius.searchBar, style: .continuous)
                .fill(Color.districtSurfaceHigh)
        )
    }
}

#Preview {
    SearchBarView(text: .constant(""))
        .padding(DistrictSpacing.pageInset)
        .background(Color.districtBackground)
}
