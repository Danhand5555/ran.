import SwiftUI

struct ProfileTab: View {
  let colors: RanColors
  let onCustomize: () -> Void

  var body: some View {
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
            Text("DANN THE FLASH").font(.system(size: 32, weight: .black)).italic().padding(
              .top, 10)
            Text("MEMBER SINCE ISSUE #1").font(.system(size: 12, weight: .black)).padding(5)
              .background(colors.ink).foregroundStyle(colors.paper)
          }
        }.frame(height: 280).comicPanel(color: colors.panel, ink: colors.ink)
        HStack(spacing: 20) {
          ProfileStatBox(label: "TOTAL KM", value: "428.5", colors: colors)
          ProfileStatBox(label: "MISSIONS", value: "94", colors: colors)
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
      }.padding(.horizontal, 30).padding(.bottom, 20)
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
