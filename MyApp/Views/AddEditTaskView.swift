import SwiftUI

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
    
    // FIX: Store the actual Color object in state instead of calculating hex constantly
    @State private var themeColor: Color = Color(red: 0.9, green: 0.45, blue: 0.45)
    @State private var icon: String = "figure.run"
    
    // UI States
    @State private var showingColorPicker = false
    
    // Use raw Colors instead of Hex strings for the preset picker
    private let presetColors: [Color] = [
        Color(red: 0.9, green: 0.45, blue: 0.45), // Salmon Red
        Color(red: 0.5, green: 0.78, blue: 0.52), // Green
        Color(red: 0.39, green: 0.71, blue: 0.96), // Blue
        Color(red: 0.31, green: 0.76, blue: 0.97), // Light Blue
        Color(red: 0.47, green: 0.53, blue: 0.8),  // Indigo
        Color(red: 0.73, green: 0.41, blue: 0.78), // Purple
        Color(red: 0.94, green: 0.38, blue: 0.57), // Pink
        Color(red: 1.0, green: 0.72, blue: 0.3),   // Orange
        Color(red: 1.0, green: 0.54, blue: 0.4)    // Deep Orange
    ]
    
    private let durations: [Double] = [5, 15, 30, 45, 60, 90, 120, 180]
    let darkBackground = Color(red: 0.1, green: 0.1, blue: 0.11)

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - TWO TONE HEADER
            VStack(alignment: .leading, spacing: 0) {
                // Top Bar (Cancel)
                HStack {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Capsule())
                    }
                    Spacer()
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
                            Text("\(startTime.formatted(date: .omitted, time: .shortened)) - \(endTime.formatted(date: .omitted, time: .shortened)) (\(formatDuration(durationMinutes)))")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        TextField("", text: $title, prompt: Text("Task Title").foregroundColor(.white.opacity(0.5)))
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                            .tint(.white)
                        
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
                        if title.isEmpty { title = "New Task" }
                        step += 1
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
                // FIX: Initialize the color safely
                themeColor = Color(hex: task.colorHex) ?? Color(red: 0.9, green: 0.45, blue: 0.45)
                icon = task.icon ?? "circle.fill"
                step = 3 // Jump to confirmation for existing tasks
            }
        }
    }
}

// MARK: - Subviews & Steps
extension AddEditTaskView {
    
    // HEADER ICON ANIMATION
    @ViewBuilder
    var headerIcon: some View {
        ZStack(alignment: .bottomLeading) {
            // Dotted line in background for step 3
            if step == 3 {
                Path { path in
                    path.move(to: CGPoint(x: 32, y: -50))
                    path.addLine(to: CGPoint(x: 32, y: 150))
                }
                .stroke(Color.black.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
            }
            
            // Main Icon Shape
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
                    .offset(y: step == 3 ? -15 : 0) // Shift up slightly in capsule
            }
            
            // Color Palette Button (Step 3)
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
                // Dummy data matching screenshot
                suggestionRow(icon: "envelope.fill", title: "Answer Emails", time: "10:00 - 10:15 (15 min)")
                suggestionRow(icon: "tv.fill", title: "Watch a Movie", time: "20:00 - 21:30 (1 hr, 30 min)")
                suggestionRow(icon: "figure.run", title: "Go for a Run!", time: "12:00 - 13:00 (1 hr)")
                suggestionRow(icon: "cart.fill", title: "Go Shopping", time: "17:00 - 18:00 (1 hr)")
            }
            .padding(.top, 30)
            .padding(.horizontal, 24)
        }
    }
    
    func suggestionRow(icon: String, title: String, time: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(themeColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(time)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Divider().background(Color.gray.opacity(0.3)).padding(.top, 8)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.title = title
            self.icon = icon
            step = 2
        }
    }
    
    // STEP 2: TIME & DURATION
    var step2Body: some View {
        VStack(alignment: .leading, spacing: 30) {
            
            // Date Row
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(themeColor)
                Text(startTime.formatted(.dateTime.weekday().day().month().year()))
                    .foregroundColor(.white)
                Spacer()
                Text("Today >")
                    .foregroundColor(.gray)
                    .font(.subheadline)
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
                    Image(systemName: "ellipsis.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 24)
                
                DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark) // Force dark mode for white text
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
                    Image(systemName: "ellipsis.circle.fill")
                        .foregroundColor(.gray)
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
        VStack(spacing: 0) {
            if showingColorPicker {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(presetColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 36, height: 36)
                                .overlay(Circle().stroke(Color.white, lineWidth: themeColor == color ? 3 : 0))
                                .onTapGesture {
                                    withAnimation {
                                        themeColor = color
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
            
            VStack(spacing: 24) {
                detailRow(icon: "calendar", title: startTime.formatted(.dateTime.weekday().day().month().year()), value: "Today >")
                detailRow(icon: "clock.fill", title: "\(startTime.formatted(date: .omitted, time: .shortened)) - \(startTime.addingTimeInterval(durationMinutes * 60).formatted(date: .omitted, time: .shortened))", value: "\(formatDuration(durationMinutes)) >")
                detailRow(icon: "bell.slash.fill", title: "1 Alert", value: "Nudge >")
                detailRow(icon: "arrow.2.squarepath", title: "Repeat", value: "PRO", isPro: true)
                
                Divider().background(Color.gray.opacity(0.3))
                
                HStack {
                    Image(systemName: "square")
                        .foregroundColor(.gray)
                    Text("Add Subtask")
                        .foregroundColor(.gray)
                    Spacer()
                }
                
                Text("Add notes, meeting links or phone numbers...")
                    .font(.subheadline)
                    .foregroundColor(.gray.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(24)
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
                Text(value)
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(4)
            } else {
                Text(value)
                    .foregroundColor(.gray)
            }
        }
    }
    
    // MARK: - Helpers
    private func saveTask() {
        // Convert the current UI color back to a hex string for saving
        let hexString = themeColor.toHex() ?? "#E57373"
        
        let task = TaskItem(
            id: taskToEdit?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled Task" : title,
            startTime: startTime,
            duration: durationMinutes * 60,
            colorHex: hexString,
            icon: icon,
            isCompleted: taskToEdit?.isCompleted ?? false
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
