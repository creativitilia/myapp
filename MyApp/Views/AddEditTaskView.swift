import SwiftUI

// Struct to hold predefined task suggestions
struct TaskSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let colorHex: String
    let durationMinutes: Double
}

struct AddEditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: DayScheduleViewModel
    var taskToEdit: TaskItem?

    // Wizard State
    @State private var step: Int = 1
    
    // Task Properties
    @State private var title: String = ""
    @State private var startTime: Date = Date()
    @State private var durationMinutes: Double = 60
    @State private var notes: String = ""
    
    // UI States
    @State private var colorHex: String = "#E57373"
    @State private var icon: String = "checklist"
    @State private var showingColorPicker = false
    
    private let presetColors: [String] = [
        "#E57373", "#81C784", "#64B5F6", "#4FC3F7", "#7986CB",
        "#BA68C8", "#F06292", "#FFB74D", "#FF8A65"
    ]
    
    private let durations: [Double] = [5, 15, 30, 45, 60, 90, 120, 180]
    let darkBackground = Color(red: 0.1, green: 0.1, blue: 0.11)
    let cardBackground = Color(red: 0.15, green: 0.15, blue: 0.16)
    
    // Dynamic property that converts the hex string to a SwiftUI Color safely
    var themeColor: Color {
        Color(hex: colorHex) ?? Color(red: 0.9, green: 0.45, blue: 0.45)
    }
    
    // Hardcoded suggestions database
    let allSuggestions: [TaskSuggestion] = [
        TaskSuggestion(title: "Answer Emails", icon: "envelope.fill", colorHex: "#E57373", durationMinutes: 15),
        TaskSuggestion(title: "Watch a Movie", icon: "tv.fill", colorHex: "#64B5F6", durationMinutes: 120),
        TaskSuggestion(title: "Go for a Run", icon: "figure.run", colorHex: "#81C784", durationMinutes: 60),
        TaskSuggestion(title: "Go Shopping", icon: "cart.fill", colorHex: "#FFB74D", durationMinutes: 60),
        TaskSuggestion(title: "Read a Book", icon: "book.fill", colorHex: "#BA68C8", durationMinutes: 45),
        TaskSuggestion(title: "Wind Down", icon: "moon.fill", colorHex: "#7986CB", durationMinutes: 30)
    ]
    
    // Dynamically filter suggestions based on what the user types
    var filteredSuggestions: [TaskSuggestion] {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return allSuggestions }
        return allSuggestions.filter { $0.title.lowercased().contains(title.lowercased()) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - TWO TONE HEADER
            VStack(alignment: .leading, spacing: 0) {
                // Top Bar (Cancel/Back & Ellipsis)
                HStack {
                    if step > 1 && taskToEdit == nil {
                        Button(action: handleBackButton) {
                            Image(systemName: "chevron.left")
                                .font(.body.weight(.bold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    } else {
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Capsule())
                        }
                    }
                    Spacer()
                    
                    if step == 3 {
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .font(.body.weight(.bold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                // Icon & Title Area
                HStack(alignment: step == 3 ? .top : .center, spacing: 16) {
                    headerIcon
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if step > 1 {
                            let endTime = startTime.addingTimeInterval(durationMinutes * 60)
                            Text("\(startTime.formatted(date: .omitted, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        TextField("", text: $title, prompt: Text("Task Title").foregroundColor(.white.opacity(0.5)))
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                            .tint(.white)
                            .onChange(of: title) { _, newValue in
                                if step == 1 {
                                    if !filteredSuggestions.contains(where: { $0.title.lowercased() == newValue.lowercased() }) {
                                        icon = "checkmark.circle.fill"
                                    }
                                }
                            }
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(height: 1)
                    }
                    
                    if step == 2 {
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .frame(height: 180)
            .background(themeColor.ignoresSafeArea(edges: .top))
            .animation(.spring(), value: step)
            .animation(.spring(), value: themeColor)
            
            // MARK: - TWO TONE BODY
            ZStack(alignment: .top) {
                darkBackground.ignoresSafeArea()
                
                Group {
                    if step == 1 {
                        step1Body
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    } else if step == 2 {
                        step2Body
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    } else {
                        step3Body
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: step)
            }
            
            // MARK: - FOOTER BUTTON
            VStack {
                Button {
                    if step < 3 {
                        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { title = "New Task" }
                        withAnimation { step += 1 }
                    } else {
                        saveTask()
                    }
                } label: {
                    Text(step < 3 ? "Continue" : (taskToEdit == nil ? "Create Task" : "Save Changes"))
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(themeColor)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .padding(.top, 16)
            }
            .background(darkBackground)
        }
        .onAppear {
            if let task = taskToEdit {
                title = task.title
                startTime = task.startTime
                durationMinutes = task.durationMinutes
                colorHex = task.colorHex
                icon = task.icon ?? "checklist"
                step = 3 // Jump to confirmation for existing tasks
            }
        }
    }
}

// MARK: - Subviews & Steps
extension AddEditTaskView {
    
    private func handleBackButton() {
        if step > 1 {
            withAnimation { step -= 1 }
        } else {
            dismiss()
        }
    }
    
    // HEADER ICON ANIMATION
    @ViewBuilder
    var headerIcon: some View {
        ZStack(alignment: .bottomLeading) {
            if step == 3 {
                Path { path in
                    path.move(to: CGPoint(x: 32, y: -50))
                    path.addLine(to: CGPoint(x: 32, y: 150))
                }
                .stroke(Color.black.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
            }
            
            ZStack {
                if step == 3 {
                    Capsule()
                        .fill(Color(white: 0.25))
                        .frame(width: 64, height: 120)
                        .overlay(Capsule().stroke(Color.white, lineWidth: 3))
                } else {
                    Circle()
                        .fill(Color(white: 0.25))
                        .frame(width: 64, height: 64)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                }
                
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(themeColor)
                    .offset(y: step == 3 ? -15 : 0)
            }
            
            if step == 3 {
                Button(action: { withAnimation { showingColorPicker.toggle() } }) {
                    Circle()
                        .fill(darkBackground)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "paintpalette.fill")
                                .font(.caption)
                                .foregroundColor(themeColor)
                        )
                }
                .offset(x: -5, y: 5)
            }
        }
    }
    
    // STEP 1: SUGGESTIONS / RECENT
    var step1Body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if filteredSuggestions.isEmpty {
                    Text("No matching suggestions. A custom task will be created.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 40)
                } else {
                    ForEach(filteredSuggestions) { suggestion in
                        suggestionRow(suggestion: suggestion)
                    }
                }
            }
            .padding(.top, 30)
            .padding(.horizontal, 24)
        }
    }
    
    func suggestionRow(suggestion: TaskSuggestion) -> some View {
        HStack(spacing: 16) {
            Image(systemName: suggestion.icon)
                .font(.title2)
                .foregroundColor(Color(hex: suggestion.colorHex) ?? themeColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(formatDuration(suggestion.durationMinutes)) default")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(suggestion.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Divider().background(Color.gray.opacity(0.3)).padding(.top, 8)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.title = suggestion.title
            self.icon = suggestion.icon
            self.colorHex = suggestion.colorHex
            self.durationMinutes = suggestion.durationMinutes
            withAnimation { step = 2 }
        }
    }
    
    // STEP 2: TIME & DURATION
    var step2Body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // Interactive Date Picker
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(themeColor)
                DatePicker("", selection: $startTime, displayedComponents: .date)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .tint(themeColor)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            Divider().background(Color.gray.opacity(0.3)).padding(.horizontal, 24)
            
            // Time Picker
            VStack(alignment: .leading) {
                HStack {
                    Text("Time")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 24)
                
                DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .frame(height: 120)
                    .clipped()
                    .frame(maxWidth: .infinity)
            }
            
            // Duration Scroller
            VStack(alignment: .leading) {
                HStack {
                    Text("Duration")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 24)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(durations, id: \.self) { dur in
                            let isSelected = durationMinutes == dur
                            Text(formatDuration(dur))
                                .font(.subheadline.weight(isSelected ? .bold : .regular))
                                .foregroundColor(isSelected ? darkBackground : .gray)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(isSelected ? themeColor : Color.white.opacity(0.05))
                                .clipShape(Capsule())
                                .onTapGesture {
                                    withAnimation { durationMinutes = dur }
                                }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    
    // STEP 3: CONFIRMATION
    var step3Body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                if showingColorPicker {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(presetColors, id: \.self) { hex in
                                Circle()
                                    .fill(Color(hex: hex) ?? .white)
                                    .frame(width: 36, height: 36)
                                    .overlay(Circle().stroke(Color.white, lineWidth: colorHex == hex ? 3 : 0))
                                    .onTapGesture {
                                        withAnimation {
                                            colorHex = hex
                                            showingColorPicker = false
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                    }
                    .background(Color.black.opacity(0.2))
                    .transition(.opacity)
                }
                
                // Settings Block (Date, Time, Repeat, Alert)
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        Image(systemName: "calendar")
                            .foregroundColor(themeColor)
                            .frame(width: 24)
                        DatePicker("", selection: $startTime, displayedComponents: .date)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .tint(themeColor)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.gray).font(.caption)
                    }
                    .padding()
                    
                    Divider().background(Color.gray.opacity(0.3)).padding(.leading, 56)
                    
                    HStack(spacing: 16) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(themeColor)
                            .frame(width: 24)
                        DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .tint(themeColor)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.gray).font(.caption)
                    }
                    .padding()
                    
                    Divider().background(Color.gray.opacity(0.3)).padding(.leading, 56)
                    
                    detailRow(icon: "arrow.2.squarepath", title: "Every day", value: "PRO", isPro: true)
                        .padding()
                    
                    Divider().background(Color.gray.opacity(0.3)).padding(.leading, 56)
                    
                    detailRow(icon: "bell.slash.fill", title: "1 Alert", value: "Nudge")
                        .padding()
                }
                .background(cardBackground)
                .cornerRadius(16)
                
                // Notes Block
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "square")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                        Text("Add Subtask")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                    
                    Divider().background(Color.gray.opacity(0.3))
                    
                    ZStack(alignment: .topLeading) {
                        if notes.isEmpty {
                            Text("Add notes, meeting links or phone numbers...")
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                        }
                        TextEditor(text: $notes)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(minHeight: 120)
                    }
                }
                .background(cardBackground)
                .cornerRadius(16)
                
                // Delete Button
                if taskToEdit != nil {
                    Button(action: {
                        if let task = taskToEdit {
                            viewModel.deleteTask(task)
                        }
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete")
                        }
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(cardBackground)
                        .cornerRadius(16)
                    }
                }
            }
            .padding(24)
            .padding(.bottom, 60) // Extra padding to scroll past the footer button
        }
    }
    
    func detailRow(icon: String, title: String, value: String, isPro: Bool = false) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(themeColor)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            if isPro {
                HStack(spacing: 6) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill").font(.system(size: 8))
                        Text("PRO")
                    }
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(4)
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            } else {
                HStack(spacing: 8) {
                    Text(value)
                        .foregroundColor(.gray)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func saveTask() {
        let task = TaskItem(
            id: taskToEdit?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled Task" : title,
            startTime: startTime,
            duration: durationMinutes * 60,
            colorHex: colorHex,
            icon: icon,
            isCompleted: taskToEdit?.isCompleted ?? false
            // Note: If you want to persist the 'notes' string, you will need to add `notes: String?` to your `TaskItem` struct and pass it here!
        )
        
        if taskToEdit != nil {
            viewModel.updateTask(task)
        } else {
            viewModel.addTask(task)
        }
        dismiss()
    }
    
    private func formatDuration(_ minutes: Double) -> String {
        if minutes < 60 {
            return "\(Int(minutes)) min"
        } else if minutes.truncatingRemainder(dividingBy: 60) == 0 {
            return "\(Int(minutes / 60)) hr"
        } else {
            let hrs = Int(minutes / 60)
            let mins = Int(minutes.truncatingRemainder(dividingBy: 60))
            return "\(hrs) hr, \(mins) min"
        }
    }
}
