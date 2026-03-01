import SwiftUI

struct TaskBlockView: View {
    let task: TaskItem
    let height: CGFloat
    let onTap: () -> Void
    let onToggleComplete: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            // 1. Icon & Duration Tail (Centered on the background line)
            ZStack(alignment: .top) {
                // Duration Capsule Tail
                if height > 44 {
                    Capsule()
                        .fill(task.color.opacity(task.isCompleted ? 0.3 : 0.8))
                        .frame(width: 14, height: height)
                } else {
                    Circle()
                        .fill(task.color.opacity(task.isCompleted ? 0.3 : 0.8))
                        .frame(width: 44, height: 44)
                }
                
                // Head Circle with Icon
                Circle()
                    .fill(task.isCompleted ? task.color.opacity(0.5) : task.color)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: task.isCompleted ? "checkmark" : (task.icon ?? "doc.text.fill"))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 44)
            
            // 2. Text Content
            VStack(alignment: .leading, spacing: 4) {
                let endTime = task.startTime.addingTimeInterval(task.duration)
                HStack(spacing: 4) {
                    Text("\(task.startTime.formatted(date: .omitted, time: .shortened)) - \(endTime.formatted(date: .omitted, time: .shortened))")
                    Text("(\(Int(task.durationMinutes)) min)")
                }
                .font(.caption)
                .foregroundColor(.gray)
                
                Text(task.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                    .strikethrough(task.isCompleted)
            }
            .padding(.top, 4)
            
            Spacer(minLength: 0)
            
            // 3. Completion Checkbox (Right side)
            Button(action: onToggleComplete) {
                Circle()
                    .strokeBorder(task.isCompleted ? task.color : Color.gray.opacity(0.3), lineWidth: 2)
                    .background(Circle().fill(task.isCompleted ? task.color : Color.clear))
                    .frame(width: 26, height: 26)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.white)
                            .opacity(task.isCompleted ? 1 : 0)
                    )
            }
            .padding(.top, 8)
            .padding(.trailing, 16)
        }
        .frame(height: max(height, 44), alignment: .top)
        .contentShape(Rectangle()) // Makes the whole row tappable/draggable
        .onTapGesture(perform: onTap)
    }
}
