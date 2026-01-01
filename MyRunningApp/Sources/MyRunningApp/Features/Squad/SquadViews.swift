import SwiftUI

struct SquadTab: View {
  let colors: RanColors
  @Binding var showMap: Bool
  @State private var showInviteSuccess = false

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 25) {
        // Header
        HStack {
          Text("THE SQUAD").font(.system(size: 32, weight: .black)).padding(.horizontal, 15)
            .comicPanel(color: colors.sky, ink: colors.ink)
          Spacer()
          Button(action: { withAnimation { showMap = true } }) {
            HStack {
              Image(systemName: "map.fill")
              Text("RADAR")
            }.font(.headline.bold()).padding(10).background(colors.accent).comicPanel(
              color: colors.accent, ink: colors.ink, x: 4, y: 4)
          }.buttonStyle(.plain)
        }

        // Recruit Section
        VStack(alignment: .leading, spacing: 15) {
          HStack {
            VStack(alignment: .leading, spacing: 2) {
              Text("RECRUIT NEW HEROES").font(.system(size: 16, weight: .black))
              Text("Expand the streak club").font(.system(size: 10, weight: .bold)).foregroundStyle(
                colors.ink.opacity(0.5))
            }
            Spacer()
            Button(action: copyInvite) {
              HStack {
                Image(systemName: showInviteSuccess ? "checkmark" : "plus.square.fill")
                Text(showInviteSuccess ? "COPIED!" : "JOIN LINK")
              }.font(.caption.bold()).padding(8).background(
                showInviteSuccess ? colors.sky : colors.action
              ).foregroundStyle(.white).border(colors.ink, width: 2)
            }.buttonStyle(.plain)
          }
        }
        .padding(20).background(colors.panel).comicPanel(
          color: colors.panel, ink: colors.ink, x: 6, y: 6)

        // Active Squad Mission Card
        VStack(alignment: .leading, spacing: 15) {
          HStack {
            Image(systemName: "person.3.sequence.fill").font(.title2)
            Text("ACTIVE SQUAD MISSION").font(.system(size: 16, weight: .black))
            Spacer()
            Text("LVL 3").font(.caption.bold()).padding(5).background(colors.ink).foregroundStyle(
              colors.accent)
          }.foregroundStyle(colors.ink)
          Text("COLLECT 100KM AS A TEAM").font(.system(size: 14, weight: .black)).italic()
          VStack(spacing: 5) {
            HStack {
              Text("72.5 KM / 100 KM").font(.caption.bold())
              Spacer()
              Text("72%").font(.caption.bold())
            }
            ZStack(alignment: .leading) {
              Rectangle().fill(colors.ink.opacity(0.1)).frame(height: 12).border(
                colors.ink, width: 2)
              Rectangle().fill(colors.action).frame(width: 250, height: 12).border(
                colors.ink, width: 2)
            }
          }
        }.padding(20).background(colors.paper).comicPanel(
          color: colors.paper, ink: colors.ink, x: 6, y: 6)

        // Direct Streaks
        VStack(spacing: 25) {
          HStack {
            Text("DIRECT DUELS").font(.system(size: 14, weight: .black)).foregroundStyle(
              colors.ink.opacity(0.6))
            Spacer()
            Text("TAP TO NUDGE").font(.system(size: 10, weight: .black)).foregroundStyle(
              colors.action
            ).italic()
          }

          VStack(spacing: 18) {
            DuelMemberCard(
              name: "IRON LEG", streak: 21, color: .orange, colors: colors, myDone: true,
              theirDone: true)
            DuelMemberCard(
              name: "SPEEDCAT", streak: 14, color: .yellow, colors: colors, myDone: true,
              theirDone: false)
            DuelMemberCard(
              name: "THE SLOTH", streak: 2, color: .gray, colors: colors, myDone: false,
              theirDone: false)
          }
        }

        // Interaction Feed
        VStack(alignment: .leading, spacing: 10) {
          Text("ACTIVITY FEED").font(.system(size: 12, weight: .black)).foregroundStyle(
            colors.ink.opacity(0.4))
          HStack {
            Image(systemName: "quote.bubble.fill").foregroundStyle(colors.sky)
            Text("**IRON LEG** sent a **BOOM!** to the squad").font(
              .system(size: 12, weight: .bold))
          }.padding(12).background(colors.panel).border(colors.ink, width: 2)
        }

      }.padding(.horizontal, 30).padding(.bottom, 20)
    }
  }

  func copyInvite() {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString("JOIN MY RAN SQUAD: ISSUE-#14-HQ", forType: .string)
    withAnimation { showInviteSuccess = true }
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      withAnimation { showInviteSuccess = false }
    }
  }
}

