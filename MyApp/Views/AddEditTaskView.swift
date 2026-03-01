import SwiftUI

struct AddEditTaskView: View {
    @Environment(\.dismiss) private var dismiss

    let existingTask: TaskItem?
    let onSave: (TaskItem) -> Void
    let onDelete: ((TaskItem) -> Void)?

    @State private var title: String = ""
    @State private var startTime: Date = Date()
    @State private var durationMinutes: Double = 60
    @State private var colorHex: String = "#7BC6FF"
    @State private var icon: String = ""

    private let colors = ["#7BC6FF", "#9FE3B1", "#FFC58F", "#E6A4FF", "#FFD7E2", "#FFE68A"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $title)
                    TextField("SF Symbol (optional)", text: $icon)
                }

                Section("Time") {
                    DatePicker("Start", selection: $startTime, displayedComponents: [.hourAndMinute])
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text("\(Int(durationMinutes)) min")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $durationMinutes, in: 5...300, step: 5)
                }

                Section("Color") {
                    HStack {
                        ForEach(colors, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle().stroke(colorHex == hex ? Color.primary : .clear, lineWidth: 2)
                                )
                                .onTapGesture { colorHex = hex }
                        }
                    }
                }

                if let existingTask, let onDelete {
                    Section {
                        Button(role: .destructive) {
                            onDelete(existingTask)
                            dismiss()
                        } label: {
                            Text("Delete Task")
                        }
                    }
                }
            }
            .navigationTitle(existingTask == nil ? "New Task" : "Edit Task")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let task = TaskItem(
                            id: existingTask?.id ?? UUID(),
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled Task" : title,
                            startTime: mergeDateWithTodayTime(startTime),
                            duration: durationMinutes * 60,
                            colorHex: colorHex,
                            icon: icon.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : icon
                        )
                        onSave(task)
                        dismiss()
                    }
                }
            }
            .onAppear(perform: loadExisting)
        }
    }

    private func loadExisting() {
        guard let task = existingTask else { return }
        title = task.title
        startTime = task.startTime
        durationMinutes = task.durationMinutes
        colorHex = task.colorHex
        icon = task.icon ?? ""
    }

    private func mergeDateWithTodayTime(_ date: Date) -> Date {
        let cal = Calendar.current
        let hm = cal.dateComponents([.hour, .minute], from: date)
        return cal.date(bySettingHour: hm.hour ?? 0, minute: hm.minute ?? 0, second: 0, of: Date()) ?? Date()
    }
}
