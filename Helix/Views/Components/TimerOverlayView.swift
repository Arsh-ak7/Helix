import SwiftUI

struct TimerOverlayView: View {
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        if timerManager.isActive {
            VStack {
                Spacer()
                HStack(spacing: 16) {
                    // Progress Circle
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 4)
                        Circle()
                            .trim(from: 0, to: timerManager.progress)
                            .stroke(Color("AppAccent"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.1), value: timerManager.progress)
                    }
                    .frame(width: 24, height: 24)
                    
                    // Time
                    Text(timerManager.formattedTime)
                        .font(.system(.headline, design: .monospaced))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    // Controls
                    Button {
                        timerManager.addTime(30)
                    } label: {
                        Text("+30s")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.black) // Black text for contrast
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white) // White background
                            .cornerRadius(8)
                    }
                    
                    Button {
                        timerManager.stopTimer()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding(16)
                .background(Color(hex: "1C1C1E")) // Always dark grey/black for the capsule
                .cornerRadius(30)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)
                .padding(.bottom, 20) // Lift above tab bar slightly if needed, but this is an overlay
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: timerManager.isActive)
        }
    }
}

// Helper for Hex color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
