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
