import CoreLocation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation

@MainActor
class FirebaseManager: ObservableObject {
  static let shared = FirebaseManager()
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
      guard let self = self else { return }
      self.currentUser = user
      self.isAuthenticated = user != nil

      if let user = user {
        print("✅ DEBUG: Firebase Auth Success. UID: \(user.uid)")
        // Ensure user has a record in Firestore
        Task {
          try? await self.ensureUserDocumentExists(user: user)
        }
      } else {
        print("❌ DEBUG: No User Logged In.")
      }
    }
  }

  private func ensureUserDocumentExists(user: User) async throws {
    let userRef = db.collection("agents").document(user.uid)
    let snapshot = try? await userRef.getDocument()

    if snapshot?.exists == false {
      print("DEBUG: Provisioning new agent document for \(user.uid)")
      try await saveUserToFirestore(user: user, name: "RECRUIT")
    }
  }

  // MARK: - Auth Methods

  func signInAnonymously() async throws {
    let result = try await Auth.auth().signInAnonymously()
    print("Signed in anonymously: \(result.user.uid)")
  }

  // MARK: - Email/Password Authentication

  func signUp(email: String, password: String, name: String) async throws {
    print("DEBUG: Starting sign up for email: \(email)")
    let result = try await Auth.auth().createUser(withEmail: email, password: password)
    print("DEBUG: User created with UID: \(result.user.uid)")

    // Update display name
    let changeRequest = result.user.createProfileChangeRequest()
    changeRequest.displayName = name
    try await changeRequest.commitChanges()
    print("DEBUG: Display name set to: \(name)")

    // Save to Firestore
    try await saveUserToFirestore(user: result.user, name: name)
    print("DEBUG: User data saved to Firestore")
  }

  func signIn(email: String, password: String) async throws {
    print("DEBUG: Starting sign in for email: \(email)")
    let result = try await Auth.auth().signIn(withEmail: email, password: password)
    print("DEBUG: Successfully signed in with UID: \(result.user.uid)")
  }

  func signOut() throws {
    try Auth.auth().signOut()
    print("DEBUG: User signed out successfully")
  }

  func updateProfile(name: String) async throws {
    guard let user = Auth.auth().currentUser else { return }

    let changeRequest = user.createProfileChangeRequest()
    changeRequest.displayName = name
    try await changeRequest.commitChanges()

    // Sync to Firestore
    try await saveUserToFirestore(user: user, name: name)
  }

  func saveUserPreferences(
    runnerType: String,
    avatarColor: String,
    aura: String,
    mask: String,
    weeklyGoal: Int
  ) async throws {
    guard let user = Auth.auth().currentUser else { return }

    let preferences: [String: Any] = [
      "runnerType": runnerType,
      "avatarColor": avatarColor,
      "aura": aura,
      "mask": mask,
      "weeklyGoal": weeklyGoal,
      "hasCompletedOnboarding": true,
    ]

    try await db.collection("agents").document(user.uid).setData(
      ["preferences": preferences],
      merge: true
    )
    print("DEBUG: User preferences saved successfully")
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

  // MARK: - Run Data Management

  func saveRun(run: RunData) async throws {
    guard let user = Auth.auth().currentUser else {
      print("DEBUG: saveRun - No current user")
      return
    }

    let path = "agents/\(user.uid)/runs"
    print("DEBUG: saveRun - Attempting to save run to path: \(path)")

    let runData: [String: Any] = [
      "date": Timestamp(date: run.date),
      "distance": run.distance,
      "duration": run.duration,
      "calories": run.calories,
      "pace": run.pace,
      "averageHeartRate": run.averageHeartRate,
      "pathCoordinates": run.pathCoordinates,
    ]
    let docRef = try await db.collection("agents").document(user.uid).collection("runs")
      .addDocument(data: runData)
    print("✅ DEBUG: saveRun - Successfully saved run with ID: \(docRef.documentID)")

    // Update aggregate stats
    let userRef = db.collection("agents").document(user.uid)
    print("DEBUG: saveRun - Updating stats for user: \(user.uid)")
    _ = try await db.runTransaction({ (transaction, errorPointer) -> Any? in
      let snapshot: DocumentSnapshot
      do {
        try snapshot = transaction.getDocument(userRef)
      } catch let fetchError as NSError {
        errorPointer?.pointee = fetchError
        return nil
      }

      var newTotalDistance = run.distance
      var newTotalWorkouts = 1

      if let data = snapshot.data(), let stats = data["stats"] as? [String: Any] {
        let currentDistance = stats["totalDistance"] as? Double ?? 0
        let currentWorkouts = stats["totalWorkouts"] as? Int ?? 0
        newTotalDistance += currentDistance
        newTotalWorkouts += currentWorkouts
      }

      transaction.setData(
        [
          "stats": [
            "totalDistance": newTotalDistance,
            "totalWorkouts": newTotalWorkouts,
          ],
          "lastActive": FieldValue.serverTimestamp(),
        ], forDocument: userRef, merge: true)

      return nil
    })
  }

  func fetchRuns() async throws -> [RunData] {
    guard let user = Auth.auth().currentUser else {
      print("DEBUG: fetchRuns - No current user")
      return []
    }

    print("DEBUG: fetchRuns - Fetching runs for user: \(user.uid)")
    let snapshot = try await db.collection("agents").document(user.uid)
      .collection("runs")
      .order(by: "date", descending: true)
      .getDocuments()

    print("DEBUG: fetchRuns - Found \(snapshot.documents.count) documents")

    return snapshot.documents.compactMap { document in
      let data = document.data()

      guard let timestamp = data["date"] as? Timestamp,
        let distance = data["distance"] as? Double,
        let duration = data["duration"] as? TimeInterval,
        let calories = data["calories"] as? Double,
        let pace = data["pace"] as? Double,
        let averageHeartRate = data["averageHeartRate"] as? Int,
        let pathCoordinates = data["pathCoordinates"] as? [GeoPoint]
      else {
        print("DEBUG: fetchRuns - Error decoding document \(document.documentID)")
        return nil
      }

      return RunData(
        id: document.documentID,
        date: timestamp.dateValue(),
        distance: distance,
        duration: duration,
        calories: calories,
        pace: pace,
        averageHeartRate: averageHeartRate,
        pathCoordinates: pathCoordinates
      )
    }
  }
}

// MARK: - Models

struct RunData: Codable, Identifiable {
  var id: String?
  var date: Date
  var distance: Double  // in km
  var duration: TimeInterval
  var calories: Double
  var pace: Double  // min/km
  var averageHeartRate: Int
  var pathCoordinates: [GeoPoint]  // simplified path for map preview

  // Helper to convert CLLocationCoordinate2D to GeoPoint for Firestore
  static func toGeoPoints(from coordinates: [CLLocationCoordinate2D]) -> [GeoPoint] {
    return coordinates.map { GeoPoint(latitude: $0.latitude, longitude: $0.longitude) }
  }
}
