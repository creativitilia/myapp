import SwiftUI

struct TimeColumnView: View {
    @ObservedObject var vm: DayScheduleViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<25, id: \.self) { hour in
                Text(vm.hourLabel(for: hour == 24 ? 0 : hour))
                    .font(.caption2.weight(.medium))
                    .foregroundColor(Color.gray.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .frame(height: 60 * vm.pixelsPerMinute, alignment: .top)
                    .offset(y: -7) // Align visual center of text to the hour mark
            }
        }
        .frame(width: vm.timeColumnWidth)
    }
}
