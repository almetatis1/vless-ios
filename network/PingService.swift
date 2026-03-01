import Foundation
import Network

// MARK: - Ping Result Model
struct PingResult: Identifiable {
    let id = UUID()
    let host: String
    let ip: String?
    let latencyMs: Double?
    let status: PingStatus
    let timestamp: Date
    
    enum PingStatus {
        case success
        case timeout
        case unreachable
        case error(String)
        
        var description: String {
            switch self {
            case .success: return "Success"
            case .timeout: return "Timeout"
            case .unreachable: return "Unreachable"
            case .error(let msg): return "Error: \(msg)"
            }
        }
    }
}

// MARK: - Ping Service
class PingService: ObservableObject {
    @Published var results: [PingResult] = []
    @Published var isRunning = false
    
    private var pingTasks: [Task<Void, Never>] = []
    
    // Common hosts for ping testing
    static let commonHosts = [
        ("Google DNS", "8.8.8.8"),
        ("Cloudflare DNS", "1.1.1.1"),
        ("OpenDNS", "208.67.222.222"),
        ("Quad9 DNS", "9.9.9.9")
    ]
    
    func ping(host: String, count: Int = 4) {
        isRunning = true
        results.removeAll()
        
        let task = Task {
            for i in 0..<count {
                guard !Task.isCancelled else { break }
                
                let startTime = Date()
                let result = await performPing(host: host)
                
                await MainActor.run {
                    self.results.append(result)
                }
                
                // Wait 1 second between pings
                if i < count - 1 {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                }
            }
            
            await MainActor.run {
                self.isRunning = false
            }
        }
        
        pingTasks.append(task)
    }
    
    func pingMultipleHosts(hosts: [(String, String)]) {
        isRunning = true
        results.removeAll()
        
        let task = Task {
            for (name, host) in hosts {
                guard !Task.isCancelled else { break }
                
                let result = await performPing(host: host, displayName: name)
                
                await MainActor.run {
                    self.results.append(result)
                }
            }
            
            await MainActor.run {
                self.isRunning = false
            }
        }
        
        pingTasks.append(task)
    }
    
    /// Single ping for one host; returns latency in ms. Uses TCP port 443 first,
    /// falls back to HTTP HEAD if TCP fails. Hard 2-second timeout. Never returns nil —
    /// on total failure returns 999 (shown as 1 red bar) so the spinner always resolves.
    func pingOnce(host: String) async -> Double? {
        let start = Date()

        // --- Attempt 1: TCP connect to port 443 with 2s hard timeout ---
        let tcpMs = await withTaskGroup(of: Double?.self) { group in
            group.addTask {
                await self.tcpPing(host: host, port: .https)
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                return Optional<Double>.none
            }
            // Return first non-nil result OR nil if timeout wins
            for await result in group {
                group.cancelAll()
                if let ms = result { return Optional(ms) }
            }
            return Optional<Double>.none
        }

        if let ms = tcpMs { return ms }

        // --- Attempt 2: HTTP HEAD fallback on port 80 with remaining time ---
        let elapsed = Date().timeIntervalSince(start) * 1000
        let remaining = max(500, 2000 - elapsed) // at least 500 ms for fallback

        let httpMs = await withTaskGroup(of: Double?.self) { group in
            group.addTask {
                await self.httpHeadPing(host: host)
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: UInt64(remaining) * 1_000_000)
                return Optional<Double>.none
            }
            for await result in group {
                group.cancelAll()
                if let ms = result { return Optional(ms) }
            }
            return Optional<Double>.none
        }

