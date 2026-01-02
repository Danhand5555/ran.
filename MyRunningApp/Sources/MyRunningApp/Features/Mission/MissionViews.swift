import SwiftUI

#if os(iOS)
  import UIKit
#endif

struct SharingCardView: View {
  let colors: RanColors
  let distance: Double
  let onBack: () -> Void
  let heroName: String
  let streakDays: Int

  let xpGained: Int
  let timeElapsed: String

  init(
    colors: RanColors, distance: Double, heroName: String, streakDays: Int,
    onBack: @escaping () -> Void
  ) {
    self.colors = colors
    self.distance = distance
    self.heroName = heroName
    self.streakDays = streakDays
    self.onBack = onBack
    self.xpGained = Int(distance * 100)
    self.timeElapsed = String(format: "%02d:%02d", Int(distance * 6), Int.random(in: 10...59))
  }

  var cardContent: some View {
    VStack(spacing: 0) {
      // Header
      HStack(alignment: .bottom) {
        VStack(alignment: .leading, spacing: -5) {
          Text("ran.")
            .font(.system(size: 80, weight: .black, design: .rounded))
            .italic()
            .foregroundStyle(.black)
            .shadow(color: colors.accent, radius: 0, x: 5, y: 5)
          Text("MISSION REPORT")
            .font(.system(size: 14, weight: .black))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.black)
            .foregroundStyle(colors.paper)
        }
        Spacer()
        VStack(alignment: .trailing, spacing: 2) {
          Text("ISSUE #14")
            .font(.system(size: 12, weight: .black))
          Text("JAN 2026")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.black.opacity(0.6))
          ZStack {
            Circle()
              .fill(colors.accent)
              .frame(width: 50, height: 50)
              .overlay(Circle().stroke(.black, lineWidth: 3))
            Text("99¢")
              .font(.system(size: 16, weight: .black))
              .italic()
          }
        }
      }
      .padding(25)
      .background(colors.paper)
      .border(.black, width: 4)

      // Hero Area
      ZStack {
        colors.paper
        HalftoneOverlay(color: colors.ink.opacity(0.1))
        SpeedLines(ink: .black, isRotating: false).opacity(0.2)

        VStack(spacing: 10) {
          // Hero Name Badge
          Text(heroName)
            .font(.system(size: 24, weight: .black))
            .padding(10)
            .background(colors.action)
            .foregroundStyle(.white)
            .rotationEffect(.degrees(-2))
            .border(.black, width: 3)
            .shadow(color: .black, radius: 0, x: 5, y: 5)

          // Distance
          HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(String(format: "%.2f", distance))
              .font(.system(size: 120, weight: .black, design: .rounded))
            Text("KM")
              .font(.system(size: 32, weight: .black))
          }
          .foregroundStyle(.black)
          .shadow(color: colors.accent, radius: 0, x: 8, y: 8)

          Text("TOTAL MISSION GAIN")
            .font(.headline.bold())
            .foregroundStyle(.black.opacity(0.7))

          // Stats Row
          HStack(spacing: 30) {
            MiniStat(label: "TIME", value: timeElapsed, colors: colors)
            MiniStat(label: "XP", value: "+\(xpGained)", colors: colors)
            MiniStat(label: "STREAK", value: "\(streakDays) 🔥", colors: colors)
          }
          .padding(.top, 10)
        }

        // Stickers - positioned in corners to avoid text overlap
        Text("KA-BLAM!")
          .font(.system(size: 18, weight: .black))
          .italic()
          .padding(8)
          .background(colors.sky)
          .border(.black, width: 3)
          .rotationEffect(.degrees(15))
          .position(x: 350, y: 50)

        Text("LEVEL UP!")
          .font(.system(size: 16, weight: .black))
          .padding(6)
          .background(colors.accent)
          .border(.black, width: 3)
          .rotationEffect(.degrees(-10))
          .position(x: 70, y: 380)
      }
      .frame(height: 420)
      .clipped()
      .border(.black, width: 4)

      // Footer
      Text("APPROVED BY THE STREAK CLUB • BANGKOK HQ")
        .font(.system(size: 10, weight: .black))
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(.black)
        .foregroundStyle(.white)
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
          }
          .font(.headline.bold())
          .padding(.horizontal, 30)
          .padding(.vertical, 15)
          .background(colors.panel)
          .comicPanel(color: colors.panel, ink: .black, x: 5, y: 5)
        }

        Button(action: {
          HapticManager.shared.triggerHeavy()
          shareImage()
        }) {
          HStack {
            Image(systemName: "square.and.arrow.up.fill")
            Text("SHARE TO SQUAD")
          }
          .font(.headline.bold())
          .padding(.horizontal, 40)
          .padding(.vertical, 15)
          .background(colors.accent)
          .comicPanel(color: colors.accent, ink: .black, x: 5, y: 5)
        }
      }
      .buttonStyle(.plain)
    }
    .padding(.vertical, 40)
  }

  @MainActor
  func shareImage() {
    let renderer = ImageRenderer(content: cardContent)
    renderer.scale = 3

    #if os(macOS)
      if let image = renderer.nsImage {
        let picker = NSSharingServicePicker(items: [image])
        if let window = NSApplication.shared.windows.first {
          picker.show(relativeTo: .zero, of: window.contentView!, preferredEdge: .minY)
        }
      }
    #elseif os(iOS)
      if let image = renderer.uiImage,
        let imageData = image.jpegData(compressionQuality: 0.9),
        let jpegImage = UIImage(data: imageData)
      {
        let activityVC = UIActivityViewController(
          activityItems: [jpegImage], applicationActivities: nil)
        activityVC.excludedActivityTypes = [.assignToContact, .addToReadingList]
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootVC = windowScene.windows.first?.rootViewController
        {
          // Find topmost presented view controller
          var topVC = rootVC
          while let presented = topVC.presentedViewController {
            topVC = presented
          }
          topVC.present(activityVC, animated: true)
        }
      }
    #endif
  }
}

