import SwiftUI

// MARK: - Main Welcome Flow Container
struct WelcomeFlowView: View {
  let colors: RanColors
  @ObservedObject var firebaseManager: FirebaseManager
  let onComplete: () -> Void

  @State private var currentPage = 0
  @State private var runnerType = ""
  @State private var avatarColor: Color = .red
  @State private var selectedAura = "None"
  @State private var selectedMask = "None"
  @State private var weeklyGoal = 10

  @AppStorage("userAvatarColor") private var userAvatarColorName: String = "red"

  var body: some View {
    ZStack {
      colors.paper.ignoresSafeArea()
      ZineBackground(colors: colors).opacity(0.3)

      TabView(selection: $currentPage) {
        // Page 1: Hero Awakening
        HeroAwakeningPage(colors: colors) {
          withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            currentPage = 1
          }
        }
        .tag(0)

        // Page 2: Running Style
        RunningStylePage(colors: colors, selectedType: $runnerType) {
          withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            currentPage = 2
          }
        }
        .tag(1)

        // Page 3: Character Customization
        CharacterCustomizePage(
          colors: colors,
          avatarColor: $avatarColor,
          selectedAura: $selectedAura,
          selectedMask: $selectedMask
        ) {
          withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            currentPage = 3
          }
        }
        .tag(2)

        // Page 4: Goal Setting
        GoalSettingPage(colors: colors, weeklyGoal: $weeklyGoal) {
          withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            currentPage = 4
          }
        }
        .tag(3)

        // Page 5: Mission Ready
        MissionReadyPage(
          colors: colors,
          runnerType: runnerType,
          avatarColor: avatarColor,
          weeklyGoal: weeklyGoal
        ) {
          Task {
            // Save preferences to Firebase
            await savePreferences()
            onComplete()
          }
        }
        .tag(4)
      }
      #if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .never))
      #else
        .tabViewStyle(.automatic)
      #endif
      .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)

      // Page Indicators
      VStack {
        Spacer()
        HStack(spacing: 8) {
          ForEach(0..<5, id: \.self) { i in
            Circle()
              .fill(i == currentPage ? colors.accent : colors.ink.opacity(0.3))
              .frame(width: 10, height: 10)
          }
        }
        .padding(.bottom, 30)
      }
    }
    .overlay(
      Rectangle()
        .stroke(colors.ink, lineWidth: 10)
        .ignoresSafeArea()
    )
  }

  private func savePreferences() async {
    // Save to AppStorage for immediate UI update
    userAvatarColorName = colorToName(avatarColor)

    do {
      try await firebaseManager.saveUserPreferences(
        runnerType: runnerType,
        avatarColor: colorToName(avatarColor),
        aura: selectedAura,
        mask: selectedMask,
        weeklyGoal: weeklyGoal
      )
      HapticManager.shared.triggerSuccess()
    } catch {
      HapticManager.shared.triggerError()
      print("DEBUG: Failed to save preferences: \(error)")
    }
  }

  private func colorToName(_ color: Color) -> String {
    switch color {
    case .blue: return "blue"
    case .green: return "green"
    case .orange: return "orange"
    case .purple: return "purple"
    case .cyan: return "cyan"
    default: return "red"
    }
  }
}

// MARK: - Page 1: Hero Awakening
struct HeroAwakeningPage: View {
  let colors: RanColors
  let onContinue: () -> Void

  @State private var showTitle = false
  @State private var showSubtitle = false
  @State private var showStamp = false
  @State private var isPulsing = false

