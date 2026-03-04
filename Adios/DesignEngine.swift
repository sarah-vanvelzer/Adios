import SwiftUI

// MARK: COLOURS
extension Color {
    static let adios_pink  = Color("adios_pink")
    static let adios_black = Color("adios_black")
    static let adios_cream = Color("adios_cream")
}

// MARK: FONTS
extension Font {
    static func monstral(_ size: CGFloat) -> Font {
        .custom("DxMonstral-Smooth", size: size)
    }
    static func roundelay(_ size: CGFloat) -> Font {
        .custom("Roundelay-Regular", size: size)
    }
}

// MARK: SPACING
enum Spacing {
    static let xs:  CGFloat = 8
    static let sm:  CGFloat = 12
    static let md:  CGFloat = 20
    static let lg:  CGFloat = 32
    static let xl:  CGFloat = 48
    static let xxl: CGFloat = 64
}

// MARK: RADIUS
enum Radius {
    static let button: CGFloat = 50
    static let card:   CGFloat = 20
    static let input:  CGFloat = 14
}

// MARK: SCALE HELPER
extension CGFloat {
    static func adiosScale(for width: CGFloat) -> CGFloat {
        Swift.min(width / 390, 1.3)
    }
}

// MARK: BUTTON STYLE
struct AdiosButtonStyle: ButtonStyle {
    var fill: Color
    var text: Color
    var stroke: Color
    var scale: CGFloat = 1.0

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.roundelay(20 * scale))
            .foregroundColor(text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16 * scale)
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(stroke, lineWidth: 2 * scale))
            .contentShape(RoundedRectangle(cornerRadius: 14))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: BACK BUTTON
struct BackButton: View {
    let action: () -> Void
    var scale: CGFloat = 1.0

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18 * scale, weight: .semibold))
                .foregroundColor(.adios_black)
                .frame(width: 40 * scale, height: 40 * scale)
        }
    }
}