// MARK: - Duel Card and other components remain the same...

struct DuelMemberCard: View {
  let name: String
  let streak: Int
  let color: Color
  let colors: RanColors
  let myDone: Bool
  let theirDone: Bool
  @State private var isPulsing = false
  @State private var showNudgeMessage = false
  var body: some View {
    Button(action: {
      if !theirDone {
        withAnimation { showNudgeMessage = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          withAnimation { showNudgeMessage = false }
        }
      }
    }) {
      ZStack(alignment: .topTrailing) {
        VStack(spacing: 0) {
          HStack(spacing: 20) {
            ZStack {
              Rectangle().fill(color).frame(width: 70, height: 70).border(colors.ink, width: 4)
              Image(systemName: "person.fill").font(.title).foregroundStyle(colors.ink)
              if myDone && !theirDone {
                Image(systemName: "hourglass").font(.caption.bold()).padding(4).background(
                  colors.accent
                ).border(colors.ink, width: 2).offset(x: 35, y: -35)
              }
            }.offset(x: -4, y: -4).background(colors.ink.frame(width: 70, height: 70))
            VStack(alignment: .leading, spacing: 8) {
              Text(name).font(.system(size: 22, weight: .black)).foregroundStyle(colors.ink)
              HStack(spacing: 4) {
                DuelSegment(label: "YOU", active: myDone, color: colors.action, colors: colors)
                DuelSegment(label: name, active: theirDone, color: colors.sky, colors: colors)
              }
            }
            Spacer()
            VStack(spacing: -5) {
              Text("\(streak)").font(.system(size: 32, weight: .black, design: .rounded))
              Image(systemName: (myDone && theirDone) ? "flame.fill" : "flame").font(
                .system(size: 20)
              ).foregroundStyle((myDone && theirDone) ? .orange : Color.gray.opacity(0.3))
            }.padding(10).frame(width: 65, height: 75).background(
              (myDone && theirDone) ? colors.accent.opacity(0.15) : colors.panel
            ).border(colors.ink, width: 3).scaleEffect(
              (myDone && theirDone && isPulsing) ? 1.1 : 1.0)
          }.padding(15).background(colors.panel).border(colors.ink, width: 4).background(
            colors.ink.offset(x: 6, y: 6))
        }
        if showNudgeMessage {
          Text("NUDGE SENT!").font(.system(size: 12, weight: .black)).padding(8).background(
            colors.action
          ).foregroundStyle(.white).border(colors.ink, width: 3).rotationEffect(.degrees(10))
            .offset(x: -10, y: -20).transition(.scale.combined(with: .move(edge: .top)))
        }
      }
    }.buttonStyle(.plain).onAppear {
      if myDone && theirDone {
        withAnimation(.easeInOut(duration: 0.8).repeatForever()) { isPulsing = true }
      }
    }
  }
}

struct DuelSegment: View {
  let label: String
  let active: Bool
  let color: Color
  let colors: RanColors
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Rectangle().fill(active ? color : colors.ink.opacity(0.1)).frame(height: 8).border(
        colors.ink, width: 2)
      Text(label.prefix(4)).font(.system(size: 8, weight: .black)).foregroundStyle(
        colors.ink.opacity(0.5))
    }.frame(width: 60)
  }
}

