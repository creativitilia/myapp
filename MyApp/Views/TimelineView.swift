import SwiftUI

struct TimelineView: View {
    @StateObject private var vm = DayScheduleViewModel()

    @State private var showingAdd = false
    @State private var editingTask: TaskItem?
    @State private var dragOffsets: [UUID: CGFloat] = [:]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. Header & Calendar Scroller
                VStack(spacing: 12) {
                    HStack {
                        Text(vm.selectedDate.formatted(.dateTime.month(.wide).year()))
                            .font(.title2.weight(.bold))
                        Spacer()
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Image(systemName: "gearshape")
                            .foregroundColor(.secondary)
                            .padding(.leading, 12)
                    }
                    .padding(.horizontal)
                    
                    HorizontalCalendarView(selectedDate: $vm.selectedDate)
                }
                .padding(.top, 10)
                .padding(.bottom, 15)
                .background(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
                .zIndex(1) // Keep shadow above timeline
                
                // 2. Timeline Canvas
                ZStack(alignment: .bottomTrailing) {
                    ScrollView(.vertical) {
                        ZStack(alignment: .topLeading) {
                            
                            // A. Time Labels (Far left)
                            TimeColumnView(vm: vm)
                            
                            // B. Continuous Vertical Line Background
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 2)
                                .frame(height: vm.timelineHeight())
                                // Align exactly to center of the task icons
                                // columnWidth (65) + HStack spacing (10) + half of circle width (22) - half of line width (1)
                                .offset(x: vm.timeColumnWidth + 10 + 22 - 1)
                            
                            // C. Current Time Indicator (Red Line sweeping across)
                            if vm.calendar.isDate(vm.selectedDate, inSameDayAs: Date()) {
                                let currentY = vm.yPosition(for: vm.currentTime)
                                HStack(spacing: 0) {
                                    // Pushes the dot over to align with the timeline line
                                    Spacer()
                                        .frame(width: vm.timeColumnWidth + 10 + 22 - 4)
                                    
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                    
                                    Rectangle()
                                        .fill(Color.red)
                                        .frame(height: 1.5)
                                        .padding(.leading, -2) // Overlap the dot slightly
                                }
                                .offset(y: currentY - 4)
                                .zIndex(2) // float over everything
                                .animation(.linear(duration: 1.0), value: currentY)
                            }
                            
                            // D. Task Blocks
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
                                            dragOffsets[task.id] = value.translation.height
                                        }
                                        .onEnded { value in
                                            withAnimation(.spring()) { dragOffsets[task.id] = 0 }
                                            vm.reschedule(task: task, byDragYOffset: value.translation.height)
                                        }
                                )
                                .animation(.spring(response: 0.3, dampingFraction: 0.85), value: vm.tasks)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: vm.timelineHeight() + 100) // Padding at bottom
                        .padding(.top, 20)
                    }
                    
                    // 3. Floating Add Button
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 60, height: 60)
                            // The salmon pink matching version 2.0
                            .background(Color(hex: "#FF8C8C") ?? Color.pink)
                            .clipShape(Circle())
                            .shadow(color: Color(hex: "#FF8C8C")?.opacity(0.4) ?? .clear, radius: 8, y: 4)
                    }
                    .padding(24)
                }
            }
            .navigationBarHidden(true) // Hide default nav bar to use custom one
            .sheet(isPresented: $showingAdd) {
                AddEditTaskView(viewModel: vm, taskToEdit: nil)
            }
            .sheet(item: $editingTask) { task in
                AddEditTaskView(viewModel: vm, taskToEdit: task)
            }
        }
    }
}
