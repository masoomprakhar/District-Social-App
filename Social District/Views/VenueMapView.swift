import MapKit
import SwiftUI

struct VenueMapView: View {
    @EnvironmentObject private var store: SocializeStore
    var onOpenListing: (UUID) -> Void

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 28.585,
                longitude: 77.185
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.32,
                longitudeDelta: 0.32
            )
        )
    )

    private var venues: [VenuePin] {
        store.listings.enumerated().map { index, listing in
            VenuePin(
                listing: listing,
                coordinate: coordinates[index % coordinates.count]
            )
        }
    }

    private let coordinates = [
        CLLocationCoordinate2D(latitude: 28.4950, longitude: 77.0890),
        CLLocationCoordinate2D(latitude: 28.6004, longitude: 77.2273),
        CLLocationCoordinate2D(latitude: 28.6315, longitude: 77.2167),
        CLLocationCoordinate2D(latitude: 28.5286, longitude: 77.2197),
        CLLocationCoordinate2D(latitude: 28.5494, longitude: 77.2519),
        CLLocationCoordinate2D(latitude: 28.5677, longitude: 77.2433),
        CLLocationCoordinate2D(latitude: 28.6127, longitude: 77.2295),
        CLLocationCoordinate2D(latitude: 28.5245, longitude: 77.1855),
        CLLocationCoordinate2D(latitude: 28.5901, longitude: 77.2095)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                ForEach(venues) { venue in
                    Annotation(
                        venue.listing.title,
                        coordinate: venue.coordinate,
                        anchor: .bottom
                    ) {
                        Button {
                            onOpenListing(venue.listing.id)
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: venue.listing.category.symbolName)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        venue.listing.category.tint,
                                        in: Circle()
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 5, y: 2)

                                if store.socializeModeEnabled {
                                    Text("GROUP")
                                        .font(.system(size: 7, weight: .heavy))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(
                                            DistrictTheme.Palette.accent,
                                            in: Capsule()
                                        )
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic, emphasis: .muted))

            mapLegend
                .padding(.horizontal, 16)
                .padding(.bottom, 90)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle("Plans near you")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var mapLegend: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .foregroundStyle(DistrictTheme.Palette.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(venues.count) plans across Delhi NCR")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(DistrictTheme.Palette.textPrimary)
                Text(
                    store.socializeModeEnabled
                        ? "Group-ready plans are marked on the map"
                        : "Tap a pin to view the plan"
                )
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(DistrictTheme.Palette.textSecondary)
            }

            Spacer()
        }
        .padding(14)
        .glassEffect(
            .regular.tint(Color.black.opacity(0.2)),
            in: RoundedRectangle(cornerRadius: 18)
        )
    }
}

private struct VenuePin: Identifiable {
    var id: UUID { listing.id }
    let listing: SocializeListing
    let coordinate: CLLocationCoordinate2D
}

