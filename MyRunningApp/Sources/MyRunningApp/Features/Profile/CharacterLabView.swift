import SwiftUI

struct CharacterLabView: View {
  let colors: RanColors
  let onDismiss: () -> Void

  @State private var selectedColor: Color = Color.red
  @State private var selectedAura: String = "None"
  @State private var selectedMask: String = "None"
  @State private var rotation: Double = 0

  let auraOptions = ["None", "Speed Lines", "Electric", "Dark Smoke"]
  let maskOptions = ["None", "Domino", "Full Mask", "Headband"]
  let colorOptions: [Color] = [.red, .blue, .green, .orange, .purple, .black]

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      // Blueprint Grid Background
      Canvas { context, size in
        let step: CGFloat = 30
        for x in stride(from: 0, to: size.width, by: step) {
          var p = Path()
          p.move(to: CGPoint(x: x, y: 0))
          p.addLine(to: CGPoint(x: x, y: size.height))
          context.stroke(p, with: .color(colors.sky.opacity(0.2)), lineWidth: 1)
        }
        for y in stride(from: 0, to: size.height, by: step) {
          var p = Path()
          p.move(to: CGPoint(x: 0, y: y))
          p.addLine(to: CGPoint(x: size.width, y: y))
          context.stroke(p, with: .color(colors.sky.opacity(0.2)), lineWidth: 1)
        }
      }.ignoresSafeArea()

      VStack(spacing: 0) {
        // Safe Area Spacer
        Color.clear.frame(height: 80)

        // Header
        HStack {
          VStack(alignment: .leading, spacing: 0) {
            Text("CHARACTER LAB").font(.system(size: 32, weight: .black)).foregroundStyle(
              colors.sky)
            Text("TOP SECRET / ISSUE #1 ORIGINS").font(.system(size: 10, weight: .bold))
              .foregroundStyle(colors.sky.opacity(0.6))
          }
          Spacer()
          Button(action: onDismiss) {
            Image(systemName: "xmark").font(.title2.bold()).padding(12).background(colors.action)
              .foregroundStyle(.white).border(.white, width: 3)
          }.buttonStyle(.plain)
        }
        .padding(.horizontal, 30)  // Reduced top padding since spacer handles it
        .padding(.bottom, 20)

        // Hero Preview Section
        ZStack {
          // Aura Effect
          if selectedAura != "None" {
            Group {
              if selectedAura == "Speed Lines" {
                SpeedLines(ink: colors.sky, isRotating: true).opacity(0.4)
              } else if selectedAura == "Electric" {
                AuraEffect(color: colors.sky)
              } else {
                AuraEffect(color: .gray)
              }
            }
          }

          // The Hero
          VStack {
            ZStack {
              // Main Body
              Circle().fill(selectedColor).frame(width: 160, height: 160)  // Slightly smaller
                .border(.white, width: 6)
                .shadow(color: selectedColor.opacity(0.5), radius: 20)

              // Mask Overlay
              if selectedMask != "None" {
                Text(selectedMask == "Domino" ? "👓" : (selectedMask == "Full Mask" ? "🎭" : "🎗️"))
                  .font(.system(size: 70))
              } else {
                Image(systemName: "figure.run").font(.system(size: 70)).foregroundStyle(.white)
              }
            }
            .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))

            Text("DANN THE FLASH").font(.system(size: 24, weight: .black)).italic().padding(
              .top, 20
            ).foregroundStyle(.white)
          }
        }
        .frame(maxWidth: .infinity).frame(height: 300)  // Reduced height
        .background(colors.ink.opacity(0.5))
        .border(colors.sky, width: 2)
        .padding(.horizontal, 30)

        // Controls
        ScrollView {
          VStack(alignment: .leading, spacing: 25) {
            // Color Selection
            LabSection(title: "SUIT DEPLOYMENT") {
              HStack(spacing: 15) {
                ForEach(colorOptions, id: \.self) { color in
                  Circle().fill(color).frame(width: 40, height: 40)
                    .overlay(Circle().stroke(.white, lineWidth: selectedColor == color ? 4 : 0))
                    .onTapGesture {
                      HapticManager.shared.triggerSelection()
                      withAnimation { selectedColor = color }
                    }
                }
              }
            }

            // Mask Selection
            LabSection(title: "IDENTITY SHIELD") {
              HStack(spacing: 12) {
                ForEach(maskOptions, id: \.self) { mask in
                  Text(mask).font(.caption.bold()).padding(.horizontal, 15).padding(.vertical, 8)
                    .background(selectedMask == mask ? colors.sky : Color.white.opacity(0.1))
                    .foregroundStyle(selectedMask == mask ? .black : .white)
                    .border(.white, width: 2)
                    .onTapGesture {
                      HapticManager.shared.triggerSelection()
                      withAnimation { selectedMask = mask }
                    }
                }
              }
            }

            // Aura Selection
            LabSection(title: "POWER AURA") {
              HStack(spacing: 12) {
                ForEach(auraOptions, id: \.self) { aura in
                  Text(aura).font(.caption.bold()).padding(.horizontal, 15).padding(.vertical, 8)
                    .background(selectedAura == aura ? colors.accent : Color.white.opacity(0.1))
                    .foregroundStyle(selectedAura == aura ? .black : .white)
                    .border(.white, width: 2)
                    .onTapGesture {
                      HapticManager.shared.triggerSelection()
                      withAnimation { selectedAura = aura }
                    }
                }
              }
            }
          }
          .padding(30)
        }

        // Footer Action
        Button(action: {
          HapticManager.shared.triggerMedium()
          onDismiss()
        }) {
          Text("EQUIP HERO GEAR").font(.title3.bold()).padding(.vertical, 20).frame(
            maxWidth: .infinity
          ).background(colors.sky).foregroundStyle(.black).comicPanel(
            color: colors.sky, ink: .white)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 30)
        .padding(.top, 20)
        .padding(.bottom, 60)
      }
      .onAppear {
        withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
          rotation = 360
        }
      }
    }
  }
}

struct LabSection<Content: View>: View {
  let title: String
  let content: Content
  init(title: String, @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title).font(.system(size: 14, weight: .black)).foregroundStyle(Color.white.opacity(0.6))
      content
    }
  }
}

struct AuraEffect: View {
  let color: Color
  @State private var scale: CGFloat = 1.0
  var body: some View {
    Circle().stroke(color, lineWidth: 4).frame(width: 220, height: 220)
      .scaleEffect(scale).opacity(2.0 - Double(scale))
      .onAppear {
        withAnimation(.easeOut(duration: 3.0).repeatForever(autoreverses: false)) {
          scale = 2.0
        }
      }
  }
}
