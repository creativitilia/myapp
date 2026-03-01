import SwiftUI

struct TimelineView: View {
    @StateObject private var vm = DayScheduleViewModel()

    @State private var showingAdd = false
    @State private var editingTask: TaskItem?
    
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
                        Text(vm.selectedDate.formatted(.dateTime.day().month(.wide)))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
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
                                
                                // INVISIBLE HOUR ANCHORS
                                VStack(spacing: 0) {
                                    ForEach(0..<24, id: \.self) { hour in
                                        Color.clear
                                            .frame(height: 60 * vm.pixelsPerMinute)
                                            .id(hour)
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
                                
                                // C. Floating Current Time Label
                                if vm.calendar.isDate(vm.selectedDate, inSameDayAs: Date()) {
                                    let currentY = vm.yPosition(for: vm.currentTime)
                                    
                                    Text(vm.currentTime.formatted(date: .omitted, time: .shortened))
                                        .font(.caption2.weight(.bold))
                                        .foregroundColor(.white)
                                        .frame(width: vm.timeColumnWidth, alignment: .trailing)
                                        .offset(y: currentY - 7)
                                        .animation(.linear(duration: 1.0), value: currentY)
                                }
                                
                                // D. Task Blocks (Dragging completely removed)
                                ForEach(vm.tasks) { task in
                                    let taskHeight = vm.height(for: task)
                                    let yPos = vm.yPosition(for: task.startTime)
                                    
                                    HStack {
                                        Spacer().frame(width: vm.timeColumnWidth + 10)
                                        TaskBlockView(
                                            task: task,
                                            height: taskHeight,
                                            onTap: { editingTask = task },
                                            onToggleComplete: { vm.toggleCompletion(for: task) }
                                        )
                                    }
                                    .offset(y: yPos) // No more drag offset calculation!
                                }
                            }
                            .frame(height: vm.timelineHeight() + 100, alignment: .top) // extra padding at bottom
                            .padding(.vertical, 20)
                        }
                        .background(darkBackground)
                        .onAppear {
                            scrollToCurrentHour(using: scrollProxy)
                        }
                        .onChange(of: vm.selectedDate) {
                            scrollToCurrentHour(using: scrollProxy)
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
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showingAdd) {
            AddEditTaskView(viewModel: vm)
        }
        .sheet(item: $editingTask) { task in
            AddEditTaskView(viewModel: vm, taskToEdit: task)
        }
    }
    
    // Helper function to handle the scrolling logic
    private func scrollToCurrentHour(using proxy: ScrollViewProxy) {
        if vm.calendar.isDate(vm.selectedDate, inSameDayAs: Date()) {
            let currentHour = vm.calendar.component(.hour, from: vm.currentTime)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.6)) {
                    proxy.scrollTo(currentHour, anchor: .center)
                }
            }
        }
    }
}
