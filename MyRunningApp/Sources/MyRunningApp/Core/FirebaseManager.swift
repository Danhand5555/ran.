import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation

@MainActor
class FirebaseManager: ObservableObject {
  @Published var currentUser: User?
  @Published var isAuthenticated = false

  // robust db access
  private var db: Firestore {
    Firestore.firestore()
  }

  init() {
    // Only configure if not already configured
    if FirebaseApp.app() == nil {
      // Check if GoogleService-Info.plist exists
      if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
        FirebaseApp.configure()
        print("🔥 Firebase Configured Successfully")
      } else {
        print("⚠️ Warning: GoogleService-Info.plist not found. Firebase will not work.")
      }
    }

    // Listen for auth changes
    _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
      self?.currentUser = user
      self?.isAuthenticated = user != nil
      if let user = user {
        print("✅ User is signed in: \(user.uid)")
      } else {
        print("ℹ️ User is signed out")
      }
    }
  }

  // MARK: - Auth Methods

  func signInAnonymously() async throws {
    let result = try await Auth.auth().signInAnonymously()
    print("Signed in anonymously: \(result.user.uid)")
  }

  func updateProfile(name: String) async throws {
    guard let user = Auth.auth().currentUser else { return }

    let changeRequest = user.createProfileChangeRequest()
    changeRequest.displayName = name
    try await changeRequest.commitChanges()

    // Sync to Firestore
    try await saveUserToFirestore(user: user, name: name)
  }

  // MARK: - Firestore Methods

  func saveUserToFirestore(user: User, name: String) async throws {
    // Initial data schema for a new recruit
    let userData: [String: Any] = [
      "uid": user.uid,
      "displayName": name,
      "lastActive": FieldValue.serverTimestamp(),
      "role": "recruit",
      "stats": [
        "totalDistance": 0.0,
        "totalWorkouts": 0,
        "currentStreak": 0,
      ],
    ]

    try await db.collection("agents").document(user.uid).setData(userData, merge: true)
  }
}