struct SquadMapView: View {
  let colors: RanColors
  let onDismiss: () -> Void
  var body: some View {
    ZStack {
      colors.paper.ignoresSafeArea()
      Canvas { context, size in
        let step: CGFloat = 50
        for x in stride(from: 0, to: size.width, by: step) {
          var p = Path()
          p.move(to: CGPoint(x: x, y: 0))
          p.addLine(to: CGPoint(x: x, y: size.height))
          context.stroke(p, with: .color(colors.ink.opacity(0.1)), lineWidth: 1)
        }
        for y in stride(from: 0, to: size.height, by: step) {
          var p = Path()
          p.move(to: CGPoint(x: 0, y: y))
          p.addLine(to: CGPoint(x: size.width, y: y))
          context.stroke(p, with: .color(colors.ink.opacity(0.1)), lineWidth: 1)
        }
      }.ignoresSafeArea()
      VStack {
        HStack {
          Text("SQUAD RADAR").font(.system(size: 24, weight: .black)).padding(10).background(
            colors.accent
          ).border(colors.ink, width: 3)
          Spacer()
          Button(action: onDismiss) {
            Image(systemName: "xmark").padding().background(colors.panel).border(
              colors.ink, width: 3)
          }.buttonStyle(.plain)
        }.padding(.top, 50).padding(.horizontal, 30)
        Spacer()
        ZStack {
          MapFriendPin(
            name: "IRON LEG", offset: CGPoint(x: -80, y: -150), colors: colors, status: "RUNNING🏃",
            active: true)
          MapFriendPin(
            name: "SPEEDCAT", offset: CGPoint(x: 100, y: 50), colors: colors, status: "AT GYM",
            active: false)
          MapFriendPin(
            name: "YOU", offset: CGPoint(x: 0, y: -30), colors: colors, status: "RESTING",
            active: false, isUser: true)
          MissionTargetPin(offset: CGPoint(x: -120, y: 80), colors: colors)
        }
        Spacer()
      }
    }
  }
}

struct MissionTargetPin: View {
  let offset: CGPoint
  let colors: RanColors
  @State private var pulse = false
  var body: some View {
    VStack {
      ZStack {
        Circle().fill(colors.action.opacity(0.2)).frame(width: 80, height: 80).scaleEffect(
          pulse ? 1.2 : 1.0)
        Image(systemName: "target").font(.title).foregroundStyle(colors.action)
      }
      Text("BONUS KM ZONE").font(.system(size: 8, weight: .black)).padding(4).background(
        colors.action
      ).foregroundStyle(.white)
    }.offset(x: offset.x, y: offset.y).onAppear {
      withAnimation(.easeInOut(duration: 1).repeatForever()) { pulse = true }
    }
  }
}

struct MapFriendPin: View {
  let name: String
  let offset: CGPoint
  let colors: RanColors
  let status: String
  let active: Bool
  var isUser: Bool = false
  @State private var bounce = false
  var body: some View {
    VStack(spacing: 5) {
      if active {
        Text("POW!").font(.system(size: 10, weight: .black)).padding(4).background(colors.action)
          .foregroundStyle(.white).offset(y: bounce ? -5 : 0)
      }
      ZStack {
        Rectangle().fill(isUser ? colors.accent : (active ? colors.sky : colors.panel)).frame(
          width: 50, height: 50
        ).border(colors.ink, width: 3)
        Image(systemName: isUser ? "figure.run" : "person.fill").foregroundStyle(colors.ink)
      }.offset(x: -3, y: -3).background(colors.ink.frame(width: 50, height: 50))
      Text(name).font(.system(size: 10, weight: .black)).padding(.horizontal, 4).background(
        colors.ink
      ).foregroundStyle(.white)
      Text(status).font(.system(size: 8, weight: .bold)).foregroundStyle(colors.ink.opacity(0.7))
    }.offset(x: offset.x, y: offset.y).onAppear {
      if active { withAnimation(.easeInOut(duration: 0.6).repeatForever()) { bounce = true } }
    }
  }
}
