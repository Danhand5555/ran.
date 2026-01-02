import SwiftUI

struct ProfileTab: View {
  let colors: RanColors
  let onCustomize: () -> Void
  let onViewLogs: () -> Void

  @EnvironmentObject var firebaseManager: FirebaseManager
  @EnvironmentObject var healthManager: HealthManager

  var body: some View {
    let name = firebaseManager.currentUser?.displayName ?? "UNKNOWN AGENT"
    let joinDate = "MEMBER SINCE ISSUE #1"  // Could format creation date later

    ScrollView {
      VStack(spacing: 30) {
        ZStack {
          SpeedLines(ink: colors.ink, isRotating: false)
          VStack {
            ZStack {
              Circle().fill(colors.accent).frame(width: 140, height: 140).border(
                colors.ink, width: 4
              ).shadow(color: colors.ink, radius: 0, x: 8, y: 8)
              Image(systemName: "figure.run").font(.system(size: 60)).foregroundStyle(colors.ink)
            }
            Text(name.uppercased())
              .font(.system(size: 32, weight: .black))
              .italic()
              .padding(.top, 10)

            Text(joinDate).font(.system(size: 12, weight: .black)).padding(5)
              .background(colors.ink).foregroundStyle(colors.paper)
          }
        }.frame(height: 280).comicPanel(color: colors.panel, ink: colors.ink)

        HStack(spacing: 20) {
          // Use real health data
          ProfileStatBox(
            label: "TOTAL KM", value: String(format: "%.1f", healthManager.monthlyTotalDistance()),
            colors: colors)
          ProfileStatBox(
            label: "MISSIONS", value: "\(healthManager.totalWorkouts())", colors: colors)
        }

        VStack(alignment: .leading, spacing: 10) {
          Text("THE MISSION LOG").font(.headline.bold())
          Text(
            "Currently focused on hitting 500KM before Issue #2 drops. Lead of the Bangkok Speedster Squad."
          ).font(.system(size: 14, weight: .medium, design: .monospaced)).foregroundStyle(
            colors.ink.opacity(0.8))
        }.padding(20).frame(maxWidth: .infinity, alignment: .leading).background(colors.panel)
          .comicPanel(color: colors.panel, ink: colors.ink)

        Button(action: onCustomize) {
          HStack {
            Image(systemName: "paintpalette.fill")
            Text("CUSTOMIZE CHARACTER")
          }.font(.headline.bold()).padding().frame(maxWidth: .infinity).background(colors.sky)
            .comicPanel(color: colors.sky, ink: colors.ink, x: 5, y: 5)
        }.buttonStyle(.plain)

        Button(action: onViewLogs) {
          HStack {
            Image(systemName: "list.bullet.clipboard.fill")
            Text("VIEW MISSION LOGS")
          }.font(.headline.bold()).padding().frame(maxWidth: .infinity).background(colors.accent)
            .comicPanel(color: colors.accent, ink: colors.ink, x: 5, y: 5)
        }.buttonStyle(.plain)
      }.padding(.horizontal, 20).padding(.bottom, 20)
    }
    .onAppear {
      Task {
        await healthManager.fetchTodayStats()
      }
    }
  }
}

struct ProfileStatBox: View {
  let label: String
  let value: String
  let colors: RanColors
  var body: some View {
    VStack {
      Text(label).font(.caption.bold()).foregroundStyle(colors.ink.opacity(0.5))
      Text(value).font(.system(size: 36, weight: .black, design: .rounded))
    }.padding(20).frame(maxWidth: .infinity).background(colors.panel).border(colors.ink, width: 3)
      .background(colors.ink.offset(x: 4, y: 4))
  }
}
