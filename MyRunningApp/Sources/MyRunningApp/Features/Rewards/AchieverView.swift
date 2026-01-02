import SwiftUI

struct AchieverTab: View {
  let colors: RanColors
  @State private var selectedTrophy: TrophyData?

  // Mock Data for the Trophy Room
  let mainMissions = [
    TrophyData(
      icon: "bolt.fill", title: "SPEEDSTER", desc: "Clocked a sub-5' KM pace", rarity: .gold),
    TrophyData(
      icon: "flame.fill", title: "ON FIRE", desc: "Maintained a 14-day streak", rarity: .gold),
  ]

  let sideQuests = [
    TrophyData(
      icon: "map.fill", title: "EXPLORER", desc: "Charted 10 unique routes", rarity: .silver),
    TrophyData(
      icon: "cloud.rain.fill", title: "STORM RUNNER", desc: "Finished a mission in the rain",
      rarity: .silver),
    TrophyData(
      icon: "building.2.fill", title: "CITY PROTECTOR", desc: "Visited a Bangkok landmark",
      rarity: .silver),
    TrophyData(
      icon: "moon.stars.fill", title: "NIGHT OWL", desc: "3 missions after 10 PM", rarity: .silver),
    TrophyData(
      icon: "sun.max.fill", title: "EARLY BIRD", desc: "First run before 6 AM", rarity: .bronze),
    TrophyData(
      icon: "figure.socialdance", title: "PARTY RUN", desc: "Ran with full squad", rarity: .bronze),
  ]

  var body: some View {
    ZStack {
      VStack(alignment: .leading, spacing: 25) {
        // Header with Level Badge
        HStack(alignment: .bottom) {
          VStack(alignment: .leading, spacing: -5) {
            Text("TROPHY ROOM").font(.system(size: 32, weight: .black)).padding(.horizontal, 15)
              .comicPanel(color: colors.accent, ink: colors.ink)
            Text("MEMBER PROGRESS: ISSUE #1").font(.system(size: 10, weight: .bold))
              .foregroundStyle(colors.ink.opacity(0.5)).padding(.leading, 15)
          }
          Spacer()
          LevelBadge(level: 42, colors: colors)
        }

        ScrollView {
          VStack(alignment: .leading, spacing: 35) {
            // 1. XP Progress Section
            VStack(alignment: .leading, spacing: 12) {
              Text("LEVEL PROGRESSION").font(.system(size: 14, weight: .black)).foregroundStyle(
                colors.ink.opacity(0.4))
              VStack(alignment: .leading, spacing: 15) {
                HStack {
                  Text("ELITE RUNNER").font(.title3.bold())
                  Spacer()
                  Text("75% DONE").font(.caption.bold()).foregroundStyle(colors.action)
                }
                ZStack(alignment: .leading) {
                  Rectangle().fill(colors.ink.opacity(0.05)).frame(height: 18).border(
                    colors.ink, width: 2)
                  Rectangle().fill(colors.action).frame(width: 280, height: 18).border(
                    colors.ink, width: 2)
                  // Animated Speed Lines on bar
                  HalftoneOverlay(color: Color.white.opacity(0.2)).frame(width: 280, height: 18)
                    .clipped()
                }
                Text("350 / 400 XP to MARATHONER").font(.caption.bold()).foregroundStyle(
                  colors.ink.opacity(0.6))
              }
              .padding(25).background(colors.panel).comicPanel(
                color: colors.panel, ink: colors.ink, x: 6, y: 6)
            }

            // 2. Main Missions (Featured Trophies)
            VStack(alignment: .leading, spacing: 15) {
              Text("LEGENDARY FEATS").font(.system(size: 14, weight: .black)).foregroundStyle(
                colors.ink.opacity(0.4))
              HStack(spacing: 20) {
                ForEach(mainMissions) { trophy in
                  TrophyCard(trophy: trophy, colors: colors)
                    .onTapGesture { withAnimation(.spring()) { selectedTrophy = trophy } }
                }
              }
            }

            // 3. Side Quests (Grid)
            VStack(alignment: .leading, spacing: 15) {
              Text("SIDE QUESTS & BADGES").font(.system(size: 14, weight: .black)).foregroundStyle(
                colors.ink.opacity(0.4))
              LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(sideQuests) { trophy in
                  TrophyCard(trophy: trophy, colors: colors)
                    .onTapGesture { withAnimation(.spring()) { selectedTrophy = trophy } }
                }
              }
            }
          }.padding(.bottom, 100)  // Extra space for floating tab bar
        }
      }.padding(.horizontal, 20)

      // Detail Overlay
      if let trophy = selectedTrophy {
        TrophyDetailView(trophy: trophy, colors: colors) {
          withAnimation(.spring()) { selectedTrophy = nil }
        }
        .transition(.scale.combined(with: .opacity))
        .zIndex(10)
      }
    }
  }
}