  var body: some View {
    VStack(spacing: 30) {
      Spacer()

      ZStack {
        // Speed lines burst
        if showTitle {
          SpeedLines(ink: colors.accent, isRotating: true)
            .opacity(0.3)
        }

        VStack(spacing: 20) {
          Text("A NEW HERO")
            .font(.system(size: 32, weight: .black))
            .foregroundStyle(colors.ink)
            .opacity(showTitle ? 1 : 0)
            .offset(y: showTitle ? 0 : 30)

          Text("HAS JOINED")
            .font(.system(size: 48, weight: .black))
            .italic()
            .foregroundStyle(colors.ink)
            .opacity(showTitle ? 1 : 0)
            .offset(y: showTitle ? 0 : 30)

          Text("THE STREAK CLUB")
            .font(.system(size: 28, weight: .black))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(colors.accent)
            .foregroundStyle(colors.ink)
            .comicPanel(color: colors.accent, ink: colors.ink)
            .opacity(showSubtitle ? 1 : 0)
            .scaleEffect(showSubtitle ? 1 : 0.5)
        }
      }

      if showStamp {
        Text("⚡ HERO DETECTED ⚡")
          .font(.system(size: 20, weight: .black))
          .foregroundStyle(colors.action)
          .padding(15)
          .border(colors.action, width: 4)
          .rotationEffect(.degrees(-5))
          .transition(.scale.combined(with: .opacity))
      }

      Spacer()

      if showStamp {
        Button(action: {
          HapticManager.shared.triggerLight()
          onContinue()
        }) {
          HStack {
            Text("BEGIN ORIGIN STORY")
            Image(systemName: "arrow.right")
          }
          .font(.headline.bold())
          .padding(20)
          .frame(maxWidth: .infinity)
          .background(colors.ink)
          .foregroundStyle(colors.paper)
          .comicPanel(color: colors.ink, ink: colors.ink, x: 4, y: 4)
          .scaleEffect(isPulsing ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 40)
        .transition(.move(edge: .bottom).combined(with: .opacity))
      }

      Spacer().frame(height: 60)
    }
    .onAppear {
      withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
        showTitle = true
      }
      withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.8)) {
        showSubtitle = true
      }
      withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(1.3)) {
        showStamp = true
      }
      withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(1.5)) {
        isPulsing = true
      }
    }
  }
}

// MARK: - Page 2: Running Style Selection
struct RunningStylePage: View {
  let colors: RanColors
  @Binding var selectedType: String
  let onContinue: () -> Void

  let runnerTypes = [
    ("SPEEDSTER", "bolt.fill", "Quick bursts, maximum intensity"),
    ("ENDURANCE", "figure.walk", "Long distances, steady pace"),
    ("CASUAL", "leaf.fill", "Easy runs, enjoy the journey"),
    ("WARRIOR", "flame.fill", "Push limits, conquer goals"),
  ]

  var body: some View {
    VStack(spacing: 25) {
      Spacer().frame(height: 80)

      Text("CHOOSE YOUR PATH")
        .font(.system(size: 14, weight: .black))
        .foregroundStyle(colors.ink.opacity(0.5))

      Text("RUNNER TYPE")
        .font(.system(size: 36, weight: .black))
        .italic()
        .foregroundStyle(colors.ink)

      Spacer()

      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
        ForEach(runnerTypes, id: \.0) { type in
          RunnerTypeCard(
            title: type.0,
            icon: type.1,
            tagline: type.2,
            isSelected: selectedType == type.0,
            colors: colors
          ) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
              selectedType = type.0
            }
          }
        }
      }
      .padding(.horizontal, 20)

      Spacer()

      if !selectedType.isEmpty {
        Button(action: {
          HapticManager.shared.triggerMedium()
          onContinue()
        }) {
          HStack {
            Text("LOCK IN STYLE")
            Image(systemName: "checkmark.seal.fill")
          }
          .font(.headline.bold())
          .padding(20)
          .frame(maxWidth: .infinity)
          .background(colors.accent)
          .foregroundStyle(colors.ink)
          .comicPanel(color: colors.accent, ink: colors.ink, x: 4, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 40)
        .transition(.move(edge: .bottom).combined(with: .opacity))
      }

      Spacer().frame(height: 60)
    }
  }
}

