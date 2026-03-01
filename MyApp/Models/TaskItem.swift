import Foundation
import SwiftUI

enum RepeatFrequency: String, Codable, CaseIterable {
    case none = "Once"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

struct TaskItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var startTime: Date
    var duration: TimeInterval // seconds
    var colorHex: String
    var icon: String?
    var isCompleted: Bool = false
    var notes: String? = nil
    var repeatFrequency: RepeatFrequency = .none

    var durationMinutes: Double {
        duration / 60.0
    }
    
    // Helper to dynamically get SwiftUI Color
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

// MARK: - Color Hex Extensions for Persistence
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        self.init(red: Double((rgb & 0xFF0000) >> 16) / 255.0,
                  green: Double((rgb & 0x00FF00) >> 8) / 255.0,
                  blue: Double(rgb & 0x0000FF) / 255.0)
    }
    
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
