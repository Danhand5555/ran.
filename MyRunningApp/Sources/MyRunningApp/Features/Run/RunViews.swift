import SwiftUI

struct RunTab: View {
  let colors: RanColors
  let onStart: () -> Void
  @State private var isPulsing = false
  @State private var streakDays = 14
  @StateObject private var healthManager = HealthManager()

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 0) {
        // Streak Display
        ZStack {
          SpeedLines(ink: colors.ink, isRotating: false)
          VStack(spacing: -5) {
            Text("\(streakDays)")
              .font(.system(size: 120, weight: .black, design: .rounded))
              .foregroundStyle(colors.paper)
              .shadow(color: colors.ink, radius: 0, x: 6, y: 6)
              .scaleEffect(isPulsing ? 1.03 : 1.0)
              .animation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)

            Text("DAY STREAK")
              .font(.system(size: 24, weight: .black))
              .padding(.horizontal, 16)
              .padding(.vertical, 6)
              .comicPanel(color: colors.accent, ink: colors.ink)
              .rotationEffect(.degrees(-3))
          }

          // Fire badge
          FireStreakBadge(colors: colors)
            .offset(x: 90, y: -60)
        }
        .frame(height: 200)
        .onAppear { isPulsing = true }

        // Weekly Progress Bar
        WeeklyProgressView(colors: colors, currentDay: streakDays % 7)
          .padding(.horizontal, 20)
          .padding(.top, 15)

        Spacer().frame(height: 20)

        // Contract Card
        VStack(alignment: .leading, spacing: 0) {
          Text("READY FOR TODAY'S MISSION?")
            .font(.system(size: 16, weight: .black))
            .italic()
            .multilineTextAlignment(.center)
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(colors.panel)
            .border(colors.ink, width: RanColors.thickness)
            .background(colors.ink.offset(x: 5, y: 5))

          Image(systemName: "arrowtriangle.down.fill")
            .resizable()
            .frame(width: 25, height: 16)
            .foregroundStyle(colors.panel)
            .offset(x: 35, y: -2)
            .overlay(
              Image(systemName: "arrowtriangle.down.fill")
                .resizable()
                .frame(width: 25, height: 16)
                .foregroundStyle(colors.ink)
                .offset(x: 37, y: 2)
                .zIndex(-1)
            )
        }
        .padding(.horizontal, 20)

        Spacer().frame(height: 25)

        // Start Button
        Button(action: onStart) {
          HStack(spacing: 12) {
            Image(systemName: "play.fill")
            Text("START MISSION")
          }
          .font(.system(size: 22, weight: .black))
          .foregroundStyle(colors.paper)
          .padding(.vertical, 18)
          .frame(maxWidth: .infinity)
          .background(colors.ink)
          .comicPanel(color: colors.ink, ink: colors.ink, x: 6, y: 6)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)

        // Quick Stats - Real data from HealthKit
        HStack(spacing: 30) {
          QuickStat(
            label: "This Week",
            value: String(format: "%.1f km", healthManager.weeklyDistance),
            colors: colors
          )
          QuickStat(label: "Best Streak", value: "21 days", colors: colors)
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
      }
    }
    .onAppear {
      Task {
        await healthManager.requestAuthorization()
      }
    }
  }
}

// MARK: - Weekly Progress
struct WeeklyProgressView: View {
  let colors: RanColors
  let currentDay: Int
  let days = ["M", "T", "W", "T", "F", "S", "S"]

  var body: some View {
    HStack(spacing: 8) {
      ForEach(0..<7, id: \.self) { i in
        VStack(spacing: 6) {
          ZStack {
            Circle()
              .fill(i < currentDay ? colors.accent : colors.panel)
              .frame(width: 36, height: 36)
              .overlay(
                Circle().stroke(colors.ink, lineWidth: 2)
              )

            if i < currentDay {
              Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(colors.ink)
            } else if i == currentDay {
              Circle()
                .fill(colors.action)
                .frame(width: 12, height: 12)
            }
          }

          Text(days[i])
            .font(.system(size: 10, weight: .black))
            .foregroundColor(i <= currentDay ? colors.ink : colors.ink.opacity(0.3))
        }
      }
    }
    .padding(.vertical, 15)
    .padding(.horizontal, 20)
    .background(colors.panel)
    .border(colors.ink, width: 2)
  }
}

// MARK: - Quick Stat
struct QuickStat: View {
  let label: String
  let value: String
  let colors: RanColors

