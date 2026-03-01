import SwiftUI

struct TimelineView: View {
    @StateObject private var viewModel = DayScheduleViewModel()
    @State private var showingAddEditSheet = false
    @State private var taskToEdit: TaskItem?
    
    var body: some View {
        NavigationView {
            ScrollView {
                ZStack(alignment: .topLeading) {
                    // 1. Background Grid (Hour Dividers)
                    VStack(spacing: 0) {
                        ForEach(0..<25) { _ in
                            Divider()
                                .frame(height: 60 * viewModel.pixelsPerMinute, alignment: .top)
                        }
                    }
                    .padding(.leading, 50) // Make room for time labels
                    
                    // 2. Content Layer
                    HStack(alignment: .top, spacing: 10) {
                        TimeColumnView(pixelsPerMinute: viewModel.pixelsPerMinute)
                        
                        ZStack(alignment: .topLeading) {
                            ForEach(viewModel.tasks) { task in
                                TaskBlockView(task: task, viewModel: viewModel) {
                                    taskToEdit = task
                                    showingAddEditSheet = true
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing, 16)
                    }
                }
                .padding(.vertical)
                // Ensures ScrollView knows exact total height: 24h * 60m * layout multiplier
                .frame(height: 24 * 60 * viewModel.pixelsPerMinute + 40, alignment: .top)
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        taskToEdit = nil
                        showingAddEditSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddEditSheet) {
                AddEditTaskView(viewModel: viewModel, taskToEdit: taskToEdit)
            }
        }
    }
}
