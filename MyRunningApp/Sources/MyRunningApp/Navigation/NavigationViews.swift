import SwiftUI

@available(iOS 17.0, *)
struct RanContentView: View {
  @State private var selectedTab = 0
  @State private var isRunning = false
  @State private var showSuccessSplash = false
  @State private var showMap = false
  @State private var showCharacterLab = false
  @State private var showRunHistory = false
  @State private var lastRunDistance = 0.0
  @Environment(\.colorScheme) private var colorScheme

  @AppStorage("isFirstLaunch") private var isFirstLaunch = true
  @StateObject private var firebaseManager = FirebaseManager.shared
  @StateObject private var healthManager = HealthManager()

  var body: some View {
    let colors = RanColors(scheme: colorScheme)

    if isFirstLaunch {
      OnboardingView(colors: colors, firebaseManager: firebaseManager) {
        withAnimation { isFirstLaunch = false }
      }
    } else {

      GeometryReader { geo in
        ZStack {
          ZineBackground(colors: colors)

          VStack(spacing: 0) {
            // Top safe area spacer for Dynamic Island/notch
            Color.clear.frame(height: geo.safeAreaInsets.top + 10)

            BrandingHeader(colors: colors, selectedTab: $selectedTab)
              .padding(.horizontal, 20)

            Spacer(minLength: 10)

            // Swipeable Content Area
            TabView(selection: $selectedTab) {
              RunTab(colors: colors) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { isRunning = true }
              }
              .tag(0)

              AchieverTab(colors: colors)
                .tag(1)

              SquadTab(colors: colors, showMap: $showMap)
                .tag(2)

              ProfileTab(
                colors: colors,
                onCustomize: { withAnimation(.spring()) { showCharacterLab = true } },
                onViewLogs: { showRunHistory = true }
              )
              .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer(minLength: 10)

            RanNavBar(selected: $selectedTab, colors: colors)
              .padding(.horizontal, 20)

            // Bottom safe area spacer for home indicator
            Color.clear.frame(height: geo.safeAreaInsets.bottom + 15)
          }
          .blur(radius: isRunning || showSuccessSplash || showMap || showCharacterLab ? 20 : 0)
          .scaleEffect(isRunning || showSuccessSplash || showMap || showCharacterLab ? 0.9 : 1.0)

          if isRunning {
            ActiveRunPage(colors: colors) { finalDist in
              lastRunDistance = finalDist
              withAnimation(.spring()) {
                isRunning = false
                showSuccessSplash = true
              }
            }
            .transition(.move(edge: .bottom))
          }

          if showSuccessSplash {
            MissionCompleteSplash(colors: colors, distance: lastRunDistance) {
              withAnimation(.spring()) { showSuccessSplash = false }
            }
            .transition(.scale.combined(with: .opacity))
          }

          if showMap {
            SquadMapView(colors: colors) { withAnimation(.spring()) { showMap = false } }
              .transition(.move(edge: .bottom))
          }

          if showCharacterLab {
            CharacterLabView(colors: colors) {
              withAnimation(.spring()) { showCharacterLab = false }
            }
            .transition(.move(edge: .bottom))
          }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showRunHistory) {
          RunHistoryView(colors: colors)
            .environmentObject(firebaseManager)
            .environmentObject(healthManager)
        }
      }
      .environmentObject(firebaseManager)
      .environmentObject(healthManager)
      #if os(macOS)
        .frame(minWidth: 500, minHeight: 850)
      #endif
    }
  }
}

struct BrandingHeader: View {
  let colors: RanColors
  @Binding var selectedTab: Int
  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: -5) {
        Text("ran.").font(.system(size: 70, weight: .black, design: .rounded)).italic()
          .foregroundStyle(colors.ink).shadow(color: colors.accent, radius: 0, x: 4, y: 4)
        Text("STREAK CLUB").font(.system(size: 12, weight: .black)).padding(.horizontal, 8).padding(
          .vertical, 4
        ).background(colors.ink).foregroundStyle(colors.paper)
      }
      Spacer()
      Button(action: { withAnimation { selectedTab = 3 } }) {
        ZStack {
          Circle().fill(colors.accent).frame(width: 70, height: 70).comicPanel(
            color: colors.accent, ink: colors.ink, x: 4, y: 4)
          Image(systemName: "person.fill").font(.title).foregroundStyle(colors.ink)
        }
      }.buttonStyle(.plain)
    }
  }
}

struct RanNavBar: View {
  @Binding var selected: Int
  let colors: RanColors
  var body: some View {
    HStack(spacing: 0) {
      NavTabItem(icon: "figure.run", title: "RUN", active: selected == 0, colors: colors) {
        withAnimation { selected = 0 }
      }
      Spacer()
      NavTabItem(icon: "star.fill", title: "TROPHIES", active: selected == 1, colors: colors) {
        withAnimation { selected = 1 }
      }
      Spacer()
      NavTabItem(icon: "person.3.fill", title: "SQUAD", active: selected == 2, colors: colors) {
        withAnimation { selected = 2 }
      }
    }.padding(.horizontal, 40).padding(.vertical, 12).background(colors.panel).border(
      colors.ink, width: RanColors.thickness
    ).background(colors.ink.offset(x: 5, y: 5))
  }
}

struct NavTabItem: View {
  let icon: String
  let title: String
  let active: Bool
  let colors: RanColors
  let action: () -> Void
  var body: some View {
    Button(action: action) {
      VStack(spacing: 2) {
        Image(systemName: icon).font(.system(size: 22, weight: .bold))
        Text(title).font(.system(size: 10, weight: .black))
      }.foregroundStyle(active ? colors.action : colors.ink).scaleEffect(active ? 1.05 : 1.0)
    }.buttonStyle(.plain)
  }
}
