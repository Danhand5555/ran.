import SwiftUI

struct OnboardingView: View {
  let colors: RanColors
  @ObservedObject var firebaseManager: FirebaseManager
  let onComplete: () -> Void

  @State private var step = 0
  @State private var name: String = ""
  @State private var showStamp = false
  @State private var isTyping = false

  var body: some View {
    ZStack {
      colors.paper.ignoresSafeArea()

      ZineBackground(colors: colors).opacity(0.3)

      VStack {
        if step == 0 {
          // STEP 1: WELCOME / INTRO
          VStack(spacing: 30) {
            Spacer()

            Text("ran.")
              .font(.system(size: 80, weight: .black, design: .rounded))
              .italic()
              .foregroundStyle(colors.ink)

            VStack(spacing: 10) {
              Text("INITIATING PROTOCOL...")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(colors.ink.opacity(0.6))

              Text("IDENTIFY YOURSELF")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(colors.ink)
                .padding(10)
                .background(colors.accent)
                .comicPanel(color: colors.accent, ink: colors.ink)
            }

            Spacer()

            Button(action: { withAnimation { step = 1 } }) {
              HStack {
                Text("ESTABLISH UPLINK")
                Image(systemName: "arrow.right")
              }
              .font(.headline.bold())
              .padding(20)
              .frame(maxWidth: .infinity)
              .background(colors.ink)
              .foregroundStyle(colors.paper)
              .comicPanel(color: colors.ink, ink: colors.ink, x: 4, y: 4)
            }
            .buttonStyle(.plain)
            .padding(40)
          }
          .transition(.move(edge: .leading))

        } else if step == 1 {
          // STEP 2: ID CARD CREATION
          VStack(spacing: 20) {
            Text("AGENT IDENTITY")
              .font(.system(size: 14, weight: .black))
              .foregroundStyle(colors.ink.opacity(0.5))
              .padding(.top, 40)

            Spacer()

            // ID CARD
            ZStack {
              VStack(alignment: .leading, spacing: 15) {
                HStack {
                  Image(systemName: "person.crop.square.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(colors.ink.opacity(0.2))

                  VStack(alignment: .leading, spacing: 2) {
                    Text("RANK: RECRUIT")
                      .font(.system(size: 10, weight: .bold))
                      .foregroundStyle(colors.accent)
                    Text("ID: #UNKNOWN")
                      .font(.system(size: 10, weight: .bold, design: .monospaced))
                      .foregroundStyle(colors.ink.opacity(0.5))
                  }
                }

                Divider()
                  .background(colors.ink)

                VStack(alignment: .leading, spacing: 5) {
                  Text("CODENAME")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(colors.ink.opacity(0.5))

                  TextField("TAP TO ENTER NAME", text: $name)
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .foregroundStyle(colors.ink)
                    .textInputAutocapitalization(.characters)
                    .disableAutocorrection(true)
                    .onChange(of: name) {
                      if name.count > 12 { name = String(name.prefix(12)) }
                    }
                }

                Spacer()

                HStack {
                  Text("ISSUED: FORTHWITH")
                    .font(.system(size: 8, weight: .bold))
                  Spacer()
                  Image(systemName: "qrcode")
                    .font(.system(size: 24))
                }
                .foregroundStyle(colors.ink.opacity(0.4))
              }
              .padding(20)
              .frame(width: 300, height: 200)
              .background(colors.paper)
              .border(colors.ink, width: 3)
              .background(colors.ink.offset(x: 10, y: 10))

              if showStamp {
                Text("APPROVED")
                  .font(.system(size: 40, weight: .black))
                  .foregroundStyle(colors.action)
                  .padding(10)
                  .border(colors.action, width: 5)
                  .rotationEffect(.degrees(-15))
                  .opacity(0.9)
                  .scaleEffect(1.2)
                  .transition(.scale.combined(with: .opacity))
              }
            }

            Spacer()

            if !name.isEmpty {
              Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                  showStamp = true
                }

                // Sign up anonymously
                Task {
                  try? await firebaseManager.signInAnonymously()
                  try? await firebaseManager.updateProfile(name: name)
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                  onComplete()
                }
              }) {
                Text("CONFIRM IDENTITY")
                  .font(.headline.bold())
                  .padding(20)
                  .frame(maxWidth: .infinity)
                  .background(showStamp ? colors.action : colors.ink)
                  .foregroundStyle(colors.paper)
                  .comicPanel(
                    color: showStamp ? colors.action : colors.ink, ink: colors.ink, x: 4, y: 4)
              }
              .buttonStyle(.plain)
              .padding(40)
              .disabled(showStamp)
              .transition(.move(edge: .bottom).combined(with: .opacity))
            }
          }
          .padding(.bottom, 20)  // For keyboard safety (simple version)
          .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .slide))
        }
      }
    }
    .overlay(
      Rectangle()
        .stroke(colors.ink, lineWidth: 10)
        .ignoresSafeArea()
    )
  }
}
