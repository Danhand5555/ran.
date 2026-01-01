import SwiftUI

struct RunTab: View {
  let colors: RanColors
  let onStart: () -> Void
  @State private var isPulsing = false
  @State private var streakDays = 14

  var body: some View {
    VStack(spacing: 0) {
      // Streak Display
      ZStack {
        SpeedLines(ink: colors.ink, isRotating: false)
        VStack(spacing: -5) {
          Text("\(streakDays)")
            .font(.system(size: 150, weight: .black, design: .rounded))
            .foregroundStyle(colors.paper)
            .shadow(color: colors.ink, radius: 0, x: 8, y: 8)
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(
              .easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)

          Text("DAY STREAK")
            .font(.system(size: 28, weight: .black))
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .comicPanel(color: colors.accent, ink: colors.ink)
            .rotationEffect(.degrees(-3))
        }

        // Fire badge
        FireStreakBadge(colors: colors)
          .offset(x: 100, y: -80)
      }
      .frame(height: 280)
      .onAppear { isPulsing = true }

      // Weekly Progress Bar
      WeeklyProgressView(colors: colors, currentDay: streakDays % 7)
        .padding(.horizontal, 40)
        .padding(.top, 20)

      Spacer().frame(height: 30)

      // Contract Card
      VStack(alignment: .leading, spacing: 0) {
        Text("READY FOR TODAY'S MISSION?")
          .font(.system(size: 18, weight: .black))
          .italic()
          .multilineTextAlignment(.center)
          .padding(25)
          .frame(maxWidth: .infinity)
          .background(colors.panel)
          .border(colors.ink, width: RanColors.thickness)
          .background(colors.ink.offset(x: 5, y: 5))

        Image(systemName: "arrowtriangle.down.fill")
          .resizable()
          .frame(width: 30, height: 20)
          .foregroundStyle(colors.panel)
          .offset(x: 40, y: -2)
          .overlay(
            Image(systemName: "arrowtriangle.down.fill")
              .resizable()
              .frame(width: 30, height: 20)
              .foregroundStyle(colors.ink)
              .offset(x: 42, y: 2)
              .zIndex(-1)
          )
      }
      .padding(.horizontal, 40)

      Spacer().frame(height: 40)

      // Start Button
      Button(action: onStart) {
        HStack(spacing: 12) {
          Image(systemName: "play.fill")
          Text("START MISSION")
        }
        .font(.system(size: 24, weight: .black))
        .foregroundStyle(colors.paper)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity)
        .background(colors.ink)
        .comicPanel(color: colors.ink, ink: colors.ink, x: 6, y: 6)
      }
      .buttonStyle(.plain)
      .padding(.horizontal, 50)

      // Quick Stats
      HStack(spacing: 30) {
        QuickStat(label: "This Week", value: "12.4 km", colors: colors)
        QuickStat(label: "Best Streak", value: "21 days", colors: colors)
      }
      .padding(.top, 25)
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
  @State private var distance = 0.0
  @State private var timer = 0
  @State private var pace = 5.30
  @State private var calories = 0
  let timerJob = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  var body: some View {
    ZStack {
      colors.paper.ignoresSafeArea()

      VStack(spacing: 20) {
        // Header
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("MISSION: RUN")
              .font(.system(size: 14, weight: .black))
              .padding(8)
              .background(colors.ink)
              .foregroundStyle(colors.paper)
            Text("Bangkok • Sector 7B")
              .font(.system(size: 11, weight: .bold))
              .foregroundColor(colors.ink.opacity(0.5))
          }
          Spacer()
          VStack(alignment: .trailing, spacing: 4) {
            Text("LVL 42")
              .font(.system(size: 16, weight: .black))
              .italic()
            Text("+\(Int(distance * 100)) XP")
              .font(.system(size: 12, weight: .bold))
              .foregroundColor(colors.accent)
          }
        }
        .padding(.top, 50)
        .padding(.horizontal, 30)

        Spacer()

        // Main Distance Display
        ZStack {
          SpeedLines(ink: colors.ink, isRotating: true)
          VStack(spacing: 10) {
            Text(String(format: "%.2f", distance))
              .font(.system(size: 120, weight: .black, design: .rounded))
              .foregroundStyle(colors.ink)
              .shadow(color: colors.accent, radius: 0, x: 8, y: 8)
              .contentTransition(.numericText())

            Text("KILOMETERS")
              .font(.system(size: 24, weight: .black))
              .padding(.horizontal, 15)
              .padding(.vertical, 5)
              .background(colors.accent)
              .border(colors.ink, width: 3)
          }
        }

        // Stats Grid
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
          RunStatBox(label: "TIME", value: formatTime(timer), colors: colors)
          RunStatBox(label: "PACE", value: String(format: "%.2f /km", pace), colors: colors)
          RunStatBox(label: "CALORIES", value: "\(calories)", colors: colors)
          RunStatBox(label: "ENERGY", value: "98%", colors: colors)
        }
        .padding(.horizontal, 30)

        Spacer()

        // Finish Button
        Button {
          onStop(distance)
        } label: {
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
        .padding(.horizontal, 40)
        .padding(.bottom, 50)
      }
    }
    .onReceive(timerJob) { _ in
      timer += 1
      distance += Double.random(in: 0.006...0.012)
      calories = Int(distance * 62)
      pace = 5.0 + Double.random(in: -0.3...0.3)
    }
  }

  func formatTime(_ s: Int) -> String {
    String(format: "%02d:%02d", s / 60, s % 60)
  }
}
