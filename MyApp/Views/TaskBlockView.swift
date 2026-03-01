import SwiftUI

struct TaskBlockView: View {
    let task: TaskItem
    let height: CGFloat
    let onTap: () -> Void
    let onToggleComplete: () -> Void
    
    let pillWidth: CGFloat = 48
    let darkBackground = Color(red: 0.1, green: 0.1, blue: 0.12)
    
    var body: some View {
        // Aligned back to the center as requested
        HStack(alignment: .center, spacing: 16) {
            
            // 1. The Unified Pill Shape
            ZStack(alignment: .center) {
                Capsule()
                    .fill(task.isCompleted ? task.color.opacity(0.3) : task.color)
                    .frame(width: pillWidth, height: max(height, pillWidth))
                
                Image(systemName: task.isCompleted ? "checkmark" : (task.icon ?? "doc.text.fill"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(task.isCompleted ? task.color : .white)
            }
            // THE CUTOUT TRICK: This thick dark stroke matches the timeline background,
            // naturally erasing the dotted line and any pills underneath it!
            .overlay(
                Capsule()
                    .stroke(darkBackground, lineWidth: 6)
            )
            .frame(width: pillWidth, height: max(height, pillWidth), alignment: .center)
            
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
            .padding(.trailing, 16)
        }
        .frame(height: max(height, pillWidth), alignment: .center)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