  var body: some View {
    VStack(spacing: 2) {
      Text(value)
        .font(.system(size: 18, weight: .black))
        .foregroundColor(colors.ink)
      Text(label)
        .font(.system(size: 10, weight: .bold))
        .foregroundColor(colors.ink.opacity(0.5))
        .textCase(.uppercase)
    }
  }
}

// MARK: - Run Stat Box
struct RunStatBox: View {
  let label: String
  let value: String
  let colors: RanColors

  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(label)
        .font(.system(size: 12, weight: .black))
        .foregroundStyle(colors.ink.opacity(0.6))
      Text(value)
        .font(.system(size: 32, weight: .black, design: .rounded))
        .foregroundStyle(colors.ink)
    }
    .padding(20)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(colors.panel)
    .border(colors.ink, width: 3)
    .background(colors.ink.offset(x: 4, y: 4))
  }
}

// MARK: - Active Run Page
struct ActiveRunPage: View {
  let colors: RanColors
  let onStop: (Double) -> Void

  @StateObject private var locationManager = LocationManager()
  @StateObject private var healthManager = HealthManager()

  @State private var elapsedTime: TimeInterval = 0
  @State private var calories = 0

  let timerJob = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  private var formattedDistance: String {
    String(format: "%.2f", locationManager.totalDistance)
  }

  private var formattedPace: String {
    if locationManager.currentPace > 0 && locationManager.currentPace < 20 {
      return String(format: "%.2f", locationManager.currentPace)
    }
    return "--"
  }

  var body: some View {
    ZStack {
      colors.paper.ignoresSafeArea()

      VStack(spacing: 20) {
        // Top breathing room to ensure floating effect (clears Dynamic Island)
        Color.clear.frame(height: 80)

        // Header
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("MISSION: RUN")
              .font(.system(size: 14, weight: .black))
              .padding(8)
              .background(colors.ink)
              .foregroundStyle(colors.paper)
              .comicPanel(color: colors.ink, ink: colors.ink, x: 4, y: 4)
            Text("Bangkok • Sector 7B")
              .font(.system(size: 11, weight: .bold))
              .foregroundColor(colors.ink.opacity(0.5))
          }
          Spacer()
          VStack(alignment: .trailing, spacing: 4) {
            Text("LVL 42")
              .font(.system(size: 16, weight: .black))
              .italic()
            Text("+\(Int(locationManager.totalDistance * 100)) XP")
              .font(.system(size: 12, weight: .bold))
              .foregroundColor(colors.accent)
          }
        }
        .padding(.horizontal, 20)

        // Main Metric (Distance)
        VStack(spacing: 5) {
          Text(formattedDistance)
            .font(.system(size: 120, weight: .black, design: .rounded))
            .foregroundColor(colors.ink)
            .shadow(color: colors.ink.opacity(0.1), radius: 0, x: 5, y: 5)

          Text("KILOMETERS")
            .font(.system(size: 24, weight: .black))
            .foregroundColor(colors.ink)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(colors.accent)
            .comicPanel(color: colors.accent, ink: colors.ink)
          // Removed negative offset and increased spacing for better UI/UX
        }

        Spacer()

        // Stats Grid
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
          RunStatBox(label: "TIME", value: formatTime(Int(elapsedTime)), colors: colors)
          RunStatBox(label: "PACE", value: formattedPace, colors: colors)
          RunStatBox(label: "CALORIES", value: "\(calories)", colors: colors)
          RunStatBox(label: "BPM", value: "\(healthManager.currentHeartRate)", colors: colors)
        }.padding(.horizontal, 20)

        Spacer()

        // Stop Button
        Button(action: {
          locationManager.stopTracking()
          onStop(locationManager.totalDistance)
        }) {
          HStack {
            Image(systemName: "flag.checkered")
            Text("FINISH MISSION")
          }
          .font(.system(size: 24, weight: .black))
          .foregroundStyle(Color.white)
          .padding(.vertical, 22)
          .frame(maxWidth: .infinity)
          .background(colors.action)
          .comicPanel(color: colors.action, ink: Color.black, x: 6, y: 6)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.bottom, 60)  // Increased padding to lift button off the bottom edge
      }
    }
    .onAppear {
      locationManager.requestAuthorization()
      locationManager.startTracking()
      Task {
        await healthManager.requestAuthorization()
      }
    }
    .onReceive(timerJob) { _ in
      elapsedTime += 1
      // Estimate calories (approx 60 cal/km for running)
      calories = Int(locationManager.totalDistance * 60)
    }
  }

  func formatTime(_ s: Int) -> String {
    String(format: "%02d:%02d", s / 60, s % 60)
  }
}
