import SwiftUI

struct SharingCardView: View {
  let colors: RanColors
  let distance: Double
  let onBack: () -> Void

  // We'll use this to render the image separately from the UI buttons
  var cardContent: some View {
    VStack(spacing: 0) {
      HStack(alignment: .bottom) {
        VStack(alignment: .leading, spacing: -5) {
          Text("ran.").font(.system(size: 80, weight: .black, design: .rounded)).italic()
            .foregroundStyle(.black).shadow(color: colors.accent, radius: 0, x: 5, y: 5)
          Text("MISSION REPORT").font(.system(size: 14, weight: .black)).padding(.horizontal, 8)
            .padding(.vertical, 4).background(.black).foregroundStyle(colors.paper)
        }
        Spacer()
        VStack(alignment: .trailing, spacing: 2) {
          Text("ISSUE #14").font(.system(size: 12, weight: .black))
          Text("JAN 2026").font(.system(size: 10, weight: .bold)).foregroundStyle(
            .black.opacity(0.6))
          Text("99¢").font(.system(size: 18, weight: .black)).italic().padding(10).background(
            Circle().fill(colors.accent).border(.black, width: 3))
        }
      }
      .padding(25).background(colors.paper).border(.black, width: 4)

      ZStack {
        colors.paper
        HalftoneOverlay(color: colors.ink.opacity(0.1))
        SpeedLines(ink: .black, isRotating: false).opacity(0.2)

        VStack(spacing: 10) {
          Text("DANN THE FLASH").font(.system(size: 24, weight: .black)).padding(10).background(
            colors.action
          ).foregroundStyle(.white).rotationEffect(.degrees(-2)).border(.black, width: 3).shadow(
            color: .black, radius: 0, x: 5, y: 5)
          HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(String(format: "%.2f", distance)).font(
              .system(size: 120, weight: .black, design: .rounded))
            Text("KM").font(.system(size: 32, weight: .black))
          }.foregroundStyle(.black).shadow(color: colors.accent, radius: 0, x: 8, y: 8)
          Text("TOTAL MISSION GAIN").font(.headline.bold()).foregroundStyle(.black.opacity(0.7))
        }
        Text("KA-BLAM!").font(.system(size: 20, weight: .black)).italic().padding(10).background(
          colors.sky
        ).border(.black, width: 3).rotationEffect(.degrees(15)).offset(x: 130, y: -100)
        Text("LEVEL UP!").font(.system(size: 18, weight: .black)).padding(8).background(
          colors.accent
        ).border(.black, width: 3).rotationEffect(.degrees(-10)).offset(x: -120, y: 120)
      }.frame(height: 400).clipped().border(.black, width: 4)

      Text("APPROVED BY THE STREAK CLUB • BANGKOK HQ").font(.system(size: 10, weight: .black))
        .padding(15).frame(maxWidth: .infinity).background(.black).foregroundStyle(.white)
    }
    .frame(width: 420)
  }

  var body: some View {
    VStack(spacing: 30) {
      cardContent
        .comicPanel(color: colors.paper, ink: .black, x: 12, y: 12)

      HStack(spacing: 20) {
        Button(action: onBack) {
          HStack {
            Image(systemName: "arrow.left")
            Text("BACK")
          }.font(.headline.bold()).padding(.horizontal, 30).padding(.vertical, 15).background(
            colors.panel
          ).comicPanel(color: colors.panel, ink: .black, x: 5, y: 5)
        }

        Button(action: shareImage) {
          HStack {
            Image(systemName: "square.and.arrow.up.fill")
            Text("SHARE TO SQUAD")
          }.font(.headline.bold()).padding(.horizontal, 40).padding(.vertical, 15).background(
            colors.accent
          ).comicPanel(color: colors.accent, ink: .black, x: 5, y: 5)
        }
      }.buttonStyle(.plain)
    }.padding(.vertical, 40)
  }

  @MainActor
  func shareImage() {
    // macOS logic for ImageRenderer and Sharing Services
    let renderer = ImageRenderer(content: cardContent)
    renderer.scale = 3  // High res

    if let image = renderer.nsImage {
      let picker = NSSharingServicePicker(items: [image])
      // We need a way to find a view to attach to. In a simple app, we can use the main window.
      if let window = NSApplication.shared.windows.first {
        picker.show(relativeTo: .zero, of: window.contentView!, preferredEdge: .minYIndex)
      }
    }
  }
}

struct MissionCompleteSplash: View {
  let colors: RanColors
  let distance: Double
  let onDismiss: () -> Void
  @State private var appear = false
  @State private var isShowingSnapMode = false
  var body: some View {
    ZStack {
      Color.black.opacity(0.9).ignoresSafeArea()
      if !isShowingSnapMode {
        VStack(spacing: 40) {
          ZStack {
            Image(systemName: "seal.fill").resizable().frame(width: 320, height: 320)
              .foregroundStyle(colors.accent).rotationEffect(.degrees(appear ? 10 : -10))
              .comicPanel(color: colors.accent, ink: colors.ink, x: 12, y: 12)
            VStack(spacing: 0) {
              Text("MISSION").font(.system(size: 34, weight: .black))
              Text("COMPLETE!").font(.system(size: 52, weight: .black)).italic()
            }.foregroundStyle(colors.ink)
          }.scaleEffect(appear ? 1 : 0.5)
          VStack(spacing: 15) {
            Text("RESULTS RECORDED").font(.headline.bold()).foregroundStyle(.white.opacity(0.8))
            Text("+\(String(format: "%.2f", distance)) KM").font(
              .system(size: 60, weight: .black, design: .rounded)
            ).padding(.horizontal, 30).padding(.vertical, 15).background(colors.action).comicPanel(
              color: colors.action, ink: .black, x: 8, y: 8)
          }.offset(y: appear ? 0 : 50).opacity(appear ? 1 : 0)
          VStack(spacing: 20) {
            Button(action: { withAnimation(.spring()) { isShowingSnapMode = true } }) {
              HStack {
                Image(systemName: "camera.shutter.button.fill")
                Text("TAKE MISSION PHOTO")
              }.font(.title3.bold()).padding(.vertical, 20).frame(width: 350).background(colors.sky)
                .comicPanel(color: colors.sky, ink: .black)
            }
            Button(action: onDismiss) {
              Text("RETURN TO HQ").font(.headline.bold()).foregroundStyle(.white.opacity(0.6))
            }
          }.buttonStyle(.plain)
        }
      } else {
        SharingCardView(colors: colors, distance: distance) {
          withAnimation { isShowingSnapMode = false }
        }.transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale))
      }
    }.onAppear {
      withAnimation(.interpolatingSpring(stiffness: 100, damping: 12)) { appear = true }
    }
  }
}
