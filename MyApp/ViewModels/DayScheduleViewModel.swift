import Foundation
import SwiftUI

@MainActor
final class DayScheduleViewModel: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []

    let pixelsPerMinute: CGFloat = 1.4
    let minuteSnap: Int = 5

    private let store: TaskStore
    private let calendar = Calendar.current

    init(store: TaskStore = TaskStore()) {
        self.store = store
        self.tasks = store.load().sorted(by: { $0.startTime < $1.startTime })
    }

    // MARK: - CRUD
    func addTask(_ task: TaskItem) {
        tasks.append(task)
        sortAndPersist()
    }

    func updateTask(_ updated: TaskItem) {
        guard let idx = tasks.firstIndex(where: { $0.id == updated.id }) else { return }
        tasks[idx] = updated
        sortAndPersist()
    }

    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        sortAndPersist()
    }

    // MARK: - Layout Helpers
    func minutesSinceMidnight(for date: Date) -> Int {
        let comps = calendar.dateComponents([.hour, .minute], from: date)
        return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    }

    func yPosition(for task: TaskItem) -> CGFloat {
        CGFloat(minutesSinceMidnight(for: task.startTime)) * pixelsPerMinute
    }

    func height(for task: TaskItem) -> CGFloat {
        max(24, CGFloat(task.durationMinutes) * pixelsPerMinute)
    }

    func timelineHeight() -> CGFloat {
        CGFloat(24 * 60) * pixelsPerMinute
    }

    func hourLabel(for hour: Int) -> String {
        String(format: "%02d:00", hour)
    }

    // MARK: - Drag / Reschedule
    func reschedule(task: TaskItem, byDragYOffset offset: CGFloat) {
        let deltaMinutes = Int((offset / pixelsPerMinute).rounded())
        let originalMinutes = minutesSinceMidnight(for: task.startTime)
        var newMinutes = originalMinutes + deltaMinutes

        newMinutes = max(0, min(23 * 60 + 59, newMinutes))
        newMinutes = snap(minutes: newMinutes, step: minuteSnap)

        let newDate = dateToday(atMinutesSinceMidnight: newMinutes)
        var updated = task
        updated.startTime = newDate
        updateTask(updated)
    }

    func dateToday(atMinutesSinceMidnight minutes: Int) -> Date {
        let start = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .minute, value: minutes, to: start) ?? start
    }

    private func snap(minutes: Int, step: Int) -> Int {
        let remainder = minutes % step
        let down = minutes - remainder
        let up = down + step
        return (minutes - down) < (up - minutes) ? down : up
    }

    private func sortAndPersist() {
        tasks.sort { $0.startTime < $1.startTime }
        store.save(tasks)
    }
}
