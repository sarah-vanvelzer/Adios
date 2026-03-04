import SwiftUI

struct BenefitsView: View {
    @EnvironmentObject var state: AppState
    let food: String
    let benefits: [String]

    @State private var appeared = false

    var body: some View {
        GeometryReader { geo in
            // SCALE FACTOR
            let scale = CGFloat.adiosScale(for: geo.size.width)

            ZStack {
                Color.adios_cream.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {

                    BackButton(action: { state.navigate(to: .log) }, scale: scale)
                        .padding(.top, Spacing.md)
                        .padding(.leading, Spacing.md)

                    Text(food.uppercased())
                        .font(.monstral(titleSize(for: food, scale: scale)))
                        .foregroundColor(.adios_black)
                        .lineSpacing(4)
                        .minimumScaleFactor(0.5)
                        .padding(.top, Spacing.md)
                        .padding(.horizontal, Spacing.lg)

                    Spacer()

                    VStack(spacing: Spacing.sm + 5) {
                        // STAGGERED BENEFIT CARD ENTRANCE ANIMATION
                        ForEach(Array(benefits.enumerated()), id: \.offset) { index, line in
                            BenefitCard(text: line, scale: scale)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.75)
                                    .delay(Double(index) * 0.1),
                                    value: appeared
                                )
                        }
                    }
                    .padding(.horizontal, Spacing.lg)

                    Spacer()

                    VStack(spacing: Spacing.sm) {
                        Button("Add to map") {
                            state.navigate(to: .mapPlot(food: food, lines: benefits))
                        }
                        .buttonStyle(AdiosButtonStyle(fill: .adios_pink, text: .adios_black, stroke: .adios_black, scale: scale))

                        Button("Return home") {
                            state.navigate(to: .home)
                        }
                        .buttonStyle(AdiosButtonStyle(fill: .adios_cream, text: .adios_black, stroke: .adios_black, scale: scale))
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.lg)
                }
            }
            .onAppear { appeared = true }
        }
    }

    // SHRINKS TITLE FONT BASED ON CHARACTER COUNT
    private func titleSize(for text: String, scale: CGFloat) -> CGFloat {
        let base: CGFloat
        switch text.count {
        case 0...8:   base = 62
        case 9...14:  base = 52
        default:      base = 44
        }
        return base * scale
    }
}

struct BenefitCard: View {
    let text: String
    var scale: CGFloat = 1.0

    var body: some View {
        Text(text)
            .font(.roundelay(15 * scale))
            .foregroundColor(.adios_black)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14 * scale)
            .padding(.horizontal, Spacing.md)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.card)
                        .fill(Color.adios_pink.opacity(0.75))
                        .offset(y: 4)
                    RoundedRectangle(cornerRadius: Radius.card)
                        .fill(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.card)
                                .stroke(Color.adios_black, lineWidth: 2)
                        )
                }
            )
    }
}
