import SwiftUI

struct HomeView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        GeometryReader { geo in
            // SCALE FACTOR
            let scale = CGFloat.adiosScale(for: geo.size.width)

            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: Spacing.xs) {
                        Text("ADIOS")
                            .font(.monstral(100 * scale))
                            .foregroundColor(.adios_cream)
                            .shadow(color: .adios_black, radius: 0, x: 4 * scale, y: 4 * scale)

                        Text("Ate. Lived. Left.")
                            .font(.roundelay(22 * scale))
                            .foregroundColor(.adios_black)
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                    Spacer()
                    
                    // MARK: NAVIGATION
                    
                    VStack(spacing: Spacing.sm) {
                        Button("Add a bite") {
                            state.navigate(to: .log)
                        }
                        .buttonStyle(AdiosButtonStyle(fill: .adios_cream, text: .adios_black, stroke: .adios_black, scale: scale))

                        Button("View map") {
                            state.navigate(to: .map)
                        }
                        .buttonStyle(AdiosButtonStyle(fill: .clear, text: .adios_black, stroke: .adios_black, scale: scale))
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.lg + 34 * scale)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea()
    }
}
