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
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: DayScheduleViewModel
    var taskToEdit: TaskItem?

    // Wizard State
    @State private var step: Int = 1
    
    // Task Properties
    @State private var title: String = ""
    @State private var startTime: Date = Date()
    @State private var durationMinutes: Double = 60
    @State private var notes: String = ""
    @State private var isCompleted: Bool = false
    @State private var repeatFreq: RepeatFrequency = .none
    
    // UI States
    @State private var colorHex: String = "#BA68C8" // Default to Purple like your screenshot
    @State private var icon: String = "book.fill"
    @State private var showingColorPicker = false
    
    private let presetColors: [String] = [
        "#E57373", "#81C784", "#64B5F6", "#4FC3F7", "#7986CB",
        "#BA68C8", "#F06292", "#FFB74D", "#FF8A65"
    ]
    
    private let durations: [Double] = [5, 15, 30, 45, 60, 90, 120, 180]
    
    // Adapts intelligently to Light/Dark mode
    var primaryBackground: Color {
        Color(UIColor.systemBackground)
    }
    
    var cardBackground: Color {
        Color(UIColor.secondarySystemBackground)
    }
    
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
                HStack(alignment: .center, spacing: 16) {
                    headerIcon
                        .frame(width: 64) // Prevent the background dotted line path from squeezing the text
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if step > 1 {
                            let endTime = startTime.addingTimeInterval(durationMinutes * 60)
                            Text("\(startTime.formatted(date: .omitted, time: .shortened)) - \(endTime.formatted(date: .omitted, time: .shortened)) (\(formatDuration(durationMinutes)))")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // Using an overlay with strikethrough if completed
                        ZStack(alignment: .leading) {
                            TextField("Task Title", text: $title)
                                .font(.title2.weight(.bold))
                                .foregroundColor(isCompleted ? .white.opacity(0.6) : .white)
                                .accentColor(.white)
                                .minimumScaleFactor(0.8)
                            
                            if isCompleted {
                                Rectangle()
                                    .fill(Color.white.opacity(0.6))
                                    .frame(height: 2)
                                    .padding(.trailing, 8)
                            }
                        }
                        
                        // Bottom underline
                        Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(height: 1)
                    }
                    
                    if step == 3 {
                        Spacer()
                        // Tappable checkmark circle
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                isCompleted.toggle()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: 2)
                                    .background(Circle().fill(isCompleted ? Color.white : Color.clear))
                                    .frame(width: 28, height: 28)
                                
                                if isCompleted {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(themeColor)
                                }
                            }
                        }
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
                primaryBackground.ignoresSafeArea()
                
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
            .background(primaryBackground)
        }
        .onAppear {
            if let task = taskToEdit {
                title = task.title
                startTime = task.startTime
                durationMinutes = task.durationMinutes
                colorHex = task.colorHex
                icon = task.icon ?? "checklist"
                isCompleted = task.isCompleted
                notes = task.notes ?? ""
                repeatFreq = task.repeatFrequency
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
                // Dotted line adapts to light/dark
                .stroke(Color.primary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
            }
            
            ZStack {
                if step == 3 {
                    Capsule()
                        // Fix for Pill Background in Header adapting to light/dark system mode
                        .fill(cardBackground.opacity(0.95))
                        .frame(width: 64, height: 120)
                        .overlay(Capsule().stroke(Color.white, lineWidth: 3))
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 64, height: 64)
                }
                
                Image(systemName: isCompleted ? "checkmark" : icon)
                    .font(.title)
                    .foregroundColor(step == 3 ? (isCompleted ? .gray : themeColor) : .white)
            }
            
            // Sub-icon circle
            if step == 3 && !isCompleted {
                Circle()
                    .fill(cardBackground)
                    .frame(width: 24, height: 24)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .overlay(
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 10))
                            .foregroundColor(themeColor)
                    )
                    .offset(x: -4, y: 4)
            }
        }
    }
    
    // MARK: - STEP 1: Title & Icon
    var step1Body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("SUGGESTIONS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                LazyVStack(spacing: 12) {
                    ForEach(filteredSuggestions) { suggestion in
                        Button(action: {
                            title = suggestion.title
                            icon = suggestion.icon
                            colorHex = suggestion.colorHex
                            durationMinutes = suggestion.durationMinutes
                            withAnimation { step = 2 }
                        }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: suggestion.colorHex) ?? .gray)
                                        .frame(width: 40, height: 40)
                                    Image(systemName: suggestion.icon)
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.title)
                                        .font(.body.weight(.medium))
                                        .foregroundColor(.primary)
                                    Text(formatDuration(suggestion.durationMinutes))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "plus")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(cardBackground)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    // MARK: - STEP 2: Customization (Time & Color)
    var step2Body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Color Picker Grid
                VStack(alignment: .leading) {
                    Text("COLOR")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(presetColors, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex) ?? .gray)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: colorHex == hex ? 3 : 0)
                                        .padding(-4)
                                )
                                .onTapGesture {
                                    withAnimation { colorHex = hex }
                                }
                        }
                    }
                    .padding()
                    .background(cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Duration Picker Grid
                VStack(alignment: .leading) {
                    Text("DURATION")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(durations, id: \.self) { mins in
                            Button(action: {
                                withAnimation { durationMinutes = mins }
                            }) {
                                Text(formatDuration(mins))
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(durationMinutes == mins ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(durationMinutes == mins ? themeColor : cardBackground)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Start Time
                VStack(alignment: .leading) {
                    Text("START TIME")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    HStack {
                        DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(.wheel)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - STEP 3: Final Settings (Date, Repeat, Notes)
    var step3Body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Section 1: Core Details
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(themeColor)
                            .frame(width: 24)
                        DatePicker("Date", selection: $startTime, displayedComponents: .date)
                            .labelsHidden()
                        Spacer()
                    }
                    .padding()
                    
                    Divider().padding(.leading, 40)
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(themeColor)
                            .frame(width: 24)
                        DatePicker("Time", selection: $startTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                        Spacer()
                    }
                    .padding()
                    
                    Divider().padding(.leading, 40)
                    
                    HStack {
                        Image(systemName: "repeat")
                            .foregroundColor(themeColor)
                            .frame(width: 24)
                        Text("Repeat")
                        Spacer()
                        Picker("", selection: $repeatFreq) {
                            ForEach(RepeatFrequency.allCases, id: \.self) { freq in
                                Text(freq.rawValue).tag(freq)
                            }
                        }
                        .tint(.secondary)
                    }
                    .padding()
                }
                .background(cardBackground)
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Section 2: Notes
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.secondary)
                        Text("Notes")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding()
                    
                    Divider()
                    
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .overlay(
                            Group {
                                if notes.isEmpty {
                                    Text("Add notes, meeting links or phone numbers...")
                                        .foregroundColor(Color.gray.opacity(0.6))
                                        .padding(.horizontal, 16)
                                        .padding(.top, 16)
                                        .allowsHitTesting(false)
                                }
                            }, alignment: .topLeading
                        )
                }
                .background(cardBackground)
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Delete Button (if editing)
                if taskToEdit != nil {
                    Button(role: .destructive) {
                        if let task = taskToEdit {
                            viewModel.deleteTask(task)
                        }
                        dismiss()
                    } label: {
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
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 100) // Space for floating bottom button
        }
    }
    
    // MARK: - Helpers
    private func saveTask() {
        let finalTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let newTask = TaskItem(
            id: taskToEdit?.id ?? UUID(),
            title: finalTitle.isEmpty ? "New Task" : finalTitle,
            startTime: startTime,
            duration: TimeInterval(durationMinutes * 60),
            colorHex: colorHex,
            icon: icon,
            isCompleted: isCompleted,
            notes: notes.isEmpty ? nil : notes,
            repeatFrequency: repeatFreq
        )
        
        if taskToEdit != nil {
            viewModel.updateTask(newTask)
        } else {
            viewModel.addTask(newTask)
        }
        dismiss()
    }
    
    private func formatDuration(_ mins: Double) -> String {
        if mins < 60 {
            return "\(Int(mins)) min"
        } else if mins.truncatingRemainder(dividingBy: 60) == 0 {
            return "\(Int(mins / 60)) h"
        } else {
            let h = Int(mins / 60)
            let m = Int(mins.truncatingRemainder(dividingBy: 60))
            return "\(h) h \(m) m"
        }
    }
}
