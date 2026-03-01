import Foundation

class TaskStore {
    static let shared = TaskStore()
    private let fileURL: URL
    
    init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documentsDirectory.appendingPathComponent("tasks_store.json")
    }
    
    func save(tasks: [TaskItem]) {
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save tasks: \(error.localizedDescription)")
        }
    }
    
    func load() -> [TaskItem] {
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([TaskItem].self, from: data)
        } catch {
            print("No existing tasks found or failed to load. Starting fresh.")
            return []
        }
    }
}
