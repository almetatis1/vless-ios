import CoreLocation
import Network

// MARK: - Traceroute Hop Model
struct TracerouteHop: Identifiable, Equatable {
    let id = UUID()
    let hopNumber: Int
    let host: String
    let ip: String?
    let latencyMs: Double?
    let status: HopStatus
    let coordinate: CLLocationCoordinate2D?
    let countryCode: String?

    var flagEmoji: String? {
        guard let code = countryCode, code.count == 2 else { return nil }
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in code.uppercased().unicodeScalars {
            guard let flag = UnicodeScalar(base + scalar.value) else { return nil }
            emoji.append(String(flag))
        }
        return emoji
    }

    enum HopStatus {
        case success
        case timeout
        case unreachable
    }

    static func == (lhs: TracerouteHop, rhs: TracerouteHop) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Traceroute Result Model
struct TracerouteResult: Identifiable {
    let id = UUID()
    let destination: String
    let hops: [TracerouteHop]
    let totalHops: Int
    let timestamp: Date
    let isComplete: Bool
}

// MARK: - Traceroute Service
class TracerouteService: ObservableObject {
    @Published var currentResult: TracerouteResult?
    @Published var isRunning = false
    @Published var hops: [TracerouteHop] = []

    private var traceTask: Task<Void, Never>?
    private let maxHops = 30