struct MiniStat: View {
  let label: String
  let value: String
  let colors: RanColors

  var body: some View {
    VStack(spacing: 2) {
      Text(value)
        .font(.system(size: 16, weight: .black))
        .foregroundColor(.black)
      Text(label)
        .font(.system(size: 9, weight: .bold))
        .foregroundColor(.black.opacity(0.5))
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(colors.panel)
    .border(.black, width: 2)
  }
}

struct MissionCompleteSplash: View {
  let colors: RanColors
  let distance: Double
  let heroName: String
  let streakDays: Int
  let onDismiss: () -> Void
  @State private var appear = false
  @State private var isShowingSnapMode = false
  @State private var confettiCounter = 0

  var body: some View {
    ZStack {
      Color.black.opacity(0.95).ignoresSafeArea()

      if !isShowingSnapMode {
        VStack(spacing: 40) {
          // Trophy Badge
          ZStack {
            // Background seal
            Image(systemName: "seal.fill")
              .resizable()
              .frame(width: 320, height: 320)
              .foregroundStyle(colors.accent)
              .rotationEffect(.degrees(appear ? 10 : -10))
              .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: appear)
              .comicPanel(color: colors.accent, ink: colors.ink, x: 12, y: 12)

            VStack(spacing: 0) {
              Text("MISSION")
                .font(.system(size: 34, weight: .black))
              Text("COMPLETE!")
                .font(.system(size: 52, weight: .black))
                .italic()
            }
            .foregroundStyle(colors.ink)
          }
          .scaleEffect(appear ? 1 : 0.5)

          // Results
          VStack(spacing: 15) {
            Text("RESULTS RECORDED")
              .font(.headline.bold())
              .foregroundStyle(.white.opacity(0.8))

            Text("+\(String(format: "%.2f", distance)) KM")
              .font(.system(size: 60, weight: .black, design: .rounded))
              .padding(.horizontal, 30)
              .padding(.vertical, 15)
              .background(colors.action)
              .foregroundStyle(.white)
              .comicPanel(color: colors.action, ink: .black, x: 8, y: 8)

            // XP Gained
            HStack(spacing: 20) {
              StatPill(label: "XP GAINED", value: "+\(Int(distance * 100))", color: colors.accent)
              StatPill(label: "STREAK", value: "\(streakDays) DAYS", color: colors.sky)
            }
          }
          .offset(y: appear ? 0 : 50)
          .opacity(appear ? 1 : 0)

          // Buttons
          VStack(spacing: 20) {
            Button(action: {
              HapticManager.shared.triggerMedium()
              withAnimation(.spring()) { isShowingSnapMode = true }
            }) {
              HStack {
                Image(systemName: "camera.shutter.button.fill")
                Text("TAKE MISSION PHOTO")
              }
              .font(.title3.bold())
              .padding(.vertical, 20)
              .frame(width: 350)
              .background(colors.sky)
              .foregroundStyle(.black)
              .comicPanel(color: colors.sky, ink: .black)
            }

            Button(action: {
              HapticManager.shared.triggerLight()
              onDismiss()
            }) {
              Text("RETURN TO HQ")
                .font(.headline.bold())
                .foregroundStyle(.white.opacity(0.5))
            }
          }
          .buttonStyle(.plain)
        }
      } else {
        SharingCardView(
          colors: colors, distance: distance, heroName: heroName, streakDays: streakDays
        ) {
          withAnimation { isShowingSnapMode = false }
        }
        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale))
      }
    }
    .onAppear {
      HapticManager.shared.triggerSuccess()
      withAnimation(.interpolatingSpring(stiffness: 100, damping: 12)) {
        appear = true
      }
    }
  }
}

struct StatPill: View {
  let label: String
  let value: String
  let color: Color

  var body: some View {
    VStack(spacing: 4) {
      Text(value)
        .font(.system(size: 20, weight: .black))
      Text(label)
        .font(.system(size: 10, weight: .bold))
        .opacity(0.7)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .background(color)
    .foregroundColor(.black)
    .border(.black, width: 3)
  }
}
