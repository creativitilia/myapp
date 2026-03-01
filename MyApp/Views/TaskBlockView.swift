import SwiftUI

struct TaskBlockView: View {
    let task: TaskItem
    let height: CGFloat
    let onTap: () -> Void
    let onToggleComplete: () -> Void
    
    // Minimum height for a task block to remain tappable/readable
    let minHeight: CGFloat = 50
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            // 1. Unified Capsule (The Pill)
            ZStack {
                Capsule()
                    .fill(task.isCompleted ? task.color.opacity(0.3) : task.color)
                    .frame(width: 44, height: max(height, minHeight))
                
                // Keep the icon pinned to the top of the capsule
                VStack {
                    Image(systemName: task.isCompleted ? "checkmark" : (task.icon ?? "doc.text.fill"))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44) // Gives the icon a fixed square area at the top
                    Spacer(minLength: 0)
                }
            }
            .frame(width: 44, height: max(height, minHeight))
            
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
            .padding(.top, 12) // Push text down slightly to align with the icon
            
            Spacer(minLength: 0)
            
            // 3. Completion Checkbox
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
            .padding(.top, 12) // Align checkbox with text
            .padding(.trailing, 16)
        }
        .frame(height: max(height, minHeight), alignment: .top)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
