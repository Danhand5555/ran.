import SwiftUI

struct RanContentView: View {
  @State private var selectedTab = 0
  @State private var isRunning = false
  @State private var showSuccessSplash = false
  @State private var showMap = false
  @State private var showCharacterLab = false
  @State private var lastRunDistance = 0.0

  var body: some View {
    let colors = RanColors()

    ZStack {
      ZineBackground(colors: colors)

      VStack(spacing: 0) {
        BrandingHeader(colors: colors, selectedTab: $selectedTab)
          .padding(.top, 40).padding(.horizontal, 30)

        Spacer(minLength: 20)

        ZStack {
          switch selectedTab {
          case 0:
            RunTab(colors: colors) {
              withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { isRunning = true }
            }
          case 1: SquadTab(colors: colors, showMap: $showMap)
          case 2: AchieverTab(colors: colors)
          case 3:
            ProfileTab(colors: colors) { withAnimation(.spring()) { showCharacterLab = true } }
          default: EmptyView()
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(), value: selectedTab)

        Spacer(minLength: 40)

        RanNavBar(selected: $selectedTab, colors: colors)
          .padding(.bottom, 30).padding(.horizontal, 40)
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
        CharacterLabView(colors: colors) { withAnimation(.spring()) { showCharacterLab = false } }
          .transition(.move(edge: .bottom))
      }
    }
    .frame(minWidth: 500, minHeight: 850)
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
        selected = 0
      }
      Spacer()
      NavTabItem(icon: "star.fill", title: "TROPHIES", active: selected == 2, colors: colors) {
        selected = 2
      }
      Spacer()
      NavTabItem(icon: "person.3.fill", title: "SQUAD", active: selected == 1, colors: colors) {
        selected = 1
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
