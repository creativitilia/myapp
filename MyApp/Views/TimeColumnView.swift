import SwiftUI

struct TimeColumnView: View {
    let pixelsPerMinute: CGFloat

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(0..<24, id: \.self) { hour in
                Text(String(format: "%02d:00", hour))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 60 * pixelsPerMinute, alignment: .topTrailing)
                    .padding(.top, 2)
            }
        }
        .frame(width: 56)
    }
}
