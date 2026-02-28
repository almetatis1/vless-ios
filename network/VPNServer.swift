import Foundation
import CoreLocation

// MARK: - VPN Server Model
struct VPNServer: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let countryCode: String
    let countryName: String
    let city: String
    let serverAddress: String
    let isPremium: Bool
    let active: Bool
    let status: String
    let flag: String
    let createdAt: String
    let updatedAt: String
    
    // WireGuard configuration
    let wireguardPublicKey: String?
    let wireguardPort: Int
    
    // OpenVPN configuration
    let openvpnUsername: String?
    let openvpnPassword: String?
    let openvpnCaCert: String?
    let openvpnClientCert: String?
    let openvpnClientKey: String?
    let openvpnPort: Int
    
    // Optional fields
    let location: String?
    let loadStatusText: String?
    
    // Custom coding keys to match Supabase snake_case
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case countryCode = "country_code"
        case countryName = "country_name"
        case city
        case serverAddress = "server_address"
        case isPremium = "is_premium"
        case active
        case status
        case flag
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case wireguardPublicKey = "wireguard_public_key"
        case wireguardPort = "wireguard_port"
        case openvpnUsername = "openvpn_username"
        case openvpnPassword = "openvpn_password"
        case openvpnCaCert = "openvpn_ca_cert"
        case openvpnClientCert = "openvpn_client_cert"
        case openvpnClientKey = "openvpn_client_key"
        case openvpnPort = "openvpn_port"
        case location
        case loadStatusText = "load_status_text"
    }
    
    // Display name for UI
    var displayName: String {
        return "\(flag) \(name) - \(city)"
    }
    
    // Check if server is active and available
    var isAvailable: Bool {
        return active && status.lowercased() == "available"
    }
    
    // Check if server has OpenVPN credentials
    var hasOpenvpnConfig: Bool {
        return openvpnUsername != nil && openvpnPassword != nil
    }
    
    // Check if server has WireGuard credentials
    var hasWireguardConfig: Bool {
        return wireguardPublicKey != nil
    }

    // Get server coordinates based on city/country for map visualization
    var coordinate: CLLocationCoordinate2D {
        let cityCoordinates: [String: CLLocationCoordinate2D] = [
            "stockholm": CLLocationCoordinate2D(latitude: 59.3293, longitude: 18.0686),
            "london": CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            "amsterdam": CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041),
            "frankfurt": CLLocationCoordinate2D(latitude: 50.1109, longitude: 8.6821),
            "paris": CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            "new york": CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            "los angeles": CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
            "tokyo": CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
            "singapore": CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198),
            "sydney": CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093),
            "toronto": CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),
            "zurich": CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417),
            "berlin": CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050),
            "madrid": CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
            "mumbai": CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777),
            "hong kong": CLLocationCoordinate2D(latitude: 22.3193, longitude: 114.1694),
            "seoul": CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
        ]

        let countryCoordinates: [String: CLLocationCoordinate2D] = [
            "se": CLLocationCoordinate2D(latitude: 59.3293, longitude: 18.0686),
            "gb": CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            "uk": CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            "nl": CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041),
            "de": CLLocationCoordinate2D(latitude: 50.1109, longitude: 8.6821),
            "fr": CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            "us": CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            "jp": CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
            "sg": CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198),
            "au": CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093),
            "ca": CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),
            "ch": CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417),
            "es": CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
            "in": CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777),
            "hk": CLLocationCoordinate2D(latitude: 22.3193, longitude: 114.1694),
            "kr": CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
        ]

        if let coord = cityCoordinates[city.lowercased()] {
            return coord
        }
        if let coord = countryCoordinates[countryCode.lowercased()] {
            return coord
        }
        return CLLocationCoordinate2D(latitude: 40.0, longitude: 0.0)
    }
}
