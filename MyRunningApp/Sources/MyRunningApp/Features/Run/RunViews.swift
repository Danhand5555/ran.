import SwiftUI

struct RunTab: View {
  let colors: RanColors
  let onStart: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        SpeedLines(ink: colors.ink, isRotating: false)
        VStack(spacing: -5) {
          Text("14").font(.system(size: 150, weight: .black, design: .rounded)).foregroundStyle(
            colors.paper
          ).shadow(color: colors.ink, radius: 0, x: 8, y: 8)
          Text("DAY STREAK").font(.system(size: 28, weight: .black)).padding(.horizontal, 20)
            .padding(.vertical, 8).comicPanel(color: colors.accent, ink: colors.ink).rotationEffect(
              .degrees(-3))
        }
      }.frame(height: 300)

      Spacer().frame(height: 40)

      VStack(alignment: .leading, spacing: 0) {
        Text("READY FOR TODAY'S MISSION?").font(.system(size: 18, weight: .black)).italic()
          .multilineTextAlignment(.center).padding(25).frame(maxWidth: .infinity).background(
            colors.panel
          ).border(colors.ink, width: RanColors.thickness).background(colors.ink.offset(x: 5, y: 5))
        Image(systemName: "arrowtriangle.down.fill").resizable().frame(width: 30, height: 20)
          .foregroundStyle(colors.panel).offset(x: 40, y: -2).overlay(
            Image(systemName: "arrowtriangle.down.fill").resizable().frame(width: 30, height: 20)
              .foregroundStyle(colors.ink).offset(x: 42, y: 2).zIndex(-1))
      }.padding(.horizontal, 40)

      Spacer().frame(height: 50)

      Button(action: onStart) {
        HStack(spacing: 12) {
          Image(systemName: "play.fill")
          Text("START MISSION")
        }.font(.system(size: 24, weight: .black)).foregroundStyle(colors.paper).padding(
          .vertical, 22
        ).frame(maxWidth: .infinity).background(colors.ink).comicPanel(
          color: colors.ink, ink: colors.ink, x: 6, y: 6)
      }.buttonStyle(.plain).padding(.horizontal, 50)
    }
  }
}

struct RunStatBox: View {
  let label: String
  let value: String
  let colors: RanColors
  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(label).font(.system(size: 12, weight: .black)).foregroundStyle(colors.ink.opacity(0.6))
      Text(value).font(.system(size: 32, weight: .black, design: .rounded)).foregroundStyle(
        colors.ink)
    }.padding(20).frame(maxWidth: .infinity, alignment: .leading).background(colors.panel).border(
      colors.ink, width: 3
    ).background(colors.ink.offset(x: 4, y: 4))
  }
}

struct ActiveRunPage: View {
  let colors: RanColors
  let onStop: (Double) -> Void
  @State private var distance = 0.0
  @State private var timer = 0
  let timerJob = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  var body: some View {
    ZStack {
      colors.paper.ignoresSafeArea()
      VStack(spacing: 30) {
        HStack {
          Text("MISSION: RUN").font(.system(size: 14, weight: .black)).padding(8).background(
            colors.ink
          ).foregroundStyle(colors.paper)
          Spacer()
          Text("LEVEL UP IN PROGRESS").font(.system(size: 12, weight: .black)).italic()
        }.padding(.top, 50).padding(.horizontal, 30)
        Spacer()
        ZStack {
          SpeedLines(ink: colors.ink, isRotating: true)
          VStack(spacing: 15) {
            Text(String(format: "%.2f", distance)).font(
              .system(size: 120, weight: .black, design: .rounded)
            ).foregroundStyle(colors.ink).shadow(color: colors.accent, radius: 0, x: 8, y: 8)
            Text("KILOMETERS").font(.system(size: 24, weight: .black)).padding(.horizontal, 15)
              .padding(.vertical, 5).background(colors.accent).border(colors.ink, width: 3)
          }
        }
        HStack(spacing: 20) {
          RunStatBox(label: "TIME", value: formatTime(timer), colors: colors)
          RunStatBox(label: "ENERGY", value: "98%", colors: colors)
        }.padding(.horizontal, 30)
        Spacer()
        Button {
          onStop(distance)
        } label: {
          HStack {
            Image(systemName: "flag.checkered")
            Text("FINISH MISSION")
          }.font(.system(size: 24, weight: .black)).foregroundStyle(Color.white).padding(
            .vertical, 22
          )
          .frame(maxWidth: .infinity).background(colors.action).comicPanel(
            color: colors.action, ink: Color.black, x: 6, y: 6)
        }.buttonStyle(.plain).padding(.horizontal, 40).padding(.bottom, 50)
      }
    }.onReceive(timerJob) { _ in
      timer += 1
      distance += 0.008
    }
  }
  func formatTime(_ s: Int) -> String { String(format: "%02d:%02d", s / 60, s % 60) }
}
