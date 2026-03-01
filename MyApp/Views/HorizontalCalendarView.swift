import SwiftUI

struct HorizontalCalendarView: View {
    @Binding var selectedDate: Date
    // We pass the view model in so we can check if days have tasks
    @ObservedObject var vm: DayScheduleViewModel
    let calendar = Calendar.current
    
    // Theme colors matching inspiration
    let themePink = Color(red: 1.0, green: 0.54, blue: 0.54) // Coral pink
    let darkBackground = Color(red: 0.1, green: 0.1, blue: 0.12)
    
    // Generate an array of dates (-14 days to +14 days from today)
    var dates: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (-14...14).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) { // Tighter spacing
                    ForEach(dates, id: \.self) { date in
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        
                        VStack(spacing: 8) {
                            // Day of the week (Mon, Tue)
                            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                                .font(.caption2)
                                .foregroundColor(isSelected ? .white : .gray)
                            
                            // Date Number (1, 23, 24)
                            Text(date.formatted(.dateTime.day()))
                                .font(.title3.weight(isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : .primary)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(isSelected ? themePink : Color.clear)
                                )
                            
                            // Task indicators underneath (dots or tiny icons)
                            // We check if there are tasks for this specific date
                            let tasksForDay = vm.tasksFor(date: date)
                            if !tasksForDay.isEmpty {
                                HStack(spacing: 2) {
                                    // Just showing up to 2 tiny icons to match inspiration
                                    ForEach(tasksForDay.prefix(2)) { task in
                                        Circle()
                                            .fill(task.color)
                                            .frame(width: 6, height: 6)
                                    }
                                }
                                .frame(height: 10)
                            } else {
                                // Spacer to keep height consistent
                                Spacer().frame(height: 10)
                            }
                        }
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedDate = date
                            }
                        }
                        .id(date)
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                proxy.scrollTo(calendar.startOfDay(for: selectedDate), anchor: .center)
            }
        }
    }
}
