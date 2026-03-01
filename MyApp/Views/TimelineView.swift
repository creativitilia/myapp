import SwiftUI

struct TimelineView: View {
    @StateObject private var vm = DayScheduleViewModel()

    @State private var showingAdd = false
    @State private var editingTask: TaskItem?
    @State private var dragOffsets: [UUID: CGFloat] = [:]
    
    // Theme colors matching inspiration
    let darkBackground = Color(red: 0.1, green: 0.1, blue: 0.12)
    let darkerBackground = Color(red: 0.05, green: 0.05, blue: 0.06)
    let themePink = Color(red: 1.0, green: 0.54, blue: 0.54) // Coral pink

    var body: some View {
        NavigationStack {
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
                            .foregroundColor(themePink)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(themePink)
                            .padding(.bottom, 4)
                            
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Fixed: passing selectedDate and vm to match the updated struct
                    HorizontalCalendarView(selectedDate: $vm.selectedDate, vm: vm)
                }
                .padding(.bottom, 15)
                .background(darkerBackground) // Very dark top header
                .zIndex(1)
                
                // 2. Timeline Canvas
                ZStack(alignment: .bottomTrailing) {
                    
                    // Added ScrollViewReader to allow scrolling to the current time
                    ScrollViewReader { scrollProxy in
                        ScrollView(.vertical) {
                            ZStack(alignment: .topLeading) {
                                
                                // A. Time Labels (Far left)
                                TimeColumnView(vm: vm)
                                
                                // B. Continuous Vertical Line Background
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 2)
                                    .frame(height: vm.timelineHeight())
                                    .offset(x: vm.timeColumnWidth + 10 + 22 - 1)
                                
                                // C. Current Time Indicator (Red Line sweeping across)
                                if vm.calendar.isDate(vm.selectedDate, inSameDayAs: Date()) {
                                    let currentY = vm.yPosition(for: vm.currentTime)
                                    HStack(spacing: 0) {
                                        Spacer()
                                            .frame(width: vm.timeColumnWidth + 10 + 22 - 4)
                                        
                                        Circle()
                                            .fill(themePink)
                                            .frame(width: 8, height: 8)
                                        
                                        Rectangle()
                                            .fill(themePink)
                                            .frame(height: 1.5)
                                            .padding(.leading, -2)
                                    }
                                    .offset(y: currentY - 4)
                                    .zIndex(2)
                                    .animation(.linear(duration: 1.0), value: currentY)
                                    .id("currentTimeIndicator") // ID for the scroller to find
                                }
                                
                                // D. Task Blocks
                                ForEach(vm.tasks) { task in
                                    let taskHeight = vm.height(for: task)
                                    let yPos = vm.yPosition(for: task.startTime)
                                    let dragOffset = dragOffsets[task.id] ?? 0
                                    
                                    HStack {
                                        Spacer().frame(width: vm.timeColumnWidth + 10)
                                        TaskBlockView(
                                            task: task,
                                            height: taskHeight,
                                            onTap: { editingTask = task },
                                            onToggleComplete: { vm.toggleCompletion(for: task) }
                                        )
                                    }
                                    .offset(y: yPos + dragOffset)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                dragOffsets[task.id] = value.translation.height
                                            }
                                            .onEnded { value in
                                                vm.reschedule(task: task, byDragYOffset: value.translation.height)
                                                dragOffsets[task.id] = nil
                                            }
                                    )
                                }
                            }
                            .padding(.vertical, 20)
                            .onAppear {
                                // Auto-scroll to the current time when the view loads
                                if vm.calendar.isDate(vm.selectedDate, inSameDayAs: Date()) {
                                    // Give the view a tiny fraction of a second to render before scrolling
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation {
                                            // anchor: .center puts the red line in the middle of the screen
                                            scrollProxy.scrollTo("currentTimeIndicator", anchor: .center)
                                        }
                                    }
                                }
                            }
                        }
                        .background(darkBackground) // Dark timeline canvas
                    } // End ScrollViewReader
                    
                    // Add Button Floating
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(themePink)
                            .clipShape(Circle())
                            .shadow(color: themePink.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .padding()
                }
            }
            .background(darkerBackground.ignoresSafeArea())
            .preferredColorScheme(.dark) // FORCE DARK MODE FOR THE WHOLE APP
        }
        .sheet(isPresented: $showingAdd) {
            AddEditTaskView(viewModel: vm)
        }
        .sheet(item: $editingTask) { task in
            AddEditTaskView(viewModel: vm, taskToEdit: task)
        }
    }
}
