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
    
    // Optional VLESS
    let vlessUrl: String?
    let vlessUuid: String?
    let vlessPublicKey: String?
    let vlessPort: Int?
    
    // Optional translations: locale code -> display name (e.g. {"en": "Germany", "de": "Deutschland"})
    let countryNames: [String: String]?
    let cityName: [String: String]?
    
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
        case countryNames = "country_names"
        case cityName = "city_name"
        case vlessUrl = "vless_url"
        case vlessUuid = "vless_uuid"
        case vlessPublicKey = "vless_public_key"
        case vlessPort = "vless_port"
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        countryCode = try c.decode(String.self, forKey: .countryCode)
        countryName = try c.decode(String.self, forKey: .countryName)
        city = try c.decode(String.self, forKey: .city)
        serverAddress = try c.decode(String.self, forKey: .serverAddress)
        isPremium = try c.decode(Bool.self, forKey: .isPremium)
        active = try c.decode(Bool.self, forKey: .active)
        status = try c.decode(String.self, forKey: .status)
        flag = try c.decode(String.self, forKey: .flag)
        createdAt = try c.decode(String.self, forKey: .createdAt)
        updatedAt = try c.decode(String.self, forKey: .updatedAt)
        wireguardPublicKey = try c.decodeIfPresent(String.self, forKey: .wireguardPublicKey)
        wireguardPort = try c.decode(Int.self, forKey: .wireguardPort)
        openvpnUsername = try c.decodeIfPresent(String.self, forKey: .openvpnUsername)
        openvpnPassword = try c.decodeIfPresent(String.self, forKey: .openvpnPassword)
        openvpnCaCert = try c.decodeIfPresent(String.self, forKey: .openvpnCaCert)
        openvpnClientCert = try c.decodeIfPresent(String.self, forKey: .openvpnClientCert)
        openvpnClientKey = try c.decodeIfPresent(String.self, forKey: .openvpnClientKey)
        openvpnPort = try c.decode(Int.self, forKey: .openvpnPort)
        vlessUrl = try c.decodeIfPresent(String.self, forKey: .vlessUrl)
        vlessUuid = try c.decodeIfPresent(String.self, forKey: .vlessUuid)
        vlessPublicKey = try c.decodeIfPresent(String.self, forKey: .vlessPublicKey)
        vlessPort = try c.decodeIfPresent(Int.self, forKey: .vlessPort)
        cityName = try c.decodeIfPresent([String: String].self, forKey: .cityName)
        countryNames = try c.decodeIfPresent([String: String].self, forKey: .countryNames)
    }
    
    // Display name for UI
    var displayName: String {
        return "\(flag) \(name) - \(city)"
    }
    
    /// Localized "City, Country" from database city_name (combined per locale).
    func localizedCityName(preferredLocale: String) -> String {
        let code = preferredLocale.replacingOccurrences(of: "_", with: "-")
        if let names = cityName, !names.isEmpty {
            if let name = names[code] ?? names[code.components(separatedBy: "-").first ?? code] ?? names["en"], !name.isEmpty {
                return name
            }
        }
        return city
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
    
    // Check if server has VLESS config: either full vless_url or uuid + public_key
    var hasVlessConfig: Bool {
        if let url = vlessUrl, !url.trimmingCharacters(in: .whitespaces).isEmpty, url.lowercased().hasPrefix("vless://") {
            return true
        }
        let uuidOk = vlessUuid.map { !$0.trimmingCharacters(in: .whitespaces).isEmpty } ?? false
        let keyOk = vlessPublicKey.map { !$0.trimmingCharacters(in: .whitespaces).isEmpty } ?? false
        return uuidOk && keyOk
    }
    
    /// VLESS URL to use for connection: either vless_url or built from uuid + public_key + server_address + port
    var resolvedVlessUrl: String? {
        if let url = vlessUrl, !url.trimmingCharacters(in: .whitespaces).isEmpty, url.lowercased().hasPrefix("vless://") {
            return url
        }
        guard let uuid = vlessUuid?.trimmingCharacters(in: .whitespaces), !uuid.isEmpty,
              vlessPublicKey.map({ !$0.trimmingCharacters(in: .whitespaces).isEmpty }) ?? false,
              !serverAddress.isEmpty else {
            return nil
        }
        let port = vlessPort ?? 443
        return "vless://\(uuid)@\(serverAddress):\(port)"
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
