import SwiftUI

struct MapPlotView: View {
    @EnvironmentObject var state: AppState
    let food: String
    let benefits: [String]

    @State private var dotPosition: CGPoint? = nil
    @State private var appeared = false

    var body: some View {
        GeometryReader { geo in
            // SCALE FACTOR
            let scale = CGFloat.adiosScale(for: geo.size.width)

            ZStack {
                Color.adios_cream.ignoresSafeArea()

                VStack(spacing: 0) {

                    BackButton(action: {
                        state.navigate(to: .benefits(food: food, lines: benefits))
                    }, scale: scale)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Spacing.md)
                    .padding(.leading, Spacing.md)

                    Text(food.uppercased())
                        .font(.monstral(34 * scale))
                        .foregroundColor(.adios_black)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.65)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, Spacing.sm)
                        .padding(.horizontal, Spacing.lg)

                    Text("Tap to place on the map")
                        .font(.roundelay(15 * scale))
                        .foregroundColor(.adios_black.opacity(0.45))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, 4)

                    // MAP DIMENSIONS DERIVED FROM SCREEN WIDTH
                    let mapWidth = geo.size.width - 2 * Spacing.xl
                    let mapHeight: CGFloat = 350 * scale
                    let sideLabelWidth: CGFloat = 44 * scale

                    VStack(spacing: 6) {
                        Text("Comforting")
                            .font(.roundelay(11 * scale))
                            .foregroundColor(.adios_black)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 3 * scale)

                        ZStack {
                            HStack(spacing: 0) {
                                Text("Craveable")
                                    .font(.roundelay(11 * scale))
                                    .foregroundColor(.adios_black)
                                    .fixedSize()
                                    .frame(width: sideLabelWidth)
                                    .rotationEffect(.degrees(-90))
                                    .padding(.trailing, -8)

                                MoodMapCanvas(
                                    dotPosition: $dotPosition,
                                    mapSize: CGSize(width: mapWidth, height: mapHeight),
                                    scale: scale
                                )

                                Text("Sustaining")
                                    .font(.roundelay(11 * scale))
                                    .foregroundColor(.adios_black)
                                    .fixedSize()
                                    .frame(width: sideLabelWidth)
                                    .rotationEffect(.degrees(90))
                                    .padding(.leading, -8)
                            }
                        }

                        Text("Electric")
                            .font(.roundelay(11 * scale))
                            .foregroundColor(.adios_black)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 3 * scale)
                    }
                    .padding(.top, Spacing.md)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeIn(duration: 0.4), value: appeared)

                    Spacer()

                    Button("Adios") {
                        guard let pos = dotPosition else { return }
                        // NORMALIZE DOT POSITION BEFORE SAVING
                        let entry = MapEntry(
                            food: food,
                            benefits: benefits,
                            x: pos.x / mapWidth,
                            y: pos.y / mapHeight
                        )
                        state.addEntry(entry)
                        state.navigate(to: .home)
                    }
                    .buttonStyle(AdiosButtonStyle(fill: .adios_pink, text: .adios_black, stroke: .adios_black, scale: scale))
                    .disabled(dotPosition == nil)
                    .opacity(dotPosition == nil ? 0.45 : 1)
                    .animation(.easeInOut(duration: 0.25), value: dotPosition == nil)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.lg)
                }
            }
            .onAppear { appeared = true }
        }
    }
}

struct MoodMapCanvas: View {
    @Binding var dotPosition: CGPoint?
    let mapSize: CGSize
    let scale: CGFloat

    var body: some View {
        ZStack {
            Image("map")
                .resizable()
                .scaledToFill()
                .frame(width: mapSize.width, height: mapSize.height)
                .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.card)
                        .stroke(Color.adios_black, lineWidth: 2 * scale)
                )

            if let pos = dotPosition {
                Circle()
                    .fill(Color.adios_black)
                    .frame(width: 12 * scale, height: 12 * scale)
                    .position(pos)
                    .animation(.spring(response: 0.3, dampingFraction: 0.65), value: pos)
            }
        }
        .frame(width: mapSize.width, height: mapSize.height)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    // CLAMP DOT POSITION WITHIN BOUNDS
                    let padding: CGFloat = 15
                    dotPosition = CGPoint(
                        x: min(max(value.location.x, padding), mapSize.width - padding),
                        y: min(max(value.location.y, padding), mapSize.height - padding)
                    )
                }
        )
    }
}
