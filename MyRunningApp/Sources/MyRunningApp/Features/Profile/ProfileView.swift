import SwiftUI

struct ProfileTab: View {
  let colors: RanColors
  let onCustomize: () -> Void
  let onViewLogs: () -> Void

  @EnvironmentObject var firebaseManager: FirebaseManager
  @EnvironmentObject var healthManager: HealthManager

  @State private var showLogoutConfirmation = false
  @AppStorage("userAvatarColor") private var userAvatarColorName: String = "red"

  private var avatarColor: Color {
    switch userAvatarColorName {
    case "blue": return .blue
    case "green": return .green
    case "orange": return .orange
    case "purple": return .purple
    case "cyan": return .cyan
    default: return .red
    }
  }

  var body: some View {
    let name = firebaseManager.currentUser?.displayName ?? "UNKNOWN AGENT"
    let joinDate = "MEMBER SINCE ISSUE #1"  // Could format creation date later

    ScrollView {
      VStack(spacing: 30) {
        ZStack {
          SpeedLines(ink: avatarColor, isRotating: false)
          VStack {
            ZStack {
              Circle().fill(avatarColor).frame(width: 140, height: 140).border(
                colors.ink, width: 4
              ).shadow(color: avatarColor.opacity(0.5), radius: 15, x: 8, y: 8)
              Image(systemName: "figure.run").font(.system(size: 60)).foregroundStyle(colors.paper)
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

        // Logout Button
        Button(action: { showLogoutConfirmation = true }) {
          HStack {
            Image(systemName: "rectangle.portrait.and.arrow.right")
            Text("SIGN OUT")
          }.font(.headline.bold()).padding().frame(maxWidth: .infinity).background(colors.action)
            .comicPanel(color: colors.action, ink: colors.ink, x: 5, y: 5)
        }.buttonStyle(.plain)
      }.padding(.horizontal, 20).padding(.bottom, 20)
    }
    .onAppear {
      Task {
        await healthManager.fetchTodayStats()
      }
    }
    .alert("CONFIRM SIGN OUT", isPresented: $showLogoutConfirmation) {
      Button("CANCEL", role: .cancel) {}
      Button("SIGN OUT", role: .destructive) {
        do {
          try firebaseManager.signOut()
        } catch {
          print("DEBUG: Sign out failed: \(error)")
        }
      }
    } message: {
      Text("Are you sure you want to sign out?")
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
