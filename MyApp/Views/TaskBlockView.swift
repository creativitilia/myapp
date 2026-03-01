import SwiftUI

struct TaskBlockView: View {
    let task: TaskItem
    let height: CGFloat
    let onTap: () -> Void
    let onToggleComplete: () -> Void
    
    // The width of the task pill in the timeline
    let pillWidth: CGFloat = 48
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            // 1. The Unified Pill Shape
            ZStack(alignment: .top) {
                // The main background capsule that stretches based on duration
                Capsule()
                    .fill(task.color.opacity(task.isCompleted ? 0.3 : 0.8))
                    .frame(width: pillWidth, height: max(height, pillWidth))
                
                // The icon, perfectly centered horizontally AND vertically inside the visual "top circle" of the pill.
                Image(systemName: task.isCompleted ? "checkmark" : (task.icon ?? "doc.text.fill"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(task.isCompleted ? task.color : .white)
                    .frame(width: pillWidth, height: pillWidth)
            }
            // Add a white stroke around the whole pill to match the "Structured" app aesthetic
            .overlay(
                Capsule()
                    .stroke(Color.white, lineWidth: 2)
            )
            .frame(width: pillWidth, height: max(height, pillWidth), alignment: .top)
            
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
            .padding(.top, (pillWidth - 20) / 2) // Push text down to vertically align with the icon inside the pill
            
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
            .padding(.top, (pillWidth - 26) / 2) // Align checkbox with the top of the row
            .padding(.trailing, 16)
        }
        .frame(height: max(height, pillWidth), alignment: .top)
        .contentShape(Rectangle()) // Makes the whole row tappable
        .onTapGesture(perform: onTap)
    }
}
