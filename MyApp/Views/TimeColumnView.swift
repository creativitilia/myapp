import SwiftUI

struct TimeColumnView: View {
    let pixelsPerMinute: CGFloat
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(0..<25) { hour in
                Text(String(format: "%02d:00", hour == 24 ? 0 : hour))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    // Height matches exactly 60 minutes * layout multiplier
                    .frame(height: 60 * pixelsPerMinute, alignment: .top)
                    .offset(y: -7) // visually align center of text to the hour line
            }
        }
        .frame(width: 50)
    }
}
