import Foundation
import SwiftUI
import Combine

@MainActor
final class DayScheduleViewModel: ObservableObject {
    // Keep all tasks in memory, but publish the ones for the selected date
    @Published private var allTasks: [TaskItem] = []
    
    @Published var selectedDate: Date = Date()
    @Published var currentTime: Date = Date()
    
    // Increased to 2.0 to match the spacious, tall design of v2.0
    let pixelsPerMinute: CGFloat = 2.0
    let minuteSnap: Int = 5
    let timeColumnWidth: CGFloat = 65

    private let store: TaskStore
    let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()

    init(store: TaskStore = TaskStore()) {
        self.store = store
        self.allTasks = store.load().sorted(by: { $0.startTime < $1.startTime })
        
        // Timer for the "Current Time" red line indicator
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.currentTime = date
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    var tasks: [TaskItem] {
        allTasks.filter { calendar.isDate($0.startTime, inSameDayAs: selectedDate) }
    }

    // MARK: - CRUD
    func addTask(_ task: TaskItem) {
        allTasks.append(task)
        sortAndPersist()
    }

    func updateTask(_ updated: TaskItem) {
        guard let idx = allTasks.firstIndex(where: { $0.id == updated.id }) else { return }
        allTasks[idx] = updated
        sortAndPersist()
    }

    func deleteTask(_ task: TaskItem) {
        allTasks.removeAll { $0.id == task.id }
        sortAndPersist()
    }
    
    func toggleCompletion(for task: TaskItem) {
        if let idx = allTasks.firstIndex(where: { $0.id == task.id }) {
            allTasks[idx].isCompleted.toggle()
            sortAndPersist()
        }
    }

    // MARK: - Layout Helpers
    func minutesSinceMidnight(for date: Date) -> Int {
        let comps = calendar.dateComponents([.hour, .minute], from: date)
        return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    }

    func yPosition(for date: Date) -> CGFloat {
        CGFloat(minutesSinceMidnight(for: date)) * pixelsPerMinute
    }

    func height(for task: TaskItem) -> CGFloat {
        max(44, CGFloat(task.durationMinutes) * pixelsPerMinute)
    }

    func timelineHeight() -> CGFloat {
        CGFloat(24 * 60) * pixelsPerMinute
    }

    func hourLabel(for hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:00 a"
        let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }

    // MARK: - Drag / Reschedule
    func reschedule(task: TaskItem, byDragYOffset offset: CGFloat) {
        let deltaMinutes = Int((offset / pixelsPerMinute).rounded())
        let originalMinutes = minutesSinceMidnight(for: task.startTime)
        var newMinutes = originalMinutes + deltaMinutes

        newMinutes = max(0, min(23 * 60 + 59, newMinutes))
        newMinutes = snap(minutes: newMinutes, step: minuteSnap)

        let startOfDay = calendar.startOfDay(for: selectedDate)
        let newDate = calendar.date(byAdding: .minute, value: newMinutes, to: startOfDay) ?? startOfDay
        
        var updated = task
        updated.startTime = newDate
        updateTask(updated)
    }

    private func snap(minutes: Int, step: Int) -> Int {
        let remainder = minutes % step
        let down = minutes - remainder
        let up = down + step
        return (minutes - down) < (up - minutes) ? down : up
    }

    private func sortAndPersist() {
        allTasks.sort { $0.startTime < $1.startTime }
        store.save(allTasks)
    }
}
