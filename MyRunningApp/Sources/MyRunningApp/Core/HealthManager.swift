import CoreLocation
import CoreMotion
import FirebaseAuth
import FirebaseFirestore
import Foundation
import HealthKit

// MARK: - Health Manager
@MainActor
@available(iOS 17.0, *)
class HealthManager: NSObject, ObservableObject {
  private let healthStore = HKHealthStore()

  // Live Workout Session
  // Removed HKWorkoutSession/Builder for iOS compatibility

  @Published var isAuthorized = false
  @Published var todaySteps: Int = 0
  @Published var todayDistance: Double = 0  // in km
  @Published var todayCalories: Int = 0
  @Published var weeklyDistance: Double = 0  // in km
  @Published var currentHeartRate: Int = 0
  @Published var sessionDistance: Double = 0
  @Published var sessionCalories: Double = 0

  @Published var isWorkoutActive = false

  // Helpers for Profile View
  func monthlyTotalDistance() -> Double {
    return weeklyDistance * 4  // Estimate for now
  }

  func totalWorkouts() -> Int {
    return Int(weeklyDistance / 5)  // Estimate: 5km per run avg
  }

  // Types we want to read/write
  private let readTypes: Set<HKObjectType> = [
    HKObjectType.quantityType(forIdentifier: .stepCount)!,
    HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
    HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
    HKObjectType.quantityType(forIdentifier: .heartRate)!,
    HKObjectType.workoutType(),
  ]

  private let writeTypes: Set<HKSampleType> = [
    HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
    HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
    HKObjectType.workoutType(),
  ]

  var isHealthDataAvailable: Bool {
    HKHealthStore.isHealthDataAvailable()
  }

  func requestAuthorization() async {
    print("DEBUG: Requesting HealthKit authorization...")
    guard isHealthDataAvailable else {
      print("DEBUG: HealthKit not available on this device")
      return
    }

    do {
      print("DEBUG: Requesting authorization for types: \(readTypes) and \(writeTypes)")
      try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
      print("DEBUG: Authorization request completed successfully")
      isAuthorized = true
      await fetchTodayStats()
    } catch {
      print("DEBUG: HealthKit authorization failed: \(error)")
    }
  }

  func fetchTodayStats() async {
    await fetchTodaySteps()
    await fetchTodayDistance()
    await fetchTodayCalories()
    await fetchWeeklyDistance()
  }

  private func fetchTodaySteps() async {
    guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

    let now = Date()
    let startOfDay = Calendar.current.startOfDay(for: now)
    let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now)

