import Foundation

final class TaskStore {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(filename: String = "tasks.json") {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = docs.appendingPathComponent(filename)

        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()

        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func load() -> [TaskItem] {
        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode([TaskItem].self, from: data)
        } catch {
            return []
        }
    }

    func save(_ tasks: [TaskItem]) {
        do {
            let data = try encoder.encode(tasks)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Failed to save tasks: \(error)")
        }
    }
}
