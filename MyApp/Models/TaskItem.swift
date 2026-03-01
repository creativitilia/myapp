import Foundation
import SwiftUI

struct TaskItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var startTime: Date
    var duration: TimeInterval // seconds
    var colorHex: String
    var icon: String?
    var isCompleted: Bool // NEW

    init(
        id: UUID = UUID(),
        title: String,
        startTime: Date,
        duration: TimeInterval,
        colorHex: String = "#FFB3B3", // Soft red as default to match v2.0
        icon: String? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.duration = duration
        self.colorHex = colorHex
        self.icon = icon
        self.isCompleted = isCompleted
    }

    var durationMinutes: Double {
        duration / 60.0
    }
}
