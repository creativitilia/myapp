import Foundation
import SwiftUI
import Combine

class DayScheduleViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    
    // Layout logic: 1.5 points per minute = 90 points per hour height
    let pixelsPerMinute: CGFloat = 1.5
    
    init() {
        loadTasks()
    }
    
    // MARK: - CRUD Operations
    func loadTasks() {
        self.tasks = TaskStore.shared.load().sorted { $0.startTime < $1.startTime }
    }
    
    func saveTasks() {
        TaskStore.shared.save(tasks: self.tasks)
    }
    
    func addTask(_ task: TaskItem) {
        tasks.append(task)
        sortAndSave()
    }
    
    func updateTask(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            sortAndSave()
        }
    }
    
    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func updateTaskStartTime(id: UUID, newStartTime: Date) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].startTime = newStartTime
            sortAndSave()
        }
    }
    
    private func sortAndSave() {
        tasks.sort { $0.startTime < $1.startTime }
        saveTasks()
    }
    
    // MARK: - Positioning & Time Math
    func minutesSinceMidnight(for date: Date) -> CGFloat {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return CGFloat((components.hour ?? 0) * 60 + (components.minute ?? 0))
    }
    
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    func dateFromMinutesSinceMidnight(_ minutes: CGFloat) -> Date {
        let start = startOfDay()
        return Calendar.current.date(byAdding: .minute, value: Int(minutes), to: start) ?? start
    }
}