    do {
      let result = try await withCheckedThrowingContinuation {
        (continuation: CheckedContinuation<Double, Error>) in
        let query = HKStatisticsQuery(
          quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum
        ) { _, stats, error in
          if let error = error {
            continuation.resume(throwing: error)
          } else {
            let steps = stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            continuation.resume(returning: steps)
          }
        }
        healthStore.execute(query)
      }
      todaySteps = Int(result)
    } catch {
      print("Failed to fetch steps: \(error)")
    }
  }

  private func fetchTodayDistance() async {
    guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
    else { return }

    let now = Date()
    let startOfDay = Calendar.current.startOfDay(for: now)
    let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now)

    do {
      let result = try await withCheckedThrowingContinuation {
        (continuation: CheckedContinuation<Double, Error>) in
        let query = HKStatisticsQuery(
          quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum
        ) { _, stats, error in
          if let error = error {
            continuation.resume(throwing: error)
          } else {
            let distance = stats?.sumQuantity()?.doubleValue(for: .meterUnit(with: .kilo)) ?? 0
            continuation.resume(returning: distance)
          }
        }
        healthStore.execute(query)
      }
      todayDistance = result
    } catch {
      print("Failed to fetch distance: \(error)")
    }
  }

  private func fetchTodayCalories() async {
    guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
      return
    }

    let now = Date()
    let startOfDay = Calendar.current.startOfDay(for: now)
    let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now)

    do {
      let result = try await withCheckedThrowingContinuation {
        (continuation: CheckedContinuation<Double, Error>) in
        let query = HKStatisticsQuery(
          quantityType: caloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum
        ) { _, stats, error in
          if let error = error {
            continuation.resume(throwing: error)
          } else {
            let calories = stats?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
            continuation.resume(returning: calories)
          }
        }
        healthStore.execute(query)
      }
      todayCalories = Int(result)
    } catch {
      print("Failed to fetch calories: \(error)")
    }
  }

  private func fetchWeeklyDistance() async {
    guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
    else { return }

    let now = Date()
    let startOfWeek = Calendar.current.date(byAdding: .day, value: -7, to: now)!
    let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: now)

    do {
      let result = try await withCheckedThrowingContinuation {
        (continuation: CheckedContinuation<Double, Error>) in
        let query = HKStatisticsQuery(
          quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum
        ) { _, stats, error in
          if let error = error {
            continuation.resume(throwing: error)
          } else {
            let distance = stats?.sumQuantity()?.doubleValue(for: .meterUnit(with: .kilo)) ?? 0
            continuation.resume(returning: distance)
          }
        }
        healthStore.execute(query)
      }
      weeklyDistance = result
    } catch {
      print("Failed to fetch weekly distance: \(error)")
    }
  }

  // MARK: - Live Workout Management

  // MARK: - Live Workout Management (iOS Compatible)

  private var heartRateQuery: HKAnchoredObjectQuery?
  private var energyQuery: HKAnchoredObjectQuery?
  private var distanceQuery: HKAnchoredObjectQuery?

  func startWorkout() {
    isWorkoutActive = true
    startQueries()
  }

  func stopWorkout() {
    isWorkoutActive = false
    stopQueries()
    // Note: The actual workout saving is handled by saveWorkout(distance:duration:calories:) called from UI
  }

  func togglePause() {
    isWorkoutActive.toggle()
    if isWorkoutActive {
      startQueries()
    } else {
      stopQueries()
    }
  }

  private func startQueries() {
    // Fetch latest heart rate immediately
    Task {
      await fetchLatestHeartRate()
    }

    // Start monitoring for Heart Rate
    if let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) {
      let heartRateQuery = createAnchoredQuery(for: heartRateType) { [weak self] samples in
        guard let self = self, let lastSample = samples.last else { return }
        let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
        DispatchQueue.main.async {
          self.currentHeartRate = Int(lastSample.quantity.doubleValue(for: unit))
        }
      }
      self.heartRateQuery = heartRateQuery
      healthStore.execute(heartRateQuery)
    }

    // Start monitoring for Active Energy
    if let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
      let energyQuery = createAnchoredQuery(for: energyType) { [weak self] samples in
        guard let self = self else { return }
        let unit = HKUnit.kilocalorie()
        let totalEnergy = samples.reduce(0) { $0 + $1.quantity.doubleValue(for: unit) }
        DispatchQueue.main.async {
          self.sessionCalories += totalEnergy
        }
      }
      self.energyQuery = energyQuery
      healthStore.execute(energyQuery)
    }
  }

  private func stopQueries() {
    if let query = heartRateQuery { healthStore.stop(query) }
    if let query = energyQuery { healthStore.stop(query) }
    heartRateQuery = nil
    energyQuery = nil
  }

  private func createAnchoredQuery(
    for type: HKQuantityType, handler: @escaping ([HKQuantitySample]) -> Void
  )
    -> HKAnchoredObjectQuery
  {
    // Use a slightly older start date for the anchored query to avoid missing samples
    // that might happen exactly at start time.
    let startTime = Date().addingTimeInterval(-60)
    let predicate = HKQuery.predicateForSamples(
      withStart: startTime, end: nil, options: .strictStartDate)
    let query = HKAnchoredObjectQuery(
      type: type, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit
    ) { _, samples, deleted, newAnchor, error in
      guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else { return }
      handler(samples)
    }

    query.updateHandler = { _, samples, deleted, newAnchor, error in
      guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else { return }
      handler(samples)
    }

    return query
  }

  private func fetchLatestHeartRate() async {
    guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }

    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    let query = HKSampleQuery(
      sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]
    ) { [weak self] _, samples, error in
      guard let self = self, let sample = samples?.first as? HKQuantitySample else { return }
      let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
      DispatchQueue.main.async {
        self.currentHeartRate = Int(sample.quantity.doubleValue(for: unit))
      }
    }
    healthStore.execute(query)
  }

  func saveWorkout(
    distance: Double, duration: TimeInterval, calories: Double,
    pace: Double, heartRate: Int,
    coordinates: [CLLocationCoordinate2D] = []
  ) async {
    let configuration = HKWorkoutConfiguration()
    configuration.activityType = .running
    configuration.locationType = .outdoor

    let builder = HKWorkoutBuilder(
      healthStore: healthStore, configuration: configuration, device: .local())

    do {
      // 1. Begin Collection
      try await withCheckedThrowingContinuation {
        (continuation: CheckedContinuation<Void, Error>) in
        builder.beginCollection(withStart: Date().addingTimeInterval(-duration)) { success, error in
          if let error = error {
            continuation.resume(throwing: error)
          } else {
            continuation.resume()
          }
        }
      }

      // 2. Create Samples
      let samples: [HKSample] = [
        HKQuantitySample(
          type: HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
          quantity: HKQuantity(unit: .meterUnit(with: .kilo), doubleValue: distance),
          start: Date().addingTimeInterval(-duration),
          end: Date()
        ),
        HKQuantitySample(
          type: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
          quantity: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
          start: Date().addingTimeInterval(-duration),
          end: Date()
        ),
      ]

      // 3. Add Samples
      try await withCheckedThrowingContinuation {
        (continuation: CheckedContinuation<Void, Error>) in
        builder.add(samples) { success, error in
          if let error = error {
            continuation.resume(throwing: error)
          } else {
            continuation.resume()
          }
        }
      }

      // 4. End Collection
      try await withCheckedThrowingContinuation {
        (continuation: CheckedContinuation<Void, Error>) in
        builder.endCollection(withEnd: Date()) { success, error in
          if let error = error {
            continuation.resume(throwing: error)
          } else {
            continuation.resume()
          }
        }
      }

      // 5. Finish Workout
      try await withCheckedThrowingContinuation {
        (continuation: CheckedContinuation<Void, Error>) in
        builder.finishWorkout { workout, error in
          if let error = error {
            continuation.resume(throwing: error)
          } else {
            continuation.resume()
          }
        }
      }

      print("Workout saved successfully via Builder!")
      await fetchTodayStats()

      // Save to Firebase
      // Note: We need coordinates for the path. For now, we'll pass an empty array
      // or we need to pass coordinates into saveWorkout.
      // Let's assume we update saveWorkout to accept coordinates or we fetch them from LocationManager.
      // For this step, we'll save basic stats.

      let runData = RunData(
        date: Date(),
        distance: distance,
        duration: duration,
        calories: calories,
        pace: pace,
        averageHeartRate: heartRate,
        pathCoordinates: RunData.toGeoPoints(from: coordinates)
      )

      do {
        print(
          "DEBUG: Saving run data to Firebase for user \(Auth.auth().currentUser?.uid ?? "nil")")
        try await FirebaseManager.shared.saveRun(run: runData)
        print("DEBUG: Run data saved successfully to Firebase")
      } catch {
        print("DEBUG: Failed to save run to Firebase: \(error)")
      }

    } catch {
      print("Failed to save workout: \(error)")
    }
  }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  private let locationManager = CLLocationManager()

  @Published var currentLocation: CLLocation?
  @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
  @Published var isTracking = false
  @Published var routeCoordinates: [CLLocationCoordinate2D] = []
  @Published var totalDistance: Double = 0  // in kilometers
  @Published var currentPace: Double = 0  // min/km

  private var lastLocation: CLLocation?
  private var startTime: Date?

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = 5  // Update every 5 meters
    // locationManager.allowsBackgroundLocationUpdates = true
    // locationManager.pausesLocationUpdatesAutomatically = false
    authorizationStatus = locationManager.authorizationStatus
  }

  func requestAuthorization() {
    locationManager.requestWhenInUseAuthorization()
  }

  func startTracking() {
    routeCoordinates = []
    totalDistance = 0
    lastLocation = nil
    startTime = Date()
    isTracking = true

    // Enable background updates only when tracking starts
    // locationManager.allowsBackgroundLocationUpdates = true // Disabled to fix crash temporarily
    // locationManager.pausesLocationUpdatesAutomatically = false

    locationManager.startUpdatingLocation()
  }

  func stopTracking() {
    isTracking = false
    locationManager.stopUpdatingLocation()
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationStatus = manager.authorizationStatus
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last, isTracking else { return }

    currentLocation = location
    routeCoordinates.append(location.coordinate)

    // Calculate distance
    if let last = lastLocation {
      let distanceMeters = location.distance(from: last)
      totalDistance += distanceMeters / 1000.0  // Convert to km

      // Calculate pace (min/km)
      if let start = startTime, totalDistance > 0 {
        let elapsedMinutes = Date().timeIntervalSince(start) / 60.0
        currentPace = elapsedMinutes / totalDistance
      }
    }

    lastLocation = location
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location error: \(error)")
  }
}

