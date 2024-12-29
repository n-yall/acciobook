import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    public func getAudiobooks(completion: @escaping (Result<[AudioTrack], Error>) -> Void) {
        guard let path = Bundle.main.url(forResource: "proj_json", withExtension: "json") else {
            return
        }
        do {
            let data = try Data(contentsOf: path)
            let result = try JSONDecoder().decode([AudioTrack].self, from: data)
            completion(.success(result))
        } catch {
            completion(.failure(error))
        }
    }
}