// MARK: - Components

struct TrophyData: Identifiable {
  let id = UUID()
  let icon: String
  let title: String
  let desc: String
  let rarity: Rarity

  enum Rarity {
    case gold, silver, bronze
    var color: Color {
      switch self {
      case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
      case .silver: return Color(red: 0.75, green: 0.75, blue: 0.75)
      case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
      }
    }
  }
}

struct TrophyCard: View {
  let trophy: TrophyData
  let colors: RanColors

  var body: some View {
    VStack(spacing: 12) {
      ZStack {
        Circle().fill(trophy.rarity.color.opacity(0.2)).frame(width: 60, height: 60)
        Image(systemName: trophy.icon).font(.title).foregroundStyle(trophy.rarity.color)
      }
      .padding(10)
      .background(colors.ink.opacity(0.05))
      .border(colors.ink, width: 2)

      VStack(spacing: 4) {
        Text(trophy.title).font(.system(size: 12, weight: .black)).multilineTextAlignment(.center)
        Text(trophy.rarity == .gold ? "LEGENDARY" : (trophy.rarity == .silver ? "RARE" : "COMMON"))
          .font(.system(size: 8, weight: .black)).padding(.horizontal, 6).padding(.vertical, 2)
          .background(trophy.rarity.color).foregroundStyle(.white)
      }
    }
    .padding(15)
    .frame(maxWidth: .infinity, minHeight: 140)
    .background(colors.panel)
    .border(colors.ink, width: 3)
    .background(colors.ink.offset(x: 4, y: 4))
  }
}

struct LevelBadge: View {
  let level: Int
  let colors: RanColors
  var body: some View {
    ZStack {
      Rectangle().fill(colors.action).frame(width: 50, height: 50).rotationEffect(.degrees(45))
        .border(colors.ink, width: 3)
      VStack(spacing: -2) {
        Text("LVL").font(.system(size: 8, weight: .black))
        Text("\(level)").font(.system(size: 20, weight: .black))
      }.foregroundStyle(.white)
    }
  }
}

struct TrophyDetailView: View {
  let trophy: TrophyData
  let colors: RanColors
  let onDismiss: () -> Void

  var body: some View {
    ZStack {
      Color.black.opacity(0.85).ignoresSafeArea().onTapGesture(perform: onDismiss)

      VStack(spacing: 30) {
        // The "Achievement Poster"
        VStack(spacing: 0) {
          HStack {
            Text("AWARDED: JAN 2026").font(.system(size: 10, weight: .black))
            Spacer()
            Text("RAN.").font(.system(size: 14, weight: .black)).italic()
          }
          .padding(15).background(trophy.rarity.color).foregroundStyle(.white)

          ZStack {
            colors.paper.frame(height: 300)
            SpeedLines(ink: .black, isRotating: true).opacity(0.15)

            VStack(spacing: 20) {
              Image(systemName: trophy.icon).font(.system(size: 80)).foregroundStyle(
                trophy.rarity.color
              )
              .shadow(color: .black.opacity(0.2), radius: 0, x: 5, y: 5)

              Text(trophy.title).font(.system(size: 40, weight: .black)).italic()
                .foregroundStyle(colors.ink)

              Text(trophy.desc).font(.headline.bold()).multilineTextAlignment(.center)
                .padding(.horizontal, 30).foregroundStyle(colors.ink.opacity(0.7))
            }

            // Action Stickers
            Text("BOOM!").font(.system(size: 20, weight: .black)).padding(8).background(
              colors.action
            )
            .foregroundStyle(.white).border(.black, width: 3).rotationEffect(.degrees(-15)).offset(
              x: -120, y: -80)
          }
          .border(.black, width: 4)

          Text("UNLOCKED BY DANN THE FLASH").font(.system(size: 12, weight: .black))
            .padding(15).frame(maxWidth: .infinity).background(.black).foregroundStyle(.white)
        }
        .frame(width: 340).comicPanel(color: colors.paper, ink: .black, x: 12, y: 12)

        Button(action: onDismiss) {
          Text("BACK TO GALLERY").font(.headline.bold()).padding(.horizontal, 30).padding(
            .vertical, 15
          )
          .background(colors.sky).comicPanel(color: colors.sky, ink: .black, x: 5, y: 5)
        }.buttonStyle(.plain)
      }
    }
  }
}
