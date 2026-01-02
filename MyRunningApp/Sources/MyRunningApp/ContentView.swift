import SwiftUI

@main
@available(iOS 17.0, *)
struct RanApp: App {
  var body: some Scene {
    WindowGroup {
      RanContentView()
    }
    #if os(macOS)
      .windowStyle(.hiddenTitleBar)
    #endif
  }
}
