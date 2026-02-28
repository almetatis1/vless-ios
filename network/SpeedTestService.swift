import Foundation

// MARK: - Speed Test Result Model
struct SpeedTestResult: Identifiable, Codable {
    let id: UUID
    let downloadSpeedMbps: Double
    let uploadSpeedMbps: Double
    let pingMs: Double
    let jitterMs: Double
    let timestamp: Date
    let serverLocation: String
    
    init(downloadSpeedMbps: Double, uploadSpeedMbps: Double, pingMs: Double, jitterMs: Double, serverLocation: String) {
        self.id = UUID()
        self.downloadSpeedMbps = downloadSpeedMbps
        self.uploadSpeedMbps = uploadSpeedMbps
        self.pingMs = pingMs
        self.jitterMs = jitterMs
        self.timestamp = Date()
        self.serverLocation = serverLocation
    }
}

// MARK: - Speed Test Service
class SpeedTestService: ObservableObject {
    @Published var currentResult: SpeedTestResult?
    @Published var isRunning = false
    @Published var progress: Double = 0.0
    @Published var currentPhase: TestPhase = .idle
    @Published var history: [SpeedTestResult] = []
    @Published var speedHistory: [Double] = [] // For live graph (download)
    @Published var uploadHistory: [Double] = [] // For live graph (upload)
    @Published var currentSpeed: Double = 0.0
    
    enum TestPhase {
        case idle
        case testingPing
        case testingDownload
        case testingUpload
        case complete
        
        var description: String {
            switch self {
            case .idle: return "Ready"
            case .testingPing: return "Testing Ping..."
            case .testingDownload: return "Testing Download Speed..."
            case .testingUpload: return "Testing Upload Speed..."
            case .complete: return "Complete"
            }
        }
    }
    
    private var testTask: Task<Void, Never>?
    
    // Test file URLs (using public speed test servers)
    private let testServers = [
        ("Cloudflare", "https://speed.cloudflare.com/__down?bytes=25000000"), // 25MB
        ("Fast.com", "https://api.fast.com/netflix/speedtest/v2"),
    ]
    
    init() {
        loadHistory()
    }
    
    func runSpeedTest(completion: (() -> Void)? = nil) {
        isRunning = true
        progress = 0.0
        speedHistory.removeAll()
        uploadHistory.removeAll()
        
        testTask = Task {
            // Phase 1: Ping Test
            await MainActor.run { self.currentPhase = .testingPing }
            let pingResult = await testPing()
            await MainActor.run { self.progress = 0.33 }
            
            guard !Task.isCancelled else {
                await MainActor.run { self.isRunning = false }
                return
            }
            
            // Phase 2: Download Test
            await MainActor.run { self.currentPhase = .testingDownload }
            let downloadSpeed = await testDownloadSpeed()
            await MainActor.run { self.progress = 0.66 }
            
            guard !Task.isCancelled else {
                await MainActor.run { self.isRunning = false }
                return
            }
            
            // Phase 3: Upload Test
            await MainActor.run { self.currentPhase = .testingUpload }
            let uploadSpeed = await testUploadSpeed()
            await MainActor.run { self.progress = 1.0 }
            
            // Create result
            let result = SpeedTestResult(
                downloadSpeedMbps: downloadSpeed,
                uploadSpeedMbps: uploadSpeed,
                pingMs: pingResult.avgPing,
                jitterMs: pingResult.jitter,
                serverLocation: "Auto"
            )
            
            await MainActor.run {
                self.currentResult = result
                self.currentPhase = .complete
                self.isRunning = false
                self.history.insert(result, at: 0)
                self.saveHistory()
                completion?()
            }
        }
    }
    
    private func testPing() async -> (avgPing: Double, jitter: Double) {
        var pings: [Double] = []
        
        // Perform 5 ping tests
        for _ in 0..<5 {
            let startTime = Date()
            
            // Simple HTTP HEAD request to measure latency
            if let url = URL(string: "https://www.cloudflare.com") {
                var request = URLRequest(url: url)
                request.httpMethod = "HEAD"
                request.timeoutInterval = 5
                
                do {
                    let (_, _) = try await URLSession.shared.data(for: request)
                    let latency = Date().timeIntervalSince(startTime) * 1000 // ms
                    pings.append(latency)
                } catch {
                    // If failed, use a high value
                    pings.append(1000)
                }
            }
            
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s between pings
        }
        
        let avgPing = pings.isEmpty ? 0 : pings.reduce(0, +) / Double(pings.count)
        
        // Calculate jitter (variance in ping)
        let jitter: Double
        if pings.count > 1 {
            let differences = zip(pings.dropFirst(), pings).map { abs($0 - $1) }
            jitter = differences.reduce(0, +) / Double(differences.count)
        } else {
            jitter = 0
        }
        
        return (avgPing, jitter)
    }
    
    private func testDownloadSpeed() async -> Double {
        // Download 5 chunks of 2MB to get live data points
        let chunkSize = 2_000_000 // 2 MB
        let chunks = 5
        var totalSpeed: Double = 0
        var successfulChunks = 0
        
        guard let url = URL(string: "https://speed.cloudflare.com/__down?bytes=\(chunkSize)") else {
            return 0
        }
        
        for _ in 0..<chunks {
            let startTime = Date()
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let duration = Date().timeIntervalSince(startTime)
                
                // Calculate speed in Mbps for this chunk
                let bytesDownloaded = Double(data.count)
                let bitsDownloaded = bytesDownloaded * 8
                let megabitsDownloaded = bitsDownloaded / 1_000_000
                let speedMbps = megabitsDownloaded / duration
                
                await MainActor.run {
                    self.speedHistory.append(speedMbps)
                    self.currentSpeed = speedMbps
                }
                
                totalSpeed += speedMbps
                successfulChunks += 1
            } catch {
                continue
            }
        }
        
        return successfulChunks > 0 ? totalSpeed / Double(successfulChunks) : 0
    }
    
    private func testUploadSpeed() async -> Double {
        // Upload test data and measure speed
        let testDataSize = 5_000_000 // 5 MB
        let testData = Data(repeating: 0, count: testDataSize)
        
        guard let url = URL(string: "https://speed.cloudflare.com/__up") else {
            return 0
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = testData
        request.timeoutInterval = 30
        
        let startTime = Date()
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            let duration = Date().timeIntervalSince(startTime)
            
            // Calculate speed in Mbps
            let bytesUploaded = Double(testDataSize)
            let bitsUploaded = bytesUploaded * 8
            let megabitsUploaded = bitsUploaded / 1_000_000
            let speedMbps = megabitsUploaded / duration
            
            await MainActor.run {
                self.currentSpeed = speedMbps
                self.uploadHistory.append(speedMbps)
            }

            return speedMbps
        } catch {
            return 0
        }
    }
    
    func stopTest() {
        testTask?.cancel()
        isRunning = false
        currentPhase = .idle
        progress = 0
    }
    
    // MARK: - History Management
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "speedTestHistory")
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "speedTestHistory"),
           let decoded = try? JSONDecoder().decode([SpeedTestResult].self, from: data) {
            history = decoded
        }
    }
    
    func clearHistory() {
        history.removeAll()
        UserDefaults.standard.removeObject(forKey: "speedTestHistory")
    }
}
