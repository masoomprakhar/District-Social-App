import ActivityKit
import SwiftUI
import WidgetKit

@main
struct SocialDistrictLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        SocialPlanLiveActivity()
    }
}

struct SocialPlanLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SocialPlanActivityAttributes.self) { context in
            lockScreenView(context)
                .activityBackgroundTint(Color(red: 0.063, green: 0.063, blue: 0.071))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.attributes.symbolName)
                        .font(.title2)
                        .foregroundStyle(.purple)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.groupSize) going")
                        .font(.caption.bold())
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.title)
                        .font(.headline)
                        .lineLimit(1)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Label(
                            context.attributes.venueName,
                            systemImage: "mappin.and.ellipse"
                        )
                        .lineLimit(1)

                        Spacer()

                        Text(
                            timerInterval:
                                Date()...max(
                                    context.attributes.startDate,
                                    Date().addingTimeInterval(60)
                                ),
                            countsDown: true
                        )
                        .monospacedDigit()
                    }
                    .font(.caption)
                }
            } compactLeading: {
                Image(systemName: context.attributes.symbolName)
                    .foregroundStyle(.purple)
            } compactTrailing: {
                Text("\(context.state.groupSize)")
                    .font(.caption2.bold())
            } minimal: {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(.purple)
            }
            .keylineTint(.purple)
        }
    }

    private func lockScreenView(
        _ context: ActivityViewContext<SocialPlanActivityAttributes>
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: context.attributes.symbolName)
                .font(.title2)
                .foregroundStyle(.purple)
                .frame(width: 44, height: 44)
                .background(.purple.opacity(0.16), in: RoundedRectangle(cornerRadius: 13))

            VStack(alignment: .leading, spacing: 3) {
                Text(context.attributes.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("\(context.state.status) · \(context.state.groupSize) going")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))
            }

            Spacer()

            Text(
                timerInterval:
                    Date()...max(
                        context.attributes.startDate,
                        Date().addingTimeInterval(60)
                    ),
                countsDown: true
            )
            .font(.caption.bold())
            .monospacedDigit()
            .foregroundStyle(.white)
        }
        .padding(16)
    }
}

