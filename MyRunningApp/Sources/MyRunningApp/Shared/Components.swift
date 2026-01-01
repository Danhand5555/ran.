import SwiftUI

// MARK: - Modifiers
struct ComicPanel: ViewModifier {
  let color: Color
  let inkColor: Color
  let xShadow: CGFloat
  let yShadow: CGFloat
  func body(content: Content) -> some View {
    content.background(color).border(inkColor, width: RanColors.thickness).offset(x: -2, y: -2)
      .background(inkColor.offset(x: xShadow, y: yShadow))
  }
}

extension View {
  func comicPanel(
    color: Color, ink: Color, x: CGFloat = RanColors.shadowOffset,
    y: CGFloat = RanColors.shadowOffset
  ) -> some View {
    self.modifier(ComicPanel(color: color, inkColor: ink, xShadow: x, yShadow: y))
  }
}

// MARK: - Visuals
struct ZineBackground: View {
  let colors: RanColors
  var body: some View {
    ZStack {
      colors.paper.ignoresSafeArea()
      Canvas { context, size in
        let step: CGFloat = 16
        for x in stride(from: 0, to: size.width, by: step) {
          for y in stride(from: 0, to: size.height, by: step) {
            context.fill(
              Path(ellipseIn: CGRect(x: x, y: y, width: 2.5, height: 2.5)),
              with: .color(colors.ink.opacity(0.06)))
          }
        }
      }
    }.ignoresSafeArea()
  }
}

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
            with: .color(color))
        }
      }
    }
  }
}

struct SpeedLines: View {
  let ink: Color
  let isRotating: Bool
  @State private var rotation: Double = 0
  var body: some View {
    Canvas { context, size in
      let center = CGPoint(x: size.width / 2, y: size.height / 2)
      for i in 0..<36 {
        let angle = Double(i) * 10 * .pi / 180.0
        let length = size.width * 1.5
        var path = Path()
        path.move(to: center)
        path.addLine(
          to: CGPoint(
            x: center.x + CGFloat(cos(angle)) * length, y: center.y + CGFloat(sin(angle)) * length))
        context.stroke(path, with: .color(ink.opacity(0.12)), lineWidth: 3.0)
      }
    }.rotationEffect(.degrees(rotation))
      .onAppear {
        if isRotating {
          withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) { rotation = 360 }
        }
      }
  }
}
