import SwiftUI

struct RanColors {
  @Environment(\.colorScheme) var scheme

  var ink: Color { scheme == .dark ? .white : .black }
  var paper: Color {
    scheme == .dark ? Color(white: 0.1) : Color(red: 0.98, green: 0.97, blue: 0.92)
  }
  var panel: Color { scheme == .dark ? Color(white: 0.15) : .white }
  var accent: Color { Color(red: 1.0, green: 0.85, blue: 0.0) }
  var action: Color { Color(red: 1.0, green: 0.25, blue: 0.25) }
  var sky: Color { Color(red: 0.45, green: 0.85, blue: 1.0) }

  static let thickness: CGFloat = 3.5
  static let shadowOffset: CGFloat = 8.0
}
