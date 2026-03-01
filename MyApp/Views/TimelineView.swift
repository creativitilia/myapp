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
                    
                    HorizontalCalendarView(selectedDate: $vm.selectedDate, vm: vm)
                }
                .padding(.bottom, 15)
                .background(darkerBackground)
                .zIndex(1)
                
                // 2. Timeline Canvas
                ZStack(alignment: .bottomTrailing) {
                    
                    ScrollViewReader { scrollProxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            ZStack(alignment: .topLeading) {
                                
                                // THE FIX FOR SCROLLING:
                                // We lay down a VStack of invisible blocks that exactly match the height of each hour.
                                // Because they are physical blocks inside a VStack, ScrollViewReader finds them instantly.
                                VStack(spacing: 0) {
                                    ForEach(0..<24, id: \.self) { hour in
                                        Color.clear
                                            // 60 minutes * pixelsPerMinute = height of one hour
                                            .frame(height: 60 * vm.pixelsPerMinute)
                                            .id(hour) // ID is simply the integer hour (e.g., 14 for 2 PM)
                                    }
                                }
                                
                                // A. Time Labels (Far left)
                                TimeColumnView(vm: vm)
                                
                                // B. Continuous Vertical Line Background (Dashed style)
                                Path { path in
                                    path.move(to: CGPoint(x: 0, y: 0))
                                    path.addLine(to: CGPoint(x: 0, y: vm.timelineHeight()))
                                }
                                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                                .offset(x: vm.timeColumnWidth + 10 + 22 - 0.75)
                                
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
                            .frame(height: vm.timelineHeight() + 100, alignment: .top) // extra padding at bottom
                            .padding(.vertical, 20)
                        }
                        .background(darkBackground) // Dark timeline canvas
                        .onAppear {
                            // Automatically scroll down to the current hour block
                            let currentHour = Calendar.current.component(.hour, from: Date())
                            
                            // Delay gives SwiftUI enough time to measure the VStack
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                if vm.calendar.isDate(vm.selectedDate, inSameDayAs: Date()) {
                                    withAnimation(.easeOut(duration: 0.6)) {
                                        // Scroll precisely to the integer ID (e.g. 14 for 2:00 PM)
                                        scrollProxy.scrollTo(currentHour, anchor: .center)
                                    }
                                }
                            }
                        }
                        // Re-trigger scroll if the user taps "Today" on the calendar header
                        // using the iOS 17 compliant signature (0-parameter closure or 2-parameter old/new closure)
                        .onChange(of: vm.selectedDate) { oldDate, newDate in
                            if vm.calendar.isDate(newDate, inSameDayAs: Date()) {
                                let currentHour = Calendar.current.component(.hour, from: Date())
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeOut(duration: 0.6)) {
                                        scrollProxy.scrollTo(currentHour, anchor: .center)
                                    }
                                }
                            }
                        }
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
                    .padding(.trailing, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(darkerBackground.ignoresSafeArea())
            .preferredColorScheme(.dark) // FORCE DARK MODE
        }
        .sheet(isPresented: $showingAdd) {
            AddEditTaskView(viewModel: vm)
        }
        .sheet(item: $editingTask) { task in
            AddEditTaskView(viewModel: vm, taskToEdit: task)
        }
    }
}