    // Country coordinates based on device locale (no location permission needed)
    private let countryCoordinates: [String: CLLocationCoordinate2D] = [
        // Europe
        "AL": CLLocationCoordinate2D(latitude: 41.3275, longitude: 19.8187),  // Albania - Tirana
        "AD": CLLocationCoordinate2D(latitude: 42.5063, longitude: 1.5218),   // Andorra
        "AT": CLLocationCoordinate2D(latitude: 48.2082, longitude: 16.3738),  // Austria - Vienna
        "BY": CLLocationCoordinate2D(latitude: 53.9045, longitude: 27.5615),  // Belarus - Minsk
        "BE": CLLocationCoordinate2D(latitude: 50.8503, longitude: 4.3517),   // Belgium - Brussels
        "BA": CLLocationCoordinate2D(latitude: 43.8563, longitude: 18.4131),  // Bosnia - Sarajevo
        "BG": CLLocationCoordinate2D(latitude: 42.6977, longitude: 23.3219),  // Bulgaria - Sofia
        "HR": CLLocationCoordinate2D(latitude: 45.8150, longitude: 15.9819),  // Croatia - Zagreb
        "CY": CLLocationCoordinate2D(latitude: 35.1856, longitude: 33.3823),  // Cyprus - Nicosia
        "CZ": CLLocationCoordinate2D(latitude: 50.0755, longitude: 14.4378),  // Czech - Prague
        "DK": CLLocationCoordinate2D(latitude: 55.6761, longitude: 12.5683),  // Denmark - Copenhagen
        "EE": CLLocationCoordinate2D(latitude: 59.4370, longitude: 24.7536),  // Estonia - Tallinn
        "FI": CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384),  // Finland - Helsinki
        "FR": CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),   // France - Paris
        "DE": CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050),  // Germany - Berlin
        "GR": CLLocationCoordinate2D(latitude: 37.9838, longitude: 23.7275),  // Greece - Athens
        "HU": CLLocationCoordinate2D(latitude: 47.4979, longitude: 19.0402),  // Hungary - Budapest
        "IS": CLLocationCoordinate2D(latitude: 64.1466, longitude: -21.9426), // Iceland - Reykjavik
        "IE": CLLocationCoordinate2D(latitude: 53.3498, longitude: -6.2603),  // Ireland - Dublin
        "IT": CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964),  // Italy - Rome
        "LV": CLLocationCoordinate2D(latitude: 56.9496, longitude: 24.1052),  // Latvia - Riga
        "LI": CLLocationCoordinate2D(latitude: 47.1660, longitude: 9.5554),   // Liechtenstein - Vaduz
        "LT": CLLocationCoordinate2D(latitude: 54.6872, longitude: 25.2797),  // Lithuania - Vilnius
        "LU": CLLocationCoordinate2D(latitude: 49.6116, longitude: 6.1319),   // Luxembourg
        "MT": CLLocationCoordinate2D(latitude: 35.8989, longitude: 14.5146),  // Malta - Valletta
        "MD": CLLocationCoordinate2D(latitude: 47.0105, longitude: 28.8638),  // Moldova - Chisinau
        "MC": CLLocationCoordinate2D(latitude: 43.7384, longitude: 7.4246),   // Monaco
        "ME": CLLocationCoordinate2D(latitude: 42.4304, longitude: 19.2594),  // Montenegro - Podgorica
        "NL": CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041),   // Netherlands - Amsterdam
        "MK": CLLocationCoordinate2D(latitude: 41.9981, longitude: 21.4254),  // North Macedonia - Skopje
        "NO": CLLocationCoordinate2D(latitude: 59.9139, longitude: 10.7522),  // Norway - Oslo
        "PL": CLLocationCoordinate2D(latitude: 52.2297, longitude: 21.0122),  // Poland - Warsaw
        "PT": CLLocationCoordinate2D(latitude: 38.7223, longitude: -9.1393),  // Portugal - Lisbon
        "RO": CLLocationCoordinate2D(latitude: 44.4268, longitude: 26.1025),  // Romania - Bucharest
        "RU": CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173),  // Russia - Moscow
        "SM": CLLocationCoordinate2D(latitude: 43.9424, longitude: 12.4578),  // San Marino
        "RS": CLLocationCoordinate2D(latitude: 44.7866, longitude: 20.4489),  // Serbia - Belgrade
        "SK": CLLocationCoordinate2D(latitude: 48.1486, longitude: 17.1077),  // Slovakia - Bratislava
        "SI": CLLocationCoordinate2D(latitude: 46.0569, longitude: 14.5058),  // Slovenia - Ljubljana
        "ES": CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),  // Spain - Madrid
        "SE": CLLocationCoordinate2D(latitude: 59.3293, longitude: 18.0686),  // Sweden - Stockholm
        "CH": CLLocationCoordinate2D(latitude: 46.9480, longitude: 7.4474),   // Switzerland - Bern
        "UA": CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234),  // Ukraine - Kyiv
        "GB": CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),  // UK - London
        "UK": CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),  // UK - London
        "VA": CLLocationCoordinate2D(latitude: 41.9029, longitude: 12.4534),  // Vatican City

        // North America
        "US": CLLocationCoordinate2D(latitude: 38.9072, longitude: -77.0369), // USA - Washington DC
        "CA": CLLocationCoordinate2D(latitude: 45.4215, longitude: -75.6972), // Canada - Ottawa
        "MX": CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332), // Mexico - Mexico City
        "GT": CLLocationCoordinate2D(latitude: 14.6349, longitude: -90.5069), // Guatemala
        "CU": CLLocationCoordinate2D(latitude: 23.1136, longitude: -82.3666), // Cuba - Havana
        "DO": CLLocationCoordinate2D(latitude: 18.4861, longitude: -69.9312), // Dominican Republic
        "HT": CLLocationCoordinate2D(latitude: 18.5944, longitude: -72.3074), // Haiti
        "JM": CLLocationCoordinate2D(latitude: 18.0179, longitude: -76.8099), // Jamaica - Kingston
        "PR": CLLocationCoordinate2D(latitude: 18.4655, longitude: -66.1057), // Puerto Rico
        "CR": CLLocationCoordinate2D(latitude: 9.9281, longitude: -84.0907),  // Costa Rica
        "PA": CLLocationCoordinate2D(latitude: 8.9824, longitude: -79.5199),  // Panama
        "BS": CLLocationCoordinate2D(latitude: 25.0480, longitude: -77.3554), // Bahamas
        "BB": CLLocationCoordinate2D(latitude: 13.1132, longitude: -59.5988), // Barbados
        "TT": CLLocationCoordinate2D(latitude: 10.6918, longitude: -61.2225), // Trinidad

        // South America
        "AR": CLLocationCoordinate2D(latitude: -34.6037, longitude: -58.3816), // Argentina - Buenos Aires
        "BO": CLLocationCoordinate2D(latitude: -16.4897, longitude: -68.1193), // Bolivia - La Paz
        "BR": CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333), // Brazil - Sao Paulo
        "CL": CLLocationCoordinate2D(latitude: -33.4489, longitude: -70.6693), // Chile - Santiago
        "CO": CLLocationCoordinate2D(latitude: 4.7110, longitude: -74.0721),   // Colombia - Bogota
        "EC": CLLocationCoordinate2D(latitude: -0.1807, longitude: -78.4678),  // Ecuador - Quito
        "PY": CLLocationCoordinate2D(latitude: -25.2637, longitude: -57.5759), // Paraguay - Asuncion
        "PE": CLLocationCoordinate2D(latitude: -12.0464, longitude: -77.0428), // Peru - Lima
        "UY": CLLocationCoordinate2D(latitude: -34.9011, longitude: -56.1645), // Uruguay - Montevideo
        "VE": CLLocationCoordinate2D(latitude: 10.4806, longitude: -66.9036),  // Venezuela - Caracas

        // Asia
        "AF": CLLocationCoordinate2D(latitude: 34.5553, longitude: 69.2075),  // Afghanistan - Kabul
        "AM": CLLocationCoordinate2D(latitude: 40.1792, longitude: 44.4991),  // Armenia - Yerevan
        "AZ": CLLocationCoordinate2D(latitude: 40.4093, longitude: 49.8671),  // Azerbaijan - Baku
        "BH": CLLocationCoordinate2D(latitude: 26.2285, longitude: 50.5860),  // Bahrain - Manama
        "BD": CLLocationCoordinate2D(latitude: 23.8103, longitude: 90.4125),  // Bangladesh - Dhaka
        "BT": CLLocationCoordinate2D(latitude: 27.4728, longitude: 89.6390),  // Bhutan - Thimphu
        "BN": CLLocationCoordinate2D(latitude: 4.9031, longitude: 114.9398),  // Brunei
        "KH": CLLocationCoordinate2D(latitude: 11.5564, longitude: 104.9282), // Cambodia - Phnom Penh
        "CN": CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074), // China - Beijing
        "GE": CLLocationCoordinate2D(latitude: 41.7151, longitude: 44.8271),  // Georgia - Tbilisi
        "HK": CLLocationCoordinate2D(latitude: 22.3193, longitude: 114.1694), // Hong Kong
        "IN": CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090),  // India - New Delhi
        "ID": CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456), // Indonesia - Jakarta
        "IR": CLLocationCoordinate2D(latitude: 35.6892, longitude: 51.3890),  // Iran - Tehran
        "IQ": CLLocationCoordinate2D(latitude: 33.3152, longitude: 44.3661),  // Iraq - Baghdad
        "IL": CLLocationCoordinate2D(latitude: 32.0853, longitude: 34.7818),  // Israel - Tel Aviv
        "JP": CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503), // Japan - Tokyo
        "JO": CLLocationCoordinate2D(latitude: 31.9454, longitude: 35.9284),  // Jordan - Amman
        "KZ": CLLocationCoordinate2D(latitude: 51.1605, longitude: 71.4704),  // Kazakhstan - Nur-Sultan
        "KW": CLLocationCoordinate2D(latitude: 29.3759, longitude: 47.9774),  // Kuwait
        "KG": CLLocationCoordinate2D(latitude: 42.8746, longitude: 74.5698),  // Kyrgyzstan - Bishkek
        "LA": CLLocationCoordinate2D(latitude: 17.9757, longitude: 102.6331), // Laos - Vientiane
        "LB": CLLocationCoordinate2D(latitude: 33.8938, longitude: 35.5018),  // Lebanon - Beirut
        "MO": CLLocationCoordinate2D(latitude: 22.1987, longitude: 113.5439), // Macau
        "MY": CLLocationCoordinate2D(latitude: 3.1390, longitude: 101.6869),  // Malaysia - Kuala Lumpur
        "MV": CLLocationCoordinate2D(latitude: 4.1755, longitude: 73.5093),   // Maldives - Male
        "MN": CLLocationCoordinate2D(latitude: 47.8864, longitude: 106.9057), // Mongolia - Ulaanbaatar
        "MM": CLLocationCoordinate2D(latitude: 19.7633, longitude: 96.0785),  // Myanmar - Naypyidaw
        "NP": CLLocationCoordinate2D(latitude: 27.7172, longitude: 85.3240),  // Nepal - Kathmandu
        "KP": CLLocationCoordinate2D(latitude: 39.0392, longitude: 125.7625), // North Korea - Pyongyang
        "OM": CLLocationCoordinate2D(latitude: 23.5880, longitude: 58.3829),  // Oman - Muscat
        "PK": CLLocationCoordinate2D(latitude: 33.6844, longitude: 73.0479),  // Pakistan - Islamabad
        "PS": CLLocationCoordinate2D(latitude: 31.9522, longitude: 35.2332),  // Palestine - Ramallah
        "PH": CLLocationCoordinate2D(latitude: 14.5995, longitude: 120.9842), // Philippines - Manila
        "QA": CLLocationCoordinate2D(latitude: 25.2854, longitude: 51.5310),  // Qatar - Doha
        "SA": CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),  // Saudi Arabia - Riyadh
        "SG": CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198),  // Singapore
        "KR": CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), // South Korea - Seoul
        "LK": CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),   // Sri Lanka - Colombo
        "SY": CLLocationCoordinate2D(latitude: 33.5138, longitude: 36.2765),  // Syria - Damascus
        "TW": CLLocationCoordinate2D(latitude: 25.0330, longitude: 121.5654), // Taiwan - Taipei
        "TJ": CLLocationCoordinate2D(latitude: 38.5598, longitude: 68.7740),  // Tajikistan - Dushanbe
        "TH": CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018), // Thailand - Bangkok
        "TL": CLLocationCoordinate2D(latitude: -8.5569, longitude: 125.5603), // Timor-Leste - Dili
        "TR": CLLocationCoordinate2D(latitude: 39.9334, longitude: 32.8597),  // Turkey - Ankara
        "TM": CLLocationCoordinate2D(latitude: 37.9601, longitude: 58.3261),  // Turkmenistan - Ashgabat
        "AE": CLLocationCoordinate2D(latitude: 24.4539, longitude: 54.3773),  // UAE - Abu Dhabi
        "UZ": CLLocationCoordinate2D(latitude: 41.2995, longitude: 69.2401),  // Uzbekistan - Tashkent
        "VN": CLLocationCoordinate2D(latitude: 21.0278, longitude: 105.8342), // Vietnam - Hanoi
        "YE": CLLocationCoordinate2D(latitude: 15.3694, longitude: 44.1910),  // Yemen - Sanaa

        // Africa
        "DZ": CLLocationCoordinate2D(latitude: 36.7538, longitude: 3.0588),   // Algeria - Algiers
        "AO": CLLocationCoordinate2D(latitude: -8.8390, longitude: 13.2894),  // Angola - Luanda
        "BJ": CLLocationCoordinate2D(latitude: 6.4969, longitude: 2.6289),    // Benin - Porto-Novo
        "BW": CLLocationCoordinate2D(latitude: -24.6282, longitude: 25.9231), // Botswana - Gaborone
        "CM": CLLocationCoordinate2D(latitude: 3.8480, longitude: 11.5021),   // Cameroon - Yaounde
        "TD": CLLocationCoordinate2D(latitude: 12.1348, longitude: 15.0557),  // Chad - N'Djamena
        "CD": CLLocationCoordinate2D(latitude: -4.4419, longitude: 15.2663),  // DR Congo - Kinshasa
        "EG": CLLocationCoordinate2D(latitude: 30.0444, longitude: 31.2357),  // Egypt - Cairo
        "ET": CLLocationCoordinate2D(latitude: 9.0320, longitude: 38.7469),   // Ethiopia - Addis Ababa
        "GH": CLLocationCoordinate2D(latitude: 5.6037, longitude: -0.1870),   // Ghana - Accra
        "KE": CLLocationCoordinate2D(latitude: -1.2921, longitude: 36.8219),  // Kenya - Nairobi
        "LY": CLLocationCoordinate2D(latitude: 32.8872, longitude: 13.1913),  // Libya - Tripoli
        "MG": CLLocationCoordinate2D(latitude: -18.8792, longitude: 47.5079), // Madagascar - Antananarivo
        "MW": CLLocationCoordinate2D(latitude: -13.9626, longitude: 33.7741), // Malawi - Lilongwe
        "MA": CLLocationCoordinate2D(latitude: 33.9716, longitude: -6.8498),  // Morocco - Rabat
        "MZ": CLLocationCoordinate2D(latitude: -25.9692, longitude: 32.5732), // Mozambique - Maputo
        "NA": CLLocationCoordinate2D(latitude: -22.5609, longitude: 17.0658), // Namibia - Windhoek
        "NG": CLLocationCoordinate2D(latitude: 9.0765, longitude: 7.3986),    // Nigeria - Abuja
        "RW": CLLocationCoordinate2D(latitude: -1.9403, longitude: 29.8739),  // Rwanda - Kigali
        "SN": CLLocationCoordinate2D(latitude: 14.7167, longitude: -17.4677), // Senegal - Dakar
        "ZA": CLLocationCoordinate2D(latitude: -25.7479, longitude: 28.2293), // South Africa - Pretoria
        "SD": CLLocationCoordinate2D(latitude: 15.5007, longitude: 32.5599),  // Sudan - Khartoum
        "TZ": CLLocationCoordinate2D(latitude: -6.7924, longitude: 39.2083),  // Tanzania - Dar es Salaam
        "TN": CLLocationCoordinate2D(latitude: 36.8065, longitude: 10.1815),  // Tunisia - Tunis
        "UG": CLLocationCoordinate2D(latitude: 0.3476, longitude: 32.5825),   // Uganda - Kampala
        "ZM": CLLocationCoordinate2D(latitude: -15.3875, longitude: 28.3228), // Zambia - Lusaka
        "ZW": CLLocationCoordinate2D(latitude: -17.8292, longitude: 31.0522), // Zimbabwe - Harare

        // Oceania
        "AU": CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093), // Australia - Sydney
        "FJ": CLLocationCoordinate2D(latitude: -18.1416, longitude: 178.4419), // Fiji - Suva
        "NZ": CLLocationCoordinate2D(latitude: -41.2865, longitude: 174.7762), // New Zealand - Wellington
        "PG": CLLocationCoordinate2D(latitude: -9.4438, longitude: 147.1803),  // Papua New Guinea
        "WS": CLLocationCoordinate2D(latitude: -13.8506, longitude: -171.7513) // Samoa - Apia
    ]

    private let fallbackLocation = CLLocationCoordinate2D(latitude: 32.0853, longitude: 34.7818) // Tel Aviv as default

    var startLocation: CLLocationCoordinate2D {
        // Get country from device locale (multiple fallback methods)
        var countryCode: String = "US"

        // Try region identifier first
        if let region = Locale.current.region?.identifier {
            countryCode = region
        }
        // Fallback: try to get from locale identifier (e.g., "en_DE" -> "DE")
        else if let regionFromLocale = Locale.current.identifier.split(separator: "_").last {
            countryCode = String(regionFromLocale)
        }
        // Fallback: check preferred languages
        else if let firstLang = Locale.preferredLanguages.first,
                let region = Locale(identifier: firstLang).region?.identifier {
            countryCode = region
        }

        print("TracerouteService: Detected country code: \(countryCode)")
        return countryCoordinates[countryCode.uppercased()] ?? fallbackLocation
    }

    private let destinations = [
        CLLocationCoordinate2D(latitude: 39.0438, longitude: -77.4874), // Ashburn, VA
        CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),  // London
        CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503), // Tokyo
        CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198),  // Singapore
        CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093) // Sydney
    ]
    
    func traceroute(to destination: String, targetCoordinate: CLLocationCoordinate2D? = nil) {
        isRunning = true
        hops.removeAll()

        traceTask = Task {
            var discoveredHops: [TracerouteHop] = []

            // Use provided coordinate or pick a random destination coordinate
            let targetCoord = targetCoordinate ?? destinations.randomElement()!
            
            // First, try to resolve the destination
            let finalIP = await resolveHostname(destination)
            
            // Simulate intermediate hops with realistic latencies and coordinates
            let intermediateHops = generateIntermediateHops(to: destination, finalIP: finalIP, targetCoord: targetCoord)
            
            for (index, hopInfo) in intermediateHops.enumerated() {
                guard !Task.isCancelled else { break }
                
                let hopNumber = index + 1
                let hop = TracerouteHop(
                    hopNumber: hopNumber,
                    host: hopInfo.host,
                    ip: hopInfo.ip,
                    latencyMs: hopInfo.latency,
                    status: hopInfo.status,
                    coordinate: hopInfo.coordinate,
                    countryCode: hopInfo.coordinate.flatMap { nearestCountryCode(for: $0) }
                )
                
                discoveredHops.append(hop)
                
                await MainActor.run {
                    self.hops.append(hop)
                }
                
                // Small delay between hops for visual effect
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                // Stop if we reached the destination
                if hopInfo.isDestination {
                    break
                }
            }
            
            await MainActor.run {
                self.currentResult = TracerouteResult(
                    destination: destination,
                    hops: discoveredHops,
                    totalHops: discoveredHops.count,
                    timestamp: Date(),
                    isComplete: true
                )
                self.isRunning = false
            }
        }
    }
    
    private func resolveHostname(_ hostname: String) async -> String {
        // Try to resolve hostname to IP
        guard let host = hostname.components(separatedBy: ":").first else {
            return hostname
        }
        
        // Simple IP check
        if host.contains(".") && host.split(separator: ".").count == 4 {
            return host
        }
        
        // For demo purposes, return the hostname
        return hostname
    }
    
    private func generateIntermediateHops(to destination: String, finalIP: String, targetCoord: CLLocationCoordinate2D) -> [(host: String, ip: String?, latency: Double?, status: TracerouteHop.HopStatus, isDestination: Bool, coordinate: CLLocationCoordinate2D?)] {
        var hops: [(host: String, ip: String?, latency: Double?, status: TracerouteHop.HopStatus, isDestination: Bool, coordinate: CLLocationCoordinate2D?)] = []
        
        // Simulate realistic network path with 8-15 hops
        let numHops = Int.random(in: 8...15)
        var currentLatency = Double.random(in: 1...5)
        
        // Calculate step for coordinate interpolation
        let latStep = (targetCoord.latitude - startLocation.latitude) / Double(numHops)
        let lonStep = (targetCoord.longitude - startLocation.longitude) / Double(numHops)
        
        // First hop: My Location
        hops.append((
            host: "My Location",
            ip: nil,
            latency: 0,
            status: .success,
            isDestination: false,
            coordinate: startLocation
        ))
        
        // Generate intermediate hops
        for i in 1..<numHops {
            // Interpolate coordinate with some noise
            let noiseLat = Double.random(in: -2...2)
            let noiseLon = Double.random(in: -2...2)
            let lat = startLocation.latitude + (latStep * Double(i)) + noiseLat
            let lon = startLocation.longitude + (lonStep * Double(i)) + noiseLon
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            currentLatency += Double.random(in: 2...10)
            
            if Int.random(in: 1...10) == 1 {
                // Timeout hop
                 hops.append((
                    host: "Timeout",
                    ip: nil,
                    latency: nil,
                    status: .timeout,
                    isDestination: false,
                    coordinate: coord
                ))
            } else {
                hops.append((
                    host: "hop-\(i).backbone.net",
                    ip: "\(Int.random(in: 1...255)).\(Int.random(in: 1...255)).\(Int.random(in: 1...255)).\(Int.random(in: 1...255))",
                    latency: currentLatency,
                    status: .success,
                    isDestination: false,
                    coordinate: coord
                ))
            }
        }
        
        // Final destination
        currentLatency += Double.random(in: 1...5)
        hops.append((
            host: destination,
            ip: finalIP,
            latency: currentLatency,
            status: .success,
            isDestination: true,
            coordinate: targetCoord
        ))
        
        return hops
    }
    
    func nearestCountryCode(for coordinate: CLLocationCoordinate2D) -> String? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        var closest: (code: String, distance: CLLocationDistance)? = nil
        for (code, coord) in countryCoordinates {
            let dist = location.distance(from: CLLocation(latitude: coord.latitude, longitude: coord.longitude))
            if closest == nil || dist < closest!.distance {
                closest = (code, dist)
            }
        }
        return closest?.code
    }

    func stopTraceroute() {
        traceTask?.cancel()
        isRunning = false
    }
}
