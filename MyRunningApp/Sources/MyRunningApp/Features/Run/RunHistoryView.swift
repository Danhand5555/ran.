import FirebaseFirestore
import MapKit
import SwiftUI

struct RunHistoryView: View {
  let colors: RanColors
  @EnvironmentObject var firebaseManager: FirebaseManager
  @State private var runs: [RunData] = []
  @State private var isLoading = true

  var body: some View {
    ZStack {
      colors.paper.ignoresSafeArea()

      VStack(spacing: 0) {
        // Header
        VStack(spacing: 0) {
          // Spacer for dynamic island/top curve
          Color.clear.frame(height: 50)

          HStack {
            VStack(alignment: .leading, spacing: 2) {
              Text("MISSION LOGS")
                .font(.system(size: 32, weight: .black))
                .italic()
                .foregroundStyle(colors.ink)

              Text("AGENT ACTIVITY HISTORY")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(colors.ink.opacity(0.5))
            }

            Spacer()

            Button(action: { Task { await loadRuns() } }) {
              Image(systemName: "arrow.clockwise")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(colors.ink)
                .padding(12)
                .background(colors.accent)
                .comicPanel(color: colors.accent, ink: colors.ink, x: 4, y: 4)
            }
            .buttonStyle(.plain)
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 20)
        }
        .background(colors.panel)
        .border(colors.ink, width: RanColors.thickness)

        if isLoading {
          Spacer()
          ProgressView()
            .tint(colors.accent)
          Spacer()
        } else if runs.isEmpty {
          Spacer()
          VStack(spacing: 12) {
            Image(systemName: "wind")
              .font(.system(size: 40))
              .foregroundStyle(colors.ink.opacity(0.3))
            Text("NO MISSIONS RECORDED")
              .font(.system(size: 16, weight: .bold))
              .foregroundStyle(colors.ink.opacity(0.5))
          }
          Spacer()
        } else {
          ScrollView {
            LazyVStack(spacing: 16) {
              ForEach(runs) { run in
                RunHistoryCard(run: run, colors: colors)
              }
            }
            .padding(20)
          }
        }
      }
    }
    .onAppear {
      Task {
        // Small delay to ensure firebase auth has a chance to sync if the sheet opens quickly
        try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5s
        await loadRuns()
      }
    }
  }

  private func loadRuns() async {
    isLoading = true
    do {
      runs = try await firebaseManager.fetchRuns()
      print("DEBUG: RunHistoryView - Loaded \(runs.count) runs")
    } catch {
      print("Error fetching runs: \(error)")
    }
    isLoading = false
  }
}

struct RunHistoryCard: View {
  let run: RunData
  let colors: RanColors

  private var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: run.date)
  }

  // Simple duration formatter
  private func formatDuration(_ timeInterval: TimeInterval) -> String {
    let minutes = Int(timeInterval) / 60
    let seconds = Int(timeInterval) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }

  var body: some View {
    VStack(spacing: 0) {
      // Top Stats Row
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 2) {
          Text("DISTANCE")
            .font(.system(size: 8, weight: .black))
            .foregroundStyle(colors.ink.opacity(0.5))
          Text(String(format: "%.2f km", run.distance))
            .font(.system(size: 14, weight: .black, design: .rounded))
            .foregroundStyle(colors.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        VStack(alignment: .leading, spacing: 2) {
          Text("PACE")
            .font(.system(size: 8, weight: .black))
            .foregroundStyle(colors.ink.opacity(0.5))
          Text(String(format: "%.2f", run.pace))
            .font(.system(size: 14, weight: .black, design: .rounded))
            .foregroundStyle(colors.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        VStack(alignment: .leading, spacing: 2) {
          Text("BPM")
            .font(.system(size: 8, weight: .black))
            .foregroundStyle(colors.ink.opacity(0.5))
          Text("\(run.averageHeartRate)")
            .font(.system(size: 14, weight: .black, design: .rounded))
            .foregroundStyle(colors.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        VStack(alignment: .trailing, spacing: 2) {
          Text("TIME")
            .font(.system(size: 8, weight: .black))
            .foregroundStyle(colors.ink.opacity(0.5))
          Text(formatDuration(run.duration))
            .font(.system(size: 14, weight: .black, design: .rounded))
            .foregroundStyle(colors.ink)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
      }
      .padding(12)
      .background(colors.panel)
      .border(colors.ink, width: 2)

      // Map Preview
      ZStack {
        if !run.pathCoordinates.isEmpty {
          Map {
            MapPolyline(
              coordinates: run.pathCoordinates.map {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
              }
            )
            .stroke(colors.action, lineWidth: 4)
          }
          .mapStyle(.standard(emphasis: .muted, pointsOfInterest: []))
          .disabled(true)  // Static preview
        } else {
          ZStack {
            colors.ink
            VStack(spacing: 8) {
              Image(systemName: "satellite.viewfinder")
                .font(.system(size: 24))
                .foregroundStyle(colors.accent)
              Text("NO TRACKING DATA")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(colors.paper.opacity(0.5))
            }
          }
        }
      }
      .frame(height: 150)
      .border(colors.ink, width: 3)
      .clipped()
      .offset(y: -2)

      // Footer
      HStack {
        Text(formattedDate.uppercased())
          .font(.system(size: 10, weight: .black, design: .monospaced))
          .foregroundStyle(colors.ink.opacity(0.8))

        Spacer()

        HStack(spacing: 6) {
          Image(systemName: "flame.fill")
            .font(.system(size: 12))
          Text("\(Int(run.calories)) KCAL")
            .font(.system(size: 14, weight: .black))
        }
        .foregroundStyle(colors.accent)
      }
      .padding(.horizontal, 15)
      .padding(.vertical, 10)
      .background(colors.panel)
      .border(colors.ink, width: 3)
      .offset(y: -5)
    }
    .padding(.bottom, 10)  // Extra space for the next card
    .background(colors.ink.offset(x: 6, y: 6))
  }
}

// Simple shape to draw the path
struct PathPreview: View {
  let points: [GeoPoint]
  let color: Color

  var body: some View {
    GeometryReader { geometry in
      Path { path in
        guard let first = points.first else { return }

        // Normalize points to fit in the box
        let minLat = points.map { $0.latitude }.min() ?? 0
        let maxLat = points.map { $0.latitude }.max() ?? 0
        let minLon = points.map { $0.longitude }.min() ?? 0
        let maxLon = points.map { $0.longitude }.max() ?? 0

        let latRange = maxLat - minLat
        let lonRange = maxLon - minLon

        let scaleX = geometry.size.width / (lonRange == 0 ? 1 : lonRange)
        let scaleY = geometry.size.height / (latRange == 0 ? 1 : latRange)

        let startX = (first.longitude - minLon) * scaleX
        let startY = (maxLat - first.latitude) * scaleY  // Invert Y for screen coords

        path.move(to: CGPoint(x: startX, y: startY))

        for point in points.dropFirst() {
          let x = (point.longitude - minLon) * scaleX
          let y = (maxLat - point.latitude) * scaleY
          path.addLine(to: CGPoint(x: x, y: y))
        }
      }
      .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
    }
    .padding(10)
  }
}
