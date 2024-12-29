import Foundation

struct AudioTrack: Codable {
    
    let title: String
    let author: String
    let imageURL: String
    let audioURL: String
    let duration: Int
    let segmentSeconds: [(Float, Float)]
    let transcript: String
    let sections: [Section]
    
    enum CodingKeys: String, CodingKey {
        case title
        case author
        case imageURL = "imageURL"
        case audioURL = "audioURL"
        case duration
        case segmentSeconds
        case transcript
        case sections
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.author = try container.decode(String.self, forKey: .author)
        self.imageURL = try container.decode(String.self, forKey: .imageURL)
        self.audioURL = try container.decode(String.self, forKey: .audioURL)
        self.duration = try container.decode(Int.self, forKey: .duration)
        self.transcript = try container.decode(String.self, forKey: .transcript)
        self.sections = try container.decode([Section].self, forKey: .sections)
        
        let segmentsData = try container.decode([[Float]].self, forKey: .segmentSeconds)
        self.segmentSeconds = try segmentsData.map { pair in
            guard pair.count == 2 else {
                throw DecodingError.dataCorruptedError(forKey: .segmentSeconds, in: container, debugDescription: "Invalid segment pair")
            }
            return (pair[0], pair[1])
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(author, forKey: .author)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(audioURL, forKey: .audioURL)
        try container.encode(duration, forKey: .duration)
        try container.encode(audioURL, forKey: .transcript)
        try container.encode(sections, forKey: .sections)
        
        let segmentsData = segmentSeconds.map { [$0.0, $0.1] }
        try container.encode(segmentsData, forKey: .segmentSeconds)
    }
}
