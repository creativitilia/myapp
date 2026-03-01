import SwiftUI

struct TimelineView: View {
    @StateObject private var vm = DayScheduleViewModel()

    @State private var showingAdd = false
    @State private var editingTask: TaskItem?

    @State private var dragOffsets: [UUID: CGFloat] = [:]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView(.vertical) {
                    HStack(alignment: .top, spacing: 10) {
                        TimeColumnView(pixelsPerMinute: vm.pixelsPerMinute)

                        ZStack(alignment: .topLeading) {
                            hourLines

                            GeometryReader { geo in
                                ForEach(vm.tasks) { task in
                                    let taskHeight = vm.height(for: task)
                                    let y = vm.yPosition(for: task)
                                    let dragOffset = dragOffsets[task.id] ?? 0
                                    let blockWidth = max(160, geo.size.width - 8)

                                    TaskBlockView(
                                        task: task,
                                        width: blockWidth,
                                        height: taskHeight,
                                        onTap: { editingTask = task }
                                    )
                                    .position(x: blockWidth / 2, y: y + taskHeight / 2 + dragOffset)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                dragOffsets[task.id] = value.translation.height
                                            }
                                            .onEnded { value in
                                                withAnimation(.spring()) {
                                                    dragOffsets[task.id] = 0
                                                }
                                                vm.reschedule(task: task, byDragYOffset: value.translation.height)
                                            }
                                    )
                                    .animation(.spring(response: 0.3, dampingFraction: 0.85), value: vm.tasks)
                                }
                            }
                        }
                        .frame(height: vm.timelineHeight())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }

                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                        .shadow(radius: 8, y: 3)
                }
                .padding(20)
            }
            .navigationTitle("Today")
            .sheet(isPresented: $showingAdd) {
                AddEditTaskView(
                    existingTask: nil,
                    onSave: { vm.addTask($0) },
                    onDelete: nil
                )
            }
            .sheet(item: $editingTask) { task in
                AddEditTaskView(
                    existingTask: task,
                    onSave: { vm.updateTask($0) },
                    onDelete: { vm.deleteTask($0) }
                )
            }
        }
    }

    private var hourLines: some View {
        VStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { _ in
                Rectangle()
                    .fill(Color.secondary.opacity(0.15))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .frame(height: 60 * vm.pixelsPerMinute, alignment: .top)
            }
        }
    }
}
