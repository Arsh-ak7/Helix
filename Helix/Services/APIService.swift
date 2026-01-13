import Foundation

struct WgerResponse: Codable {
    let results: [WgerExercise]
}

struct WgerExercise: Codable {
    let id: Int
    let translations: [WgerTranslation]?
    let images: [WgerImage]?
    
    var name: String {
        if let englishTranslation = translations?.first(where: { $0.language == 2 }) {
            return englishTranslation.name
        }
        return translations?.first?.name ?? "Unknown Exercise"
    }
    
    var description: String? {
        if let englishTranslation = translations?.first(where: { $0.language == 2 }) {
            return englishTranslation.description
        }
        return translations?.first?.description
    }
    
    var mainImageUrl: String? {
        return images?.first?.image
    }
}

struct WgerTranslation: Codable {
    let language: Int
    let name: String
    let description: String?
}

struct WgerImage: Codable {
    let image: String // URL string
}

class APIService {
    static let shared = APIService()
    
    // Changed to exerciseinfo to get detailed translation data including names
    private let baseURL = "https://wger.de/api/v2/exerciseinfo/?language=2&limit=100" 
    
    func fetchExercises() async throws -> [WgerExercise] {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(WgerResponse.self, from: data)
        return response.results
    }
}
