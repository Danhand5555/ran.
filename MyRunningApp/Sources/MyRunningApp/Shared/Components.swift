import SwiftUI

// MARK: - Comic Panel Modifier
struct ComicPanel: ViewModifier {
  let color: Color
  let inkColor: Color
  let xShadow: CGFloat
  let yShadow: CGFloat

  func body(content: Content) -> some View {
    content
      .background(color)
      .border(inkColor, width: RanColors.thickness)
      .offset(x: -2, y: -2)
      .background(inkColor.offset(x: xShadow, y: yShadow))
  }
}

extension View {
  func comicPanel(
    color: Color, ink: Color,
    x: CGFloat = RanColors.shadowOffset,
    y: CGFloat = RanColors.shadowOffset
  ) -> some View {
    self.modifier(ComicPanel(color: color, inkColor: ink, xShadow: x, yShadow: y))
  }
}

// MARK: - Zine Background
struct ZineBackground: View {
  let colors: RanColors
  @State private var animateGrain = false

  var body: some View {
    ZStack {
      // Base color
      colors.paper.ignoresSafeArea()

      // Halftone dots
      Canvas { context, size in
        let step: CGFloat = 18
        for x in stride(from: 0, to: size.width, by: step) {
          for y in stride(from: 0, to: size.height, by: step) {
            context.fill(
              Path(ellipseIn: CGRect(x: x, y: y, width: 2.5, height: 2.5)),
              with: .color(colors.ink.opacity(0.05))
            )
          }
        }
      }

      // Subtle vignette
      RadialGradient(
        colors: [.clear, colors.ink.opacity(0.08)],
        center: .center,
        startRadius: 200,
        endRadius: 600
      )
      .ignoresSafeArea()
    }
    .ignoresSafeArea()
  }
}

// MARK: - Halftone Overlay
struct HalftoneOverlay: View {
  let color: Color

  var body: some View {
    Canvas { context, size in
      let step: CGFloat = 8
      for x in stride(from: 0, to: size.width, by: step) {
        for y in stride(from: 0, to: size.height, by: step) {
          let dotSize: CGFloat = 1.5 + abs(sin(x * 0.01 + y * 0.01)) * 2
          context.fill(
            Path(ellipseIn: CGRect(x: x, y: y, width: dotSize, height: dotSize)),
            with: .color(color)
          )
        }
      }
    }
  }
}

// MARK: - Speed Lines
struct SpeedLines: View {
  let ink: Color
  let isRotating: Bool
  @State private var rotation: Double = 0

  var body: some View {
    Canvas { context, size in
      let center = CGPoint(x: size.width / 2, y: size.height / 2)
      for i in 0..<48 {
        let angle = Double(i) * 7.5 * .pi / 180.0
        let length = size.width * 1.5
        var path = Path()
        path.move(to: center)
        path.addLine(
          to: CGPoint(
            x: center.x + CGFloat(cos(angle)) * length,
            y: center.y + CGFloat(sin(angle)) * length
          ))
        context.stroke(path, with: .color(ink.opacity(0.1)), lineWidth: 2.5)
      }
    }
    .rotationEffect(.degrees(rotation))
    .onAppear {
      if isRotating {
        withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
          rotation = 360
        }
      }
    }
  }
}

// MARK: - Glowing Badge
struct GlowingBadge: View {
  let text: String
  let color: Color
  let ink: Color
  @State private var isGlowing = false

  var body: some View {
    Text(text)
      .font(.system(size: 12, weight: .black))
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(color)
      .foregroundColor(ink)
      .border(ink, width: 2)
      .shadow(color: color.opacity(isGlowing ? 0.6 : 0.2), radius: isGlowing ? 10 : 4)
      .onAppear {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
          isGlowing = true
        }
      }
  }
}

// MARK: - Fire Streak Badge
struct FireStreakBadge: View {
  let colors: RanColors
  @State private var flameOffset: CGFloat = 0

  var body: some View {
    HStack(spacing: 4) {
      Text("🔥")
        .font(.system(size: 18))
        .offset(y: flameOffset)
      Text("ON FIRE")
        .font(.system(size: 12, weight: .black))
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .background(colors.action)
    .foregroundColor(.white)
    .border(.black, width: 2)
    .rotationEffect(.degrees(-8))
    .onAppear {
      withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
        flameOffset = -3
      }
    }
  }
}

// MARK: - Animated Counter
struct AnimatedCounter: View {
  let value: Int
  let font: Font
  let color: Color

  var body: some View {
    Text("\(value)")
      .font(font)
      .foregroundColor(color)
      .contentTransition(.numericText())
      .animation(.spring(response: 0.3), value: value)
  }
}

// MARK: - Progress Ring
struct ProgressRing: View {
  let progress: Double
  let lineWidth: CGFloat
  let colors: RanColors

  var body: some View {
    ZStack {
      Circle()
        .stroke(colors.ink.opacity(0.1), lineWidth: lineWidth)

      Circle()
        .trim(from: 0, to: progress)
        .stroke(
          AngularGradient(
            colors: [colors.accent, colors.action, colors.accent],
            center: .center
          ),
          style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
        )
        .rotationEffect(.degrees(-90))
        .animation(.spring(response: 0.6), value: progress)
    }
  }
}

// MARK: - Floating Action Hint
struct FloatingHint: View {
  let text: String
  let icon: String
  @State private var isVisible = false

  var body: some View {
    HStack(spacing: 6) {
      Image(systemName: icon)
        .font(.system(size: 10, weight: .bold))
      Text(text)
        .font(.system(size: 10, weight: .bold))
    }
    .foregroundColor(.white.opacity(0.5))
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(.ultraThinMaterial)
    .cornerRadius(20)
    .opacity(isVisible ? 1 : 0)
    .offset(y: isVisible ? 0 : 10)
    .onAppear {
      withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
        isVisible = true
      }
    }
  }
}

// MARK: - XP Gain Popup
struct XPGainPopup: View {
  let amount: Int
  @State private var show = false

  var body: some View {
    Text("+\(amount) XP")
      .font(.system(size: 14, weight: .black))
      .foregroundColor(.white)
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(Color.green)
      .cornerRadius(12)
      .scaleEffect(show ? 1 : 0.5)
      .opacity(show ? 1 : 0)
      .onAppear {
        withAnimation(.spring(response: 0.3)) {
          show = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
          withAnimation(.easeOut) {
            show = false
          }
        }
      }
  }
}