        // Return measured value or 999 (1 red bar) so spinner always resolves
        return httpMs ?? 999
    }

    private func tcpPing(host: String, port: NWEndpoint.Port) async -> Double? {
        let start = Date()
        let connection = NWConnection(host: NWEndpoint.Host(host), port: port, using: .tcp)
        return await withCheckedContinuation { continuation in
            var done = false
            connection.stateUpdateHandler = { state in
                guard !done else { return }
                switch state {
                case .ready:
                    done = true
                    connection.cancel()
                    continuation.resume(returning: Date().timeIntervalSince(start) * 1000)
                case .failed:
                    done = true
                    connection.cancel()
                    continuation.resume(returning: Optional<Double>.none)
                default: break
                }
            }
            connection.start(queue: .global())
        }
    }

    private func httpHeadPing(host: String) async -> Double? {
        let urlString = "http://\(host)"
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 2
        let start = Date()
        do {
            let config = URLSessionConfiguration.ephemeral
            config.timeoutIntervalForRequest = 2
            let session = URLSession(configuration: config)
            _ = try await session.data(for: request)
            return Date().timeIntervalSince(start) * 1000
        } catch {
            // If we got any response (even error status), extract latency
            let ms = Date().timeIntervalSince(start) * 1000
            return ms < 1900 ? ms : nil // only count if it responded before timeout
        }
    }
    
    private func performPing(host: String, displayName: String? = nil) async -> PingResult {
        let startTime = Date()
        
        // Use NWConnection for basic connectivity check
        // Note: This is a simplified ping - true ICMP ping requires lower-level networking
        let connection = NWConnection(
            host: NWEndpoint.Host(host),
            port: .https,
            using: .tcp
        )
        
        return await withCheckedContinuation { continuation in
            var hasResumed = false
            
            connection.stateUpdateHandler = { state in
                guard !hasResumed else { return }
                
                switch state {
                case .ready:
                    hasResumed = true
                    let latency = Date().timeIntervalSince(startTime) * 1000 // Convert to ms
                    
                    // Get IP address if available
                    var ipAddress: String?
                    if case .hostPort(let host, _) = connection.currentPath?.remoteEndpoint {
                        ipAddress = "\(host)"
                    }
                    
                    let result = PingResult(
                        host: displayName ?? host,
                        ip: ipAddress ?? host,
                        latencyMs: latency,
                        status: .success,
                        timestamp: Date()
                    )
                    connection.cancel()
                    continuation.resume(returning: result)
                    
                case .failed(let error):
                    hasResumed = true
                    let result = PingResult(
                        host: displayName ?? host,
                        ip: nil,
                        latencyMs: nil,
                        status: .error(error.localizedDescription),
                        timestamp: Date()
                    )
                    connection.cancel()
                    continuation.resume(returning: result)
                    
                case .waiting(let error):
                    // Give it a moment before timing out
                    DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                        guard !hasResumed else { return }
                        hasResumed = true
                        let result = PingResult(
                            host: displayName ?? host,
                            ip: nil,
                            latencyMs: nil,
                            status: .timeout,
                            timestamp: Date()
                        )
                        connection.cancel()
                        continuation.resume(returning: result)
                    }
                    
                default:
                    break
                }
            }
            
            connection.start(queue: .global())
            
            // Timeout after 10 seconds
            DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
                guard !hasResumed else { return }
                hasResumed = true
                let result = PingResult(
                    host: displayName ?? host,
                    ip: nil,
                    latencyMs: nil,
                    status: .timeout,
                    timestamp: Date()
                )
                connection.cancel()
                continuation.resume(returning: result)
            }
        }
    }
    
    func stopPing() {
        pingTasks.forEach { $0.cancel() }
        pingTasks.removeAll()
        isRunning = false
    }
    
    func averageLatency() -> Double? {
        let successfulPings = results.compactMap { $0.latencyMs }
        guard !successfulPings.isEmpty else { return nil }
        return successfulPings.reduce(0, +) / Double(successfulPings.count)
    }
    
    func packetLoss() -> Double {
        guard !results.isEmpty else { return 0 }
        let failed = results.filter { 
            if case .success = $0.status { return false }
            return true
        }.count
        return Double(failed) / Double(results.count) * 100
    }
}
