import SwiftUI

struct TaskBlockView: View {
    let task: TaskItem
    let width: CGFloat
    let height: CGFloat
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                if let icon = task.icon, !icon.isEmpty {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(task.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(width: width, height: height, alignment: .topLeading)
        .background(Color(hex: task.colorHex))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
        .onTapGesture(perform: onTap)
    }
}
