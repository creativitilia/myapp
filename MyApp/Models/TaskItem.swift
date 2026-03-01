import Foundation
import SwiftUI

struct TaskItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var startTime: Date
    var duration: TimeInterval // seconds
    var colorHex: String
    var icon: String?

    init(
        id: UUID = UUID(),
        title: String,
        startTime: Date,
        duration: TimeInterval,
        colorHex: String = "#7BC6FF",
        icon: String? = nil
    ) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.duration = duration
        self.colorHex = colorHex
        self.icon = icon
    }

    var durationMinutes: Double {
        duration / 60.0
    }
}
