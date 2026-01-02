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
        print("❌ DEBUG: No User Logged In. Attempting auto-login...")
        Task {
          try? await self.signInAnonymously()
        }
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

  // MARK: - Run Data Management

  func saveRun(run: RunData) async throws {
    guard let user = Auth.auth().currentUser else {
      print("DEBUG: saveRun - No current user")
      return
    }

    let path = "agents/\(user.uid)/runs"
    print("DEBUG: saveRun - Attempting to save run to path: \(path)")

    let runData = try Firestore.Encoder().encode(run)
    let docRef = try await db.collection("agents").document(user.uid).collection("runs")
      .addDocument(
        data: runData)
    print("✅ DEBUG: saveRun - Successfully saved run with ID: \(docRef.documentID)")

    // Update aggregate stats
    let userRef = db.collection("agents").document(user.uid)
    print("DEBUG: saveRun - Updating stats for user: \(user.uid)")
    try await db.runTransaction({ (transaction, errorPointer) -> Any? in
      let snapshot: DocumentSnapshot
      do {
        try snapshot = transaction.getDocument(userRef)
      } catch let fetchError as NSError {
        errorPointer?.pointee = fetchError
        return nil
      }

      var newTotalDistance = run.distance
      var newTotalWorkouts = 1

      if let stats = snapshot.data()?["stats"] as? [String: Any] {
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
      do {
        var run = try document.data(as: RunData.self)
        run.id = document.documentID
        return run
      } catch {
        print("DEBUG: fetchRuns - Error decoding document \(document.documentID): \(error)")
        return nil
      }
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