struct RunnerTypeCard: View {
  let title: String
  let icon: String
  let tagline: String
  let isSelected: Bool
  let colors: RanColors
  let onTap: () -> Void

  var body: some View {
    Button(action: {
      HapticManager.shared.triggerLight()
      onTap()
    }) {
      VStack(spacing: 10) {
        Image(systemName: icon)
          .font(.system(size: 36))
          .foregroundStyle(isSelected ? colors.paper : colors.ink)

        Text(title)
          .font(.system(size: 16, weight: .black))
          .foregroundStyle(isSelected ? colors.paper : colors.ink)

        Text(tagline)
          .font(.system(size: 10, weight: .medium))
          .foregroundStyle(isSelected ? colors.paper.opacity(0.8) : colors.ink.opacity(0.6))
          .multilineTextAlignment(.center)
      }
      .padding(20)
      .frame(maxWidth: .infinity)
      .background(isSelected ? colors.action : colors.panel)
      .border(colors.ink, width: isSelected ? 4 : 2)
      .background(colors.ink.offset(x: isSelected ? 6 : 3, y: isSelected ? 6 : 3))
      .scaleEffect(isSelected ? 1.02 : 1.0)
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Page 3: Character Customization
struct CharacterCustomizePage: View {
  let colors: RanColors
  @Binding var avatarColor: Color
  @Binding var selectedAura: String
  @Binding var selectedMask: String
  let onContinue: () -> Void

  let colorOptions: [Color] = [.red, .blue, .green, .orange, .purple, .cyan]
  let auraOptions = ["None", "Speed Lines", "Electric", "Fire"]
  let maskOptions = ["None", "Domino", "Hero", "Tech"]

  @State private var rotation: Double = 0

  var body: some View {
    VStack(spacing: 20) {
      Spacer().frame(height: 80)

      Text("DESIGN YOUR HERO")
        .font(.system(size: 14, weight: .black))
        .foregroundStyle(colors.ink.opacity(0.5))

      Text("CHARACTER LAB")
        .font(.system(size: 36, weight: .black))
        .italic()
        .foregroundStyle(colors.ink)

      // Character Preview
      ZStack {
        if selectedAura == "Speed Lines" {
          SpeedLines(ink: avatarColor, isRotating: true).opacity(0.4)
        } else if selectedAura == "Electric" {
          AuraEffect(color: colors.sky)
        } else if selectedAura == "Fire" {
          AuraEffect(color: .orange)
        }

        ZStack {
          Circle()
            .fill(avatarColor)
            .frame(width: 120, height: 120)
            .border(colors.ink, width: 4)
            .shadow(color: avatarColor.opacity(0.5), radius: 15)

          if selectedMask == "Domino" {
            Text("👓").font(.system(size: 50))
          } else if selectedMask == "Hero" {
            Text("🦸").font(.system(size: 50))
          } else if selectedMask == "Tech" {
            Text("🤖").font(.system(size: 50))
          } else {
            Image(systemName: "figure.run")
              .font(.system(size: 50))
              .foregroundStyle(colors.paper)
          }
        }
        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
      }
      .frame(height: 180)

      // Color Selection
      VStack(alignment: .leading, spacing: 10) {
        Text("SUIT COLOR")
          .font(.system(size: 12, weight: .black))
          .foregroundStyle(colors.ink.opacity(0.5))

        HStack(spacing: 12) {
          ForEach(colorOptions, id: \.self) { color in
            Circle()
              .fill(color)
              .frame(width: 44, height: 44)
              .overlay(Circle().stroke(colors.ink, lineWidth: avatarColor == color ? 4 : 0))
              .scaleEffect(avatarColor == color ? 1.1 : 1.0)
              .onTapGesture {
                HapticManager.shared.triggerSelection()
                withAnimation(.spring(response: 0.3)) { avatarColor = color }
              }
          }
        }
      }
      .padding(.horizontal, 30)

      // Aura Selection
      VStack(alignment: .leading, spacing: 10) {
        Text("POWER AURA")
          .font(.system(size: 12, weight: .black))
          .foregroundStyle(colors.ink.opacity(0.5))

        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 10) {
            ForEach(auraOptions, id: \.self) { aura in
              Text(aura)
                .font(.system(size: 12, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(selectedAura == aura ? colors.accent : colors.panel)
                .foregroundStyle(colors.ink)
                .border(colors.ink, width: 2)
                .onTapGesture {
                  HapticManager.shared.triggerSelection()
                  withAnimation(.spring(response: 0.3)) { selectedAura = aura }
                }
            }
          }
        }
      }
      .padding(.horizontal, 30)

      // Mask Selection
      VStack(alignment: .leading, spacing: 10) {
        Text("IDENTITY")
          .font(.system(size: 12, weight: .black))
          .foregroundStyle(colors.ink.opacity(0.5))

        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 10) {
            ForEach(maskOptions, id: \.self) { mask in
              Text(mask)
                .font(.system(size: 12, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(selectedMask == mask ? colors.sky : colors.panel)
                .foregroundStyle(colors.ink)
                .border(colors.ink, width: 2)
                .onTapGesture {
                  HapticManager.shared.triggerSelection()
                  withAnimation(.spring(response: 0.3)) { selectedMask = mask }
                }
            }
          }
        }
      }
      .padding(.horizontal, 30)

      Spacer()

      Button(action: {
        HapticManager.shared.triggerMedium()
        onContinue()
      }) {
        HStack {
          Text("EQUIP GEAR")
          Image(systemName: "arrow.right")
        }
        .font(.headline.bold())
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(colors.sky)
        .foregroundStyle(colors.ink)
        .comicPanel(color: colors.sky, ink: colors.ink, x: 4, y: 4)
      }
      .buttonStyle(.plain)
      .padding(.horizontal, 40)

      Spacer().frame(height: 60)
    }
    .onAppear {
      withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
        rotation = 360
      }
    }
  }
}

// MARK: - Page 4: Goal Setting
struct GoalSettingPage: View {
  let colors: RanColors
  @Binding var weeklyGoal: Int
  let onContinue: () -> Void

  let goalOptions = [5, 10, 20, 30, 50]

  var goalMessage: String {
    switch weeklyGoal {
    case 5: return "A solid start! Every step counts."
    case 10: return "Committed runner! You've got this."
    case 20: return "Serious dedication! Impressive."
    case 30: return "Elite mindset! Respect."
    case 50: return "LEGENDARY! You're built different."
    default: return "Set your weekly target!"
    }
  }

  var body: some View {
    VStack(spacing: 25) {
      Spacer().frame(height: 80)

      Text("SET YOUR MISSION")
        .font(.system(size: 14, weight: .black))
        .foregroundStyle(colors.ink.opacity(0.5))

      Text("WEEKLY GOAL")
        .font(.system(size: 36, weight: .black))
        .italic()
        .foregroundStyle(colors.ink)

      Spacer()

      // Goal Display
      VStack(spacing: 10) {
        Text("\(weeklyGoal)")
          .font(.system(size: 100, weight: .black, design: .rounded))
          .foregroundStyle(colors.ink)

        Text("KILOMETERS / WEEK")
          .font(.system(size: 16, weight: .black))
          .padding(.horizontal, 20)
          .padding(.vertical, 8)
          .background(colors.accent)
          .foregroundStyle(colors.ink)
      }

      Text(goalMessage)
        .font(.system(size: 14, weight: .bold))
        .foregroundStyle(colors.ink.opacity(0.7))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)

      Spacer()

      // Goal Buttons
      HStack(spacing: 12) {
        ForEach(goalOptions, id: \.self) { goal in
          Button(action: {
            HapticManager.shared.triggerSelection()
            withAnimation(.spring(response: 0.3)) { weeklyGoal = goal }
          }) {
            Text("\(goal)")
              .font(.system(size: 18, weight: .black))
              .frame(width: 55, height: 55)
              .background(weeklyGoal == goal ? colors.action : colors.panel)
              .foregroundStyle(weeklyGoal == goal ? colors.paper : colors.ink)
              .border(colors.ink, width: weeklyGoal == goal ? 4 : 2)
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 20)

      Spacer()

      Button(action: {
        HapticManager.shared.triggerMedium()
        onContinue()
      }) {
        HStack {
          Text("ACCEPT MISSION")
          Image(systemName: "target")
        }
        .font(.headline.bold())
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(colors.accent)
        .foregroundStyle(colors.ink)
        .comicPanel(color: colors.accent, ink: colors.ink, x: 4, y: 4)
      }
      .buttonStyle(.plain)
      .padding(.horizontal, 40)

      Spacer().frame(height: 60)
    }
  }
}

// MARK: - Page 5: Mission Ready
struct MissionReadyPage: View {
  let colors: RanColors
  let runnerType: String
  let avatarColor: Color
  let weeklyGoal: Int
  let onStart: () -> Void

  @State private var showHero = false
  @State private var showText = false
  @State private var showButton = false
  @State private var isPulsing = false

  var body: some View {
    VStack(spacing: 30) {
      Spacer()

      // Hero Reveal
      ZStack {
        if showHero {
          SpeedLines(ink: avatarColor, isRotating: true)
            .opacity(0.4)
        }

        ZStack {
          Circle()
            .fill(avatarColor)
            .frame(width: 160, height: 160)
            .border(colors.ink, width: 6)
            .shadow(color: avatarColor.opacity(0.6), radius: 25)

          Image(systemName: "figure.run")
            .font(.system(size: 70))
            .foregroundStyle(colors.paper)
        }
        .scaleEffect(showHero ? 1 : 0.3)
        .opacity(showHero ? 1 : 0)
      }
      .frame(height: 250)

      if showText {
        VStack(spacing: 15) {
          Text("YOUR MISSION")
            .font(.system(size: 14, weight: .black))
            .foregroundStyle(colors.ink.opacity(0.5))

          Text("BEGINS NOW")
            .font(.system(size: 42, weight: .black))
            .italic()
            .foregroundStyle(colors.ink)

          HStack(spacing: 20) {
            StatPreview(label: "TYPE", value: runnerType, colors: colors)
            StatPreview(label: "GOAL", value: "\(weeklyGoal)km", colors: colors)
          }
          .padding(.top, 10)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
      }

      Spacer()

      if showButton {
        Button(action: {
          HapticManager.shared.triggerHeavy()
          onStart()
        }) {
          HStack {
            Image(systemName: "bolt.fill")
            Text("START RUNNING")
            Image(systemName: "bolt.fill")
          }
          .font(.system(size: 20, weight: .black))
          .padding(25)
          .frame(maxWidth: .infinity)
          .background(colors.action)
          .foregroundStyle(colors.paper)
          .comicPanel(color: colors.action, ink: colors.ink, x: 6, y: 6)
          .scaleEffect(isPulsing ? 1.03 : 1.0)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 30)
        .transition(.scale.combined(with: .opacity))
      }

      Spacer().frame(height: 60)
    }
    .onAppear {
      withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
        showHero = true
      }
      withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.7)) {
        showText = true
      }
      withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(1.2)) {
        showButton = true
      }
      withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(1.5)) {
        isPulsing = true
      }
    }
  }
}

struct StatPreview: View {
  let label: String
  let value: String
  let colors: RanColors

  var body: some View {
    VStack(spacing: 4) {
      Text(label)
        .font(.system(size: 10, weight: .bold))
        .foregroundStyle(colors.ink.opacity(0.5))
      Text(value)
        .font(.system(size: 16, weight: .black))
        .foregroundStyle(colors.ink)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .background(colors.panel)
    .border(colors.ink, width: 2)
  }
}
