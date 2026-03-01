import SwiftUI

struct TaskBlockView: View {
    var task: TaskItem
    @ObservedObject var viewModel: DayScheduleViewModel
    var onTap: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    
    var body: some View {
        let durationMinutes = CGFloat(task.duration / 60)
        let height = max(durationMinutes * viewModel.pixelsPerMinute, 30) // Ensure tiny tasks are tappable
        let baseOffset = viewModel.minutesSinceMidnight(for: task.startTime) * viewModel.pixelsPerMinute
        
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if let icon = task.icon, !icon.isEmpty {
                        Image(systemName: icon)
                            .font(.subheadline)
                    }
                    Text(task.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                let endTime = task.startTime.addingTimeInterval(task.duration)
                Text("\(task.startTime.formatted(date: .omitted, time: .shortened)) - \(endTime.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2)
                    .opacity(0.8)
            }
            .padding(10)
            Spacer(minLength: 0)
        }
        .frame(height: height, alignment: .top)
        .background(task.color.opacity(isDragging ? 0.9 : 0.75))
        .cornerRadius(12)
        .shadow(color: task.color.opacity(isDragging ? 0.4 : 0.1), radius: isDragging ? 10 : 3, y: isDragging ? 6 : 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(task.color.opacity(0.5), lineWidth: 1)
        )
        // Set the Y position exactly based on time + drag
        .offset(y: baseOffset + dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    isDragging = false
                    
                    // Calculate new time based on drag drop location
                    let totalMinutesMoved = value.translation.height / viewModel.pixelsPerMinute
                    let currentMinutes = viewModel.minutesSinceMidnight(for: task.startTime)
                    let newMinutesRaw = currentMinutes + totalMinutesMoved
                    
                    // Snap to the nearest 5-minute interval
                    let snappedMinutes = round(newMinutesRaw / 5.0) * 5.0
                    
                    // Clamp to prevent dropping before midnight or after the day ends
                    let clampedMinutes = max(0, min(snappedMinutes, 24 * 60 - CGFloat(task.duration / 60)))
                    
                    let newDate = viewModel.dateFromMinutesSinceMidnight(clampedMinutes)
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        dragOffset = 0
                        viewModel.updateTaskStartTime(id: task.id, newStartTime: newDate)
                    }
                }
        )
        .onTapGesture {
            onTap()
        }
    }
}
