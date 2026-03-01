import SwiftUI

struct HorizontalCalendarView: View {
    @Binding var selectedDate: Date
    let calendar = Calendar.current
    
    // Generate an array of dates (-14 days to +14 days from today)
    var dates: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (-14...14).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(dates, id: \.self) { date in
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        
                        VStack(spacing: 6) {
                            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                                .font(.caption2)
                                .foregroundColor(isSelected ? .pink : .secondary)
                            
                            Text(date.formatted(.dateTime.day()))
                                .font(.title3.weight(isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? .pink : .primary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.pink.opacity(0.15) : Color.clear)
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedDate = date
                            }
                        }
                        .id(date) // For scrolling to today
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                // Scroll to selected date on launch
                proxy.scrollTo(calendar.startOfDay(for: selectedDate), anchor: .center)
            }
        }
    }
}
