import SwiftUI

struct AuthenticationView: View {
  let colors: RanColors
  @ObservedObject var firebaseManager: FirebaseManager

  @State private var isSignUp = false
  @State private var email = ""
  @State private var password = ""
  @State private var name = ""
  @State private var isLoading = false
  @State private var errorMessage: String?

  @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

  var body: some View {
    ZStack {
      colors.paper.ignoresSafeArea()
      ZineBackground(colors: colors).opacity(0.3)

      VStack(spacing: 30) {
        Spacer()

        // Header
        VStack(spacing: 10) {
          Text("ran.")
            .font(.system(size: 80, weight: .black, design: .rounded))
            .italic()
            .foregroundStyle(colors.ink)
            .shadow(color: colors.accent, radius: 0, x: 4, y: 4)

          Text(isSignUp ? "CREATE ACCOUNT" : "SIGN IN")
            .font(.system(size: 24, weight: .black))
            .foregroundStyle(colors.ink)
            .padding(10)
            .background(colors.accent)
            .comicPanel(color: colors.accent, ink: colors.ink)
        }

        Spacer()

        // Form
        VStack(spacing: 20) {
          if isSignUp {
            AuthTextField(
              text: $name,
              placeholder: "CODENAME",
              icon: "person.fill",
              colors: colors
            )
          }

          AuthTextField(
            text: $email,
            placeholder: "EMAIL",
            icon: "envelope.fill",
            colors: colors
          )

          AuthTextField(
            text: $password,
            placeholder: "PASSWORD",
            icon: "lock.fill",
            colors: colors,
            isSecure: true
          )
        }
        .padding(.horizontal, 40)

        // Error Message
        if let errorMessage = errorMessage {
          Text(errorMessage)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(colors.action)
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(colors.action.opacity(0.1))
            .border(colors.action, width: 2)
            .padding(.horizontal, 40)
        }

        Spacer()

        // Action Button
        Button(action: handleAuth) {
          HStack {
            if isLoading {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: colors.paper))
            } else {
              Image(systemName: isSignUp ? "person.badge.plus" : "arrow.right.circle.fill")
              Text(isSignUp ? "CREATE ACCOUNT" : "SIGN IN")
            }
          }
          .font(.headline.bold())
          .padding(20)
          .frame(maxWidth: .infinity)
          .background(isLoading ? colors.ink.opacity(0.5) : colors.ink)
          .foregroundStyle(colors.paper)
          .comicPanel(color: colors.ink, ink: colors.ink, x: 4, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(isLoading || !isFormValid)
        .padding(.horizontal, 40)

        // Toggle Mode
        Button(action: {
          HapticManager.shared.triggerLight()
          withAnimation {
            isSignUp.toggle()
            errorMessage = nil
          }
        }) {
          Text(isSignUp ? "Already have an account? SIGN IN" : "Don't have an account? SIGN UP")
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(colors.ink.opacity(0.7))
        }
        .buttonStyle(.plain)
        .padding(.bottom, 40)
      }
    }
    .overlay(
      Rectangle()
        .stroke(colors.ink, lineWidth: 10)
        .ignoresSafeArea()
    )
  }

  private var isFormValid: Bool {
    if isSignUp {
      return !name.isEmpty && !email.isEmpty && !password.isEmpty && password.count >= 6
    } else {
      return !email.isEmpty && !password.isEmpty
    }
  }

  private func handleAuth() {
    HapticManager.shared.triggerMedium()
    errorMessage = nil
    isLoading = true

    Task {
      do {
        if isSignUp {
          // Reset onboarding flag for new accounts
          await MainActor.run { hasCompletedOnboarding = false }
          try await firebaseManager.signUp(email: email, password: password, name: name)
        } else {
          try await firebaseManager.signIn(email: email, password: password)
        }
        HapticManager.shared.triggerSuccess()
      } catch {
        await MainActor.run {
          HapticManager.shared.triggerError()
          errorMessage = parseError(error)
          isLoading = false
        }
      }
    }
  }

  private func parseError(_ error: Error) -> String {
    let nsError = error as NSError

    // Parse Firebase auth error codes
    if nsError.domain == "FIRAuthErrorDomain" {
      switch nsError.code {
      case 17007: return "EMAIL ALREADY IN USE"
      case 17008: return "INVALID EMAIL FORMAT"
      case 17009: return "WRONG PASSWORD"
      case 17011: return "ACCOUNT NOT FOUND"
      case 17026: return "PASSWORD TOO WEAK (MIN 6 CHARS)"
      default: return "AUTHENTICATION FAILED"
      }
    }

    return error.localizedDescription.uppercased()
  }
}

struct AuthTextField: View {
  @Binding var text: String
  let placeholder: String
  let icon: String
  let colors: RanColors
  var isSecure: Bool = false

  var body: some View {
    HStack(spacing: 15) {
      Image(systemName: icon)
        .font(.system(size: 20))
        .foregroundStyle(colors.ink.opacity(0.5))
        .frame(width: 30)

      if isSecure {
        SecureField(placeholder, text: $text)
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(colors.ink)
      } else {
        TextField(placeholder, text: $text)
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(colors.ink)
      }
    }
    .padding(15)
    .background(colors.panel)
    .border(colors.ink, width: 3)
    .background(colors.ink.offset(x: 4, y: 4))
  }
}
