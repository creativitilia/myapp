import SwiftUI

struct TimelineView: View {
    @StateObject private var vm = DayScheduleViewModel()

    @State private var showingAdd = false
    @State private var editingTask: TaskItem?
    @State private var dragOffsets: [UUID: CGFloat] = [:]

    // Custom accent colors
    let darkBackground = Color(red: 0.1, green: 0.1, blue: 0.12)
    let headerBackground = Color(red: 0.05, green: 0.05, blue: 0.06)
    let timelineLineColor = Color(red: 0.25, green: 0.25, blue: 0.25)
    let accentColor = Color(red: 1.0, green: 0.54, blue: 0.54) // Coral/Pink

    var body: some View {
        NavigationStack {
            ZStack {
                darkBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 1. Header & Calendar Scroller
                    VStack(spacing: 16) {
                        HStack(alignment: .bottom, spacing: 6) {
                            // "1 March"
                            Text(vm.selectedDate.formatted(.dateTime.day().month(.wide)))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            // "2026"
                            Text(vm.selectedDate.formatted(.dateTime.year()))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(accentColor)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(accentColor)
                                .padding(.bottom, 4)
                                
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // Pass vm to HorizontalCalendarView so it can read tasks for the dots
                        HorizontalCalendarView(selectedDate: $vm.selectedDate, vm: vm)
                    }
                    .padding(.bottom, 15)
                    .background(headerBackground)
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                    .zIndex(1) // Keep shadow above timeline
                    
                    // 2. Timeline Canvas
                    ZStack(alignment: .bottomTrailing) {
                        ScrollViewReader { scrollProxy in
                            ScrollView(.vertical, showsIndicators: false) {
                                ZStack(alignment: .topLeading) {
                                    
                                    // A. Time Labels (Far left)
                                    TimeColumnView(vm: vm)
                                    
                                    // B. Continuous Vertical Line Background (Dashed to match inspiration)
                                    Path { path in
                                        path.move(to: CGPoint(x: 0, y: 0))
                                        path.addLine(to: CGPoint(x: 0, y: vm.timelineHeight()))
                                    }
                                    .stroke(timelineLineColor, style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                                    // Align exactly to center of the task icons
                                    .offset(x: vm.timeColumnWidth + 10 + 22 - 0.75)
                                    
                                    // C. Invisible anchor for scrolling to current time
                                    Color.clear
                                        .frame(width: 1, height: 1)
                                        .offset(y: vm.yPosition(for: vm.currentTime))
                                        .id("CurrentTimeAnchor")
                                    
                                    // D. Current Time Indicator (Red Line sweeping across)
                                    if vm.calendar.isDate(vm.selectedDate, inSameDayAs: Date()) {
                                        let currentY = vm.yPosition(for: vm.currentTime)
                                        HStack(spacing: 0) {
                                            // Pushes the dot over to align with the timeline line
                                            Spacer()
                                                .frame(width: vm.timeColumnWidth + 10 + 22 - 4)
                                            
                                            Circle()
                                                .fill(accentColor)
                                                .frame(width: 8, height: 8)
                                            
                                            Rectangle()
                                                .fill(accentColor)
                                                .frame(height: 1.5)
                                                .padding(.leading, -2) // Overlap the dot slightly
                                        }
                                        .offset(y: currentY - 4)
                                        .zIndex(2) // float over everything
                                        .animation(.linear(duration: 1.0), value: currentY)
                                    }
                                    
                                    // E. Task Blocks
                                    ForEach(vm.tasks) { task in
                                        let taskHeight = vm.height(for: task)
                                        let yPos = vm.yPosition(for: task.startTime)
                                        let dragOffset = dragOffsets[task.id] ?? 0
                                        
                                        HStack {
                                            Spacer().frame(width: vm.timeColumnWidth + 10) // Push content right
                                            TaskBlockView(
                                                task: task,
                                                height: taskHeight,
                                                onTap: { editingTask = task },
                                                onToggleComplete: { vm.toggleCompletion(for: task) }
                                            )
                                        }
                                        // Offset the whole row vertically
                                        .offset(y: yPos + dragOffset)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    // Add 15 mins (or specific logic) for drag
                                                    dragOffsets[task.id] = value.translation.height
                                                }
                                                .onEnded { value in
                                                    vm.reschedule(task: task, byDragYOffset: value.translation.height)
                                                    dragOffsets[task.id] = 0
                                                }
                                        )
                                    }
                                }
                                .frame(height: vm.timelineHeight() + 100) // extra space at bottom
                                .padding(.vertical, 20)
                            }
                            .onAppear {
                                // Scroll to current time on load
                                // We use a slight delay to ensure layout is calculated first
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeOut(duration: 0.5)) {
                                        scrollProxy.scrollTo("CurrentTimeAnchor", anchor: .center)
                                    }
                                }
                            }
                            // Also scroll if the user switches days back to "Today"
                            .onChange(of: vm.selectedDate) { newDate in
                                if vm.calendar.isDate(newDate, inSameDayAs: Date()) {
                                    withAnimation(.easeOut(duration: 0.5)) {
                                        scrollProxy.scrollTo("CurrentTimeAnchor", anchor: .center)
                                    }
                                }
                            }
                        }
                        
                        // 3. Floating Add Button
                        Button {
                            showingAdd = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(accentColor)
                                .clipShape(Circle())
                                .shadow(color: accentColor.opacity(0.4), radius: 10, y: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .preferredColorScheme(.dark) // Force dark mode to match the theme
        .sheet(isPresented: $showingAdd) {
            AddEditTaskView(viewModel: vm)
        }
        .sheet(item: $editingTask) { task in
            AddEditTaskView(viewModel: vm, taskToEdit: task)
        }
    }
}
