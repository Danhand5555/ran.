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

  @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
  @StateObject private var firebaseManager = FirebaseManager.shared
  @StateObject private var healthManager = HealthManager()

  var body: some View {
    let colors = RanColors(scheme: colorScheme)

    if !firebaseManager.isAuthenticated {
      AuthenticationView(colors: colors, firebaseManager: firebaseManager)
        .transition(
          .asymmetric(
            insertion: .scale(scale: 1.1).combined(with: .opacity),
            removal: .scale(scale: 0.8).combined(with: .opacity)
          ))
    } else if !hasCompletedOnboarding {
      WelcomeFlowView(colors: colors, firebaseManager: firebaseManager) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
          hasCompletedOnboarding = true
        }
      }
      .transition(
        .asymmetric(
          insertion: .move(edge: .trailing).combined(with: .opacity),
          removal: .scale(scale: 0.9).combined(with: .move(edge: .leading))
        ))
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
            #if os(iOS)
              .tabViewStyle(.page(indexDisplayMode: .never))
            #else
              .tabViewStyle(.automatic)
            #endif
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: selectedTab) { oldValue, newValue in
              HapticManager.shared.triggerSelection()
            }

            // For iOS <26, show comic tab bar inline
            if #unavailable(iOS 26.0) {
              Spacer(minLength: 10)
              RanNavBar(selected: $selectedTab, colors: colors)
                .padding(.horizontal, 20)
              Color.clear.frame(height: geo.safeAreaInsets.bottom + 15)
            }
          }
          .blur(radius: isRunning || showSuccessSplash || showMap || showCharacterLab ? 20 : 0)
          .scaleEffect(isRunning || showSuccessSplash || showMap || showCharacterLab ? 0.9 : 1.0)

          // For iOS 26+, float Liquid Glass tab bar over content
          if #available(iOS 26.0, *) {
            VStack {
              Spacer()
              RanNavBar(selected: $selectedTab, colors: colors)
                .padding(.bottom, geo.safeAreaInsets.bottom + 10)
            }
            .blur(radius: isRunning || showSuccessSplash || showMap || showCharacterLab ? 20 : 0)
          }

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
            MissionCompleteSplash(
              colors: colors,
              distance: lastRunDistance,
              heroName: firebaseManager.currentUser?.displayName?.uppercased() ?? "UNKNOWN AGENT",
              streakDays: 0  // TODO: Get from HealthManager or Firebase
            ) {
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
  @AppStorage("userAvatarColor") private var userAvatarColorName: String = "red"

  private var avatarColor: Color {
    switch userAvatarColorName {
    case "blue": return .blue
    case "green": return .green
    case "orange": return .orange
    case "purple": return .purple
    case "cyan": return .cyan
    default: return .red
    }
  }

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
      Button(action: {
        HapticManager.shared.triggerLight()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { selectedTab = 3 }
      }) {
        ZStack {
          Circle().fill(avatarColor).frame(width: 70, height: 70).comicPanel(
            color: avatarColor, ink: colors.ink, x: 4, y: 4)
          Image(systemName: "figure.run").font(.title).foregroundStyle(colors.paper)
        }
      }.buttonStyle(.plain)
    }
  }
}

struct RanNavBar: View {
  @Binding var selected: Int
  let colors: RanColors

  var body: some View {
    if #available(iOS 26.0, macOS 26.0, *) {
      RanLiquidNavBar(selected: $selected, colors: colors)
    } else {
      // Comic style for older iOS
      RanComicNavBar(selected: $selected, colors: colors)
    }
  }
}

// MARK: - iOS 26 Liquid Glass Tab Bar
@available(iOS 26.0, macOS 26.0, *)
struct RanLiquidNavBar: View {
  @Binding var selected: Int
  let colors: RanColors

  @Namespace private var nspace

  private let tabs = [0, 1, 2]
  private let icons = ["figure.run", "star.fill", "person.3.fill"]
  private let titles = ["RUN", "TROPHIES", "SQUAD"]

  var body: some View {
    ZStack {
      // Layer 1: The Liquid Glass Background
      GlassEffectContainer {
        HStack(spacing: 0) {
          ForEach(tabs, id: \.self) { index in
            // Invisible structures just for the glass system to track
            Capsule()
              .fill(.clear)
              .frame(height: 50)  // Match approximate content height
              .overlay {
                if selected == index {
                  Capsule()
                    .glassEffect(.clear)
                    .matchedGeometryEffect(id: "tab", in: nspace)
                    .glassEffectID("tab_\(index)", in: nspace)
                } else {
                  Capsule().fill(.clear)
                    .glassEffectID("tab_\(index)", in: nspace)
                }
              }
              .frame(maxWidth: .infinity)
          }
        }
        .padding(4)
        .background(backgroundCapsule)
      }

      // Layer 2: The Interactive Content (Text/Icons) on TOP
      HStack(spacing: 0) {
        ForEach(tabs, id: \.self) { index in
          Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
              selected = index
            }
            HapticManager.shared.triggerSelection()
          }) {
            VStack(spacing: 4) {
              Image(systemName: icons[index])
                .font(.system(size: 24, weight: .medium))
                .frame(width: 28, height: 28)
              Text(titles[index])
                .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(selected == index ? colors.action : Color.gray)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())  // Ensure tap target covers the whole area
          }
          .buttonStyle(.plain)
        }
      }
      .padding(4)
    }
    .padding(.horizontal, 20)
  }

  private var backgroundCapsule: some View {
    Capsule()
      .glassEffect(.regular.interactive())
  }
}

// MARK: - Comic Style Tab Bar (iOS <26 Fallback)
struct RanComicNavBar: View {
  @Binding var selected: Int
  let colors: RanColors

  private let tabs = [0, 1, 2]
  private let icons = ["figure.run", "star.fill", "person.3.fill"]
  private let titles = ["RUN", "TROPHIES", "SQUAD"]

  var body: some View {
    HStack(spacing: 0) {
      ForEach(tabs, id: \.self) { index in
        Button(action: {
          withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selected = index
          }
          HapticManager.shared.triggerSelection()
        }) {
          VStack(spacing: 2) {
            Image(systemName: icons[index])
              .font(.system(size: 22, weight: .bold))
              .frame(width: 28, height: 28)
            Text(titles[index])
              .font(.system(size: 10, weight: .black))
          }
          .foregroundStyle(selected == index ? colors.action : colors.ink)
          .scaleEffect(selected == index ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
      }
    }
    .padding(.horizontal, 40)
    .padding(.vertical, 12)
    .background(colors.panel)
    .border(colors.ink, width: RanColors.thickness)
    .background(colors.ink.offset(x: 5, y: 5))
    .padding(.horizontal, 20)
  }
}
