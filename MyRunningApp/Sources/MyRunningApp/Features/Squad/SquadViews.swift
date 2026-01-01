import MapKit
import SwiftUI

#if os(iOS)
  import UIKit
#endif

// MARK: - Squad Tab
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

      }.padding(.horizontal, 20).padding(.bottom, 20)
    }
  }

  func copyInvite() {
    #if os(macOS)
      NSPasteboard.general.clearContents()
      NSPasteboard.general.setString("JOIN MY RAN SQUAD: ISSUE-#14-HQ", forType: .string)
    #elseif os(iOS)
      UIPasteboard.general.string = "JOIN MY RAN SQUAD: ISSUE-#14-HQ"
    #endif
    withAnimation { showInviteSuccess = true }
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      withAnimation { showInviteSuccess = false }
    }
  }
}

// MARK: - Duel Card
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

// MARK: - Squad Map View (MapKit Integrated)

struct SquadMapView: View {
  let colors: RanColors
  let onDismiss: () -> Void
  @EnvironmentObject var healthManager: HealthManager

  // Default to user location region
  @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)

  var body: some View {
    ZStack {
      // THE MAP
      Map(position: $position) {
        UserAnnotation()

        // Mock Friend 1
        Annotation(
          "Iron Leg", coordinate: CLLocationCoordinate2D(latitude: 13.758, longitude: 100.503)
        ) {
          MapFriendPin(
            name: "IRON LEG", colors: colors, status: "RUNNING 🏃", active: true, isUser: false)
        }

        // Mock Friend 2
        Annotation(
          "Speedcat", coordinate: CLLocationCoordinate2D(latitude: 13.754, longitude: 100.500)
        ) {
          MapFriendPin(
            name: "SPEEDCAT", colors: colors, status: "AT GYM", active: false, isUser: false)
        }

        // Bonus Target
        Annotation(
          "Bonus", coordinate: CLLocationCoordinate2D(latitude: 13.755, longitude: 100.505)
        ) {
          MissionTargetPin(colors: colors)
        }
      }
      .mapControls {
        MapUserLocationButton()
        MapCompass()
      }
      .mapStyle(.standard(elevation: .flat, pointsOfInterest: .all))

      // COMIC OVERLAY
      VStack {
        HStack {
          Text("SQUAD RADAR").font(.system(size: 24, weight: .black)).padding(10).background(
            colors.accent
          ).border(colors.ink, width: 3).comicPanel(color: colors.accent, ink: colors.ink)

          Spacer()

          Button(action: onDismiss) {
            Image(systemName: "xmark").font(.headline.bold()).padding(12).background(colors.panel)
              .border(
                colors.ink, width: 3)
          }.buttonStyle(.plain).comicPanel(color: colors.panel, ink: colors.ink, x: 4, y: 4)
        }.padding(.top, 80).padding(.horizontal, 20)

        Spacer()

        // Legend
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("SCANNING PROTOCOL...").font(.system(size: 10, weight: .bold, design: .monospaced))
              .foregroundStyle(colors.ink)
            HStack(spacing: 4) {
              Circle().fill(.green).frame(width: 8, height: 8)
              Text("ONLINE: 2").font(.caption.bold())
            }
          }.padding(10).background(colors.paper.opacity(0.9)).border(colors.ink, width: 2)
          Spacer()
        }.padding(20)
      }
    }
    .onAppear {
      // Optional: Trigger location update if needed
      Task {
        await healthManager.requestAuthorization()
      }
    }
  }
}

// MARK: - Map Components

struct MissionTargetPin: View {
  let colors: RanColors
  @State private var pulse = false
  var body: some View {
    VStack {
      ZStack {
        Circle().fill(colors.action.opacity(0.4)).frame(width: 60, height: 60).scaleEffect(
          pulse ? 1.2 : 1.0)
        Image(systemName: "target").font(.title).foregroundStyle(colors.action)
      }
      Text("BONUS XP").font(.system(size: 8, weight: .black)).padding(4).background(
        colors.action
      ).foregroundStyle(.white).border(colors.ink, width: 2)
    }.onAppear {
      withAnimation(.easeInOut(duration: 1).repeatForever()) { pulse = true }
    }
  }
}

struct MapFriendPin: View {
  let name: String
  let colors: RanColors
  let status: String
  let active: Bool
  var isUser: Bool = false
  @State private var bounce = false

  var body: some View {
    VStack(spacing: 5) {
      if active {
        Text("POW!").font(.system(size: 8, weight: .black)).padding(4).background(colors.action)
          .foregroundStyle(.white).offset(y: bounce ? -5 : 0).border(colors.ink, width: 2)
      }
      ZStack {
        Rectangle().fill(isUser ? colors.accent : (active ? colors.sky : colors.panel)).frame(
          width: 44, height: 44
        ).border(colors.ink, width: 3)
        Image(systemName: isUser ? "figure.run" : "person.fill").foregroundStyle(colors.ink)
      }.background(colors.ink.offset(x: 3, y: 3))

      VStack(spacing: 0) {
        Text(name).font(.system(size: 10, weight: .black)).padding(.horizontal, 4).background(
          colors.ink
        ).foregroundStyle(.white)
        Text(status).font(.system(size: 8, weight: .bold)).padding(2).background(colors.paper)
          .foregroundStyle(colors.ink)
          .border(colors.ink, width: 1)
      }
    }.onAppear {
      if active { withAnimation(.easeInOut(duration: 0.6).repeatForever()) { bounce = true } }
    }
    .shadow(radius: 4)
  }
}

// Extension to avoid 'Value of type CLLocationCoordinate2D has no member offset' error
extension CLLocationCoordinate2D {
  func offset(lat: Double, long: Double) -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: self.latitude + lat, longitude: self.longitude + long)
  }
}
