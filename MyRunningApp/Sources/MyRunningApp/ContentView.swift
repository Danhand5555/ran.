import SwiftUI

@main
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
