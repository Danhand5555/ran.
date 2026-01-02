import SwiftUI

struct RanColors {
  let scheme: ColorScheme

  init(scheme: ColorScheme = .light) {
    self.scheme = scheme
  }

  var ink: Color {
    scheme == .dark ? .white : .black
  }

  var paper: Color {
    scheme == .dark
      ? Color(red: 0.06, green: 0.06, blue: 0.06)
      : Color(red: 0.98, green: 0.97, blue: 0.92)
  }

  var panel: Color {
    scheme == .dark
      ? Color(red: 0.12, green: 0.12, blue: 0.12)
      : .white
  }

  var accent: Color {
    Color(red: 1.0, green: 0.85, blue: 0.0)  // Yellow - same for both
  }

  var action: Color {
    Color(red: 1.0, green: 0.25, blue: 0.25)  // Red - same for both
  }

  var sky: Color {
    Color(red: 0.45, green: 0.85, blue: 1.0)  // Blue - same for both
  }

  // Secondary colors for dark mode contrast
  var textPrimary: Color {
    scheme == .dark ? .white : .black
  }

  var textSecondary: Color {
    scheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7)
  }

  var divider: Color {
    scheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
  }

  static let thickness: CGFloat = 3.5
  static let shadowOffset: CGFloat = 8.0
}

// MARK: - Environment Key for Colors
struct RanColorsKey: EnvironmentKey {
  static let defaultValue = RanColors(scheme: .light)
}

extension EnvironmentValues {
  var ranColors: RanColors {
    get { self[RanColorsKey.self] }
    set { self[RanColorsKey.self] = newValue }
  }
}

// MARK: - Haptic Manager
#if os(iOS)
  import UIKit
#endif

class HapticManager {
  static let shared = HapticManager()

  private init() {}

  /// Trigger a light impact (for standard button taps)
  func triggerLight() {
    #if os(iOS)
      let generator = UIImpactFeedbackGenerator(style: .light)
      generator.prepare()
      generator.impactOccurred()
    #endif
  }

  /// Trigger a medium impact (for section selections)
  func triggerMedium() {
    #if os(iOS)
      let generator = UIImpactFeedbackGenerator(style: .medium)
      generator.prepare()
      generator.impactOccurred()
    #endif
  }

  /// Trigger a heavy impact (for main actions like finishing a run)
  func triggerHeavy() {
    #if os(iOS)
      let generator = UIImpactFeedbackGenerator(style: .heavy)
      generator.prepare()
      generator.impactOccurred()
    #endif
  }

  /// Trigger a success notification (for level ups or saving)
  func triggerSuccess() {
    #if os(iOS)
      let generator = UINotificationFeedbackGenerator()
      generator.prepare()
      generator.notificationOccurred(.success)
    #endif
  }

  /// Trigger an error notification (for validation failures)
  func triggerError() {
    #if os(iOS)
      let generator = UINotificationFeedbackGenerator()
      generator.prepare()
      generator.notificationOccurred(.error)
    #endif
  }

  /// Trigger a select change (for tab switching or scrolls)
  func triggerSelection() {
    #if os(iOS)
      let generator = UISelectionFeedbackGenerator()
      generator.prepare()
      generator.selectionChanged()
    #endif
  }
}
// MARK: - Liquid Glass System (iOS 26 Spec)
struct LiquidGlassEffect: ViewModifier {
  let colors: RanColors
  @State private var t: CGFloat = 0
  @Environment(\.accessibilityReduceMotion) var reduceMotion

  func body(content: Content) -> some View {
    content
      .background {
        ZStack {
          // Liquid Base
          RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(.ultraThinMaterial)

          // Light Refraction / Fluid Movement
          if !reduceMotion {
            LinearGradient(
              colors: [.clear, colors.action.opacity(0.12), .clear],
              startPoint: UnitPoint(x: 0.5 + 0.2 * sin(t), y: 0.5 + 0.2 * cos(t)),
              endPoint: UnitPoint(x: 0.5 - 0.2 * sin(t), y: 0.5 - 0.2 * cos(t))
            )
            .blur(radius: 20)
          }
        }
      }
      .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: 30, style: .continuous)
          .stroke(
            LinearGradient(
              colors: [.white.opacity(0.6), .white.opacity(0.1), .white.opacity(0.3)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 1.5
          )
      )
      .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
      .onAppear {
        if !reduceMotion {
          withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
            t = .pi * 2
          }
        }
      }
  }
}

extension View {
  func glassEffect(colors: RanColors) -> some View {
    self.modifier(LiquidGlassEffect(colors: colors))
  }
}