// MARK: - Motion Manager
class MotionManager: ObservableObject {
  private let pedometer = CMPedometer()
  private let motionManager = CMMotionActivityManager()

  @Published var todaySteps: Int = 0
  @Published var currentCadence: Int = 0  // steps per minute
  @Published var isRunning = false
  @Published var isWalking = false

  var isPedometerAvailable: Bool {
    CMPedometer.isStepCountingAvailable()
  }

  var isActivityAvailable: Bool {
    CMMotionActivityManager.isActivityAvailable()
  }

  func startTracking() {
    guard isPedometerAvailable else { return }

    let startOfDay = Calendar.current.startOfDay(for: Date())

    // Query today's steps
    pedometer.queryPedometerData(from: startOfDay, to: Date()) { [weak self] data, error in
      DispatchQueue.main.async {
        self?.todaySteps = Int(data?.numberOfSteps ?? 0)
      }
    }

    // Start live updates
    pedometer.startUpdates(from: Date()) { [weak self] data, error in
      DispatchQueue.main.async {
        if let cadence = data?.currentCadence?.intValue {
          self?.currentCadence = cadence
        }
      }
    }

    // Start activity tracking
    if isActivityAvailable {
      motionManager.startActivityUpdates(to: .main) { [weak self] activity in
        self?.isRunning = activity?.running ?? false
        self?.isWalking = activity?.walking ?? false
      }
    }
  }

