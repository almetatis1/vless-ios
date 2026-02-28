import Foundation

// MARK: - Supabase Configuration
struct SupabaseConfig {
    static let shared = SupabaseConfig()
    
    // Supabase credentials from .env
    private let supabaseURL = "https://uhpuqiptxcjluwsetoev.supabase.co"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVocHVxaXB0eGNqbHV3c2V0b2V2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwOTE4OTYsImV4cCI6MjA3MjY2Nzg5Nn0.D_t-dyA4Z192kAU97Oi79At_IDT_5putusXrR0bQ6z8"
    
    private init() {}
    
    // Fetch VPN servers from Supabase
    func fetchVPNServers(completion: @escaping (Result<[VPNServer], Error>) -> Void) {
        let urlString = "\(supabaseURL)/rest/v1/vpn_servers?select=*&active=eq.true&status=eq.available&order=name.asc"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "SupabaseConfig", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Supabase Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Supabase Response Status: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No data received from Supabase")
                completion(.failure(NSError(domain: "SupabaseConfig", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            print("📦 Received data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
            
            do {
                let decoder = JSONDecoder()
                // Don't use convertFromSnakeCase since we have explicit CodingKeys
                let servers = try decoder.decode([VPNServer].self, from: data)
                print("✅ Successfully decoded \(servers.count) servers")
                completion(.success(servers))
            } catch {
                print("❌ Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}
