import SwiftUI

struct AddEditTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DayScheduleViewModel
    var taskToEdit: TaskItem?
    
    @State private var title: String = ""
    @State private var startTime: Date = Date()
    @State private var durationMinutes: Int = 60
    @State private var color: Color = .blue
    @State private var icon: String = "circle.fill"
    
    // Standard pastel-like colors for tasks
    let colors: [Color] = [.blue, .purple, .pink, .red, .orange, .yellow, .green, .mint, .cyan, .gray]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("What do you want to do?", text: $title)
                    
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    
                    Stepper("Duration: \(durationMinutes) min", value: $durationMinutes, in: 5...720, step: 5)
                }
                
                Section(header: Text("Appearance")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colors, id: \.self) { clr in
                                Circle()
                                    .fill(clr)
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: color == clr ? 2 : 0)
                                    )
                                    .onTapGesture {
                                        color = clr
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                if taskToEdit != nil {
                    Section {
                        Button("Delete Task", role: .destructive) {
                            if let task = taskToEdit {
                                viewModel.deleteTask(task)
                            }
                            dismiss()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle(taskToEdit == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveTask() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear(perform: setupForm)
        }
    }
    
    private func setupForm() {
        if let task = taskToEdit {
            title = task.title
            startTime = task.startTime
            durationMinutes = Int(task.duration / 60)
            color = task.color
            icon = task.icon ?? "circle.fill"
        } else {
            // Snap default start time to the next 5-minute interval
            let current = Date()
            let calendar = Calendar.current
            var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: current)
            let currentMinute = comps.minute ?? 0
            comps.minute = ((currentMinute + 4) / 5) * 5 // Round up to nearest 5
            startTime = calendar.date(from: comps) ?? current
        }
    }
    
    private func saveTask() {
        let newTask = TaskItem(
            id: taskToEdit?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            startTime: startTime,
            duration: TimeInterval(durationMinutes * 60),
            colorHex: color.toHex() ?? "#3478F6",
            icon: icon
        )
        
        if taskToEdit != nil {
            viewModel.updateTask(newTask)
        } else {
            viewModel.addTask(newTask)
        }
        dismiss()
    }
}
