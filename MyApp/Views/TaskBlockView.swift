import SwiftUI

struct TaskBlockView: View {
    let task: TaskItem
    let height: CGFloat
    let onTap: () -> Void
    let onToggleComplete: () -> Void
    
    // The width of the task pill in the timeline
    let pillWidth: CGFloat = 48
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            
            // 1. The Unified Pill Shape
            ZStack(alignment: .center) {
                // The main background capsule that stretches based on duration
                Capsule()
                    // REMOVED OPACITY: Now completely solid when not completed
                    .fill(task.isCompleted ? task.color.opacity(0.3) : task.color)
                    .frame(width: pillWidth, height: max(height, pillWidth))
                
                // The icon, perfectly centered in the capsule
                Image(systemName: task.isCompleted ? "checkmark" : (task.icon ?? "doc.text.fill"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(task.isCompleted ? task.color : .white)
            }
            // Add a white stroke around the whole pill to match the "Structured" app aesthetic
            .overlay(
                Capsule()
                    .stroke(Color.white, lineWidth: 2)
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
        .contentShape(Rectangle()) // Makes the whole row tappable
        .onTapGesture(perform: onTap)
    }
}