  func stopTracking() {
    pedometer.stopUpdates()
    motionManager.stopActivityUpdates()
  }
}

// MARK: - Run Session Manager (Combines all managers)
@MainActor
@available(iOS 17.0, *)
class RunSessionManager: ObservableObject {
  let healthManager = HealthManager()
  let locationManager = LocationManager()
  let motionManager = MotionManager()

  @Published var isRunning = false
  @Published var elapsedTime: TimeInterval = 0
  @Published var distance: Double = 0  // km
  @Published var pace: Double = 0  // min/km
  @Published var calories: Int = 0
  @Published var heartRate: Int = 0

  private var timer: Timer?
  private var startTime: Date?

  func requestPermissions() async {
    await healthManager.requestAuthorization()
    locationManager.requestAuthorization()
  }

  func startRun() {
    isRunning = true
    startTime = Date()
    elapsedTime = 0

    locationManager.startTracking()
    motionManager.startTracking()

    // Start timer
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      Task { @MainActor in
        self?.updateStats()
      }
    }
  }

  func stopRun() async {
    isRunning = false
    timer?.invalidate()
    timer = nil

    locationManager.stopTracking()
    motionManager.stopTracking()

    // Save workout to HealthKit
    let caloriesBurned = Double(calories)
    await healthManager.saveWorkout(
      distance: distance,
      duration: elapsedTime,
      calories: caloriesBurned,
      pace: pace,
      heartRate: healthManager.currentHeartRate,
      coordinates: locationManager.routeCoordinates
    )
  }

  private func updateStats() {
    guard let start = startTime else { return }

    elapsedTime = Date().timeIntervalSince(start)
    distance = locationManager.totalDistance
    pace = locationManager.currentPace
    heartRate = healthManager.currentHeartRate

    // Estimate calories (approx 60 cal/km for running)
    calories = Int(distance * 60)
  }
}
