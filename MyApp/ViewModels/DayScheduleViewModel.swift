import Foundation
import SwiftUI
import Combine

// Determines exactly where and how a task should be drawn
struct TaskLayout {
    let task: TaskItem
    let yPos: CGFloat
    let height: CGFloat
    let zIndex: Double
    let showOverlapWarning: Bool
    let warningYPos: CGFloat
}

final class DayScheduleViewModel: ObservableObject {
    @Published private var allTasks: [TaskItem] = []
    
    @Published var selectedDate: Date = Date()
    @Published var currentTime: Date = Date()
    
    let pixelsPerMinute: CGFloat = 2.0
    let minuteSnap: Int = 5
    let timeColumnWidth: CGFloat = 65

    private let store: TaskStore
    let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()

    init(store: TaskStore = TaskStore()) {
        self.store = store
        self.allTasks = store.load().sorted(by: { $0.startTime < $1.startTime })
        
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.currentTime = date
            }
            .store(in: &cancellables)
    }
    
    var tasks: [TaskItem] {
        allTasks.filter { calendar.isDate($0.startTime, inSameDayAs: selectedDate) }
    }

    func tasksFor(date: Date) -> [TaskItem] {
        allTasks.filter { calendar.isDate($0.startTime, inSameDayAs: date) }
    }
    
    // MARK: - THE OVERLAP ENGINE
    var layoutAttributes: [TaskLayout] {
        var layouts = [TaskLayout]()
        let dayTasks = tasks.sorted { $0.startTime < $1.startTime }
        
        var prevY: CGFloat = 0
        var prevHeight: CGFloat = 0
        var staggerCount = 0
        
        for (index, task) in dayTasks.enumerated() {
            var y = yPosition(for: task.startTime)
            let h = height(for: task)
            var showWarning = false
            var warnY: CGFloat = 0
            
            if index > 0 {
                let prevTask = dayTasks[index - 1]
                let prevEnd = prevTask.startTime.addingTimeInterval(prevTask.duration)
                
                // Overlap detected!
                if task.startTime < prevEnd {
                    showWarning = true
                    
                    // If they start at the exact same time, artificially push this one down to stack them
                    if task.startTime == prevTask.startTime {
                        staggerCount += 1
                        y = prevY + 48 // Push down by pill height so titles don't collide
                    } else {
                        staggerCount = 0
                    }
                    
                    // Calculate perfectly centered Y for the "Tasks are overlapping" text
                    let prevCenter = prevY + (prevHeight / 2)
                    let currentCenter = y + (h / 2)
                    warnY = ((prevCenter + currentCenter) / 2) - 8 // -8 to visually center the font height
                } else {
                    staggerCount = 0
                }
            }
            
            layouts.append(TaskLayout(
                task: task,
                yPos: y,
                height: h,
                zIndex: Double(-index), // Earlier tasks get higher Z-Index to overlap later tasks
                showOverlapWarning: showWarning,
                warningYPos: warnY
            ))
            
            prevY = y
            prevHeight = h
        }
        return layouts
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
    
    private func sortAndPersist() {
        allTasks.sort(by: { $0.startTime < $1.startTime })
        store.save(allTasks)
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
}
