import SwiftUI

struct MapView: View {
    @EnvironmentObject var state: AppState
    @State private var selectedEntry: MapEntry? = nil
    @State private var deletingEntry: MapEntry? = nil

    var body: some View {
        GeometryReader { geo in
            // SCALE FACTOR
            let scale = CGFloat.adiosScale(for: geo.size.width)
            let mapWidth = geo.size.width - 2 * Spacing.xl
            let mapHeight: CGFloat = 350 * scale
            let sideLabelWidth: CGFloat = 44 * scale
            let isIdle = selectedEntry == nil && deletingEntry == nil

            ZStack {
                Color.adios_cream.ignoresSafeArea()

                VStack(spacing: 0) {

                    BackButton(action: { state.navigate(to: .home) }, scale: scale)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, Spacing.md)
                        .padding(.leading, Spacing.md)

                    Spacer(minLength: 0)

                    VStack(spacing: 6) {
                        // COLLAPSE HINT TEXT
                        Text("TAP TO VIEW")
                            .font(.monstral(40 * scale))
                            .foregroundColor(.adios_black)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, Spacing.lg)
                            .opacity(isIdle ? 1 : 0)
                            .frame(height: isIdle ? nil : 0)
                            .clipped()

                        Text("Press & hold to delete")
                            .font(.roundelay(15 * scale))
                            .foregroundColor(.adios_black.opacity(0.45))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.top, 2)
                            .padding(.bottom, Spacing.md)
                            .opacity(isIdle ? 1 : 0)
                            .frame(height: isIdle ? nil : 0)
                            .clipped()

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

                                ReadOnlyMoodMap(
                                    entries: state.mapEntries,
                                    selectedEntry: $selectedEntry,
                                    deletingEntry: $deletingEntry,
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

                    Spacer(minLength: 0)

                    if let entry = deletingEntry {
                        DeletePopup(entry: entry, scale: scale) {
                            withAnimation {
                                state.mapEntries.removeAll { $0.id == entry.id }
                                deletingEntry = nil
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, Spacing.lg)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else if let entry = selectedEntry {
                        EntryPopup(entry: entry, scale: scale)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.bottom, Spacing.lg)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        // INVISBLE PLACEHOLDER TO STABILIZE BOTTOM LAYOUT
                        Text("TAP TO VIEW")
                            .font(.monstral(40 * scale))
                            .foregroundColor(.clear)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.bottom, Spacing.xl + 20)
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isIdle)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedEntry?.id)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: deletingEntry?.id)
            }
            // TAP ANYWHERE ON SCREEN TO DESELECT
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    selectedEntry = nil
                    deletingEntry = nil
                }
            }
        }
    }
}

struct ReadOnlyMoodMap: View {
    let entries: [MapEntry]
    @Binding var selectedEntry: MapEntry?
    @Binding var deletingEntry: MapEntry?
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

            ForEach(entries) { entry in
                let isDeleting = deletingEntry?.id == entry.id
                let isSelected = selectedEntry?.id == entry.id

                Circle()
                    .fill(isDeleting ? Color.red : (isSelected ? Color.adios_black.opacity(0.35) : Color.adios_black))
                    .frame(width: 12 * scale, height: 12 * scale)
                    .scaleEffect(isDeleting ? 1.5 : 1.0)
                    .modifier(WiggleModifier(active: isDeleting))
                    .position(
                        // DENORMALIZE DOT POSITION
                        x: entry.x * mapSize.width,
                        y: entry.y * mapSize.height
                    )
                    .onTapGesture {
                        withAnimation {
                            deletingEntry = nil
                            selectedEntry = selectedEntry?.id == entry.id ? nil : entry
                        }
                    }
                    // LONG PRESS TO DELETE
                    .onLongPressGesture {
                        withAnimation {
                            selectedEntry = nil
                            deletingEntry = deletingEntry?.id == entry.id ? nil : entry
                        }
                    }
            }
        }
        .frame(width: mapSize.width, height: mapSize.height)
    }
}

// MARK: WIGGLE

struct WiggleModifier: ViewModifier {
    let active: Bool
    @State private var angle: Double = 0

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(active ? angle : 0))
            .onAppear {
                guard active else { return }
                startWiggle()
            }
            .onChange(of: active) { _, newValue in
                if newValue { startWiggle() } else { angle = 0 }
            }
    }

    private func startWiggle() {
        withAnimation(.easeInOut(duration: 0.12).repeatForever(autoreverses: true)) {
            angle = 10
        }
    }
}

// MARK: DELETE POPUP

struct DeletePopup: View {
    let entry: MapEntry
    var scale: CGFloat = 1.0
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(entry.food.uppercased())
                .font(.monstral(25 * scale))
                .foregroundColor(.adios_black)

            Text("Remove this entry from your map?")
                .font(.roundelay(13 * scale))
                .foregroundColor(.adios_black.opacity(0.6))

            Button(action: onDelete) {
                Text("Delete")
                    .font(.roundelay(16 * scale))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12 * scale)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.button))
                    .overlay(RoundedRectangle(cornerRadius: Radius.button).stroke(Color.adios_black, lineWidth: 2 * scale))
            }
            .padding(.top, Spacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Radius.card)
                    .fill(Color.adios_pink.opacity(0.75))
                    .offset(y: 4)
                RoundedRectangle(cornerRadius: Radius.card)
                    .fill(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.card)
                            .stroke(Color.adios_black, lineWidth: 2 * scale)
                    )
            }
        )
    }
}

struct EntryPopup: View {
    let entry: MapEntry
    var scale: CGFloat = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(entry.food.uppercased())
                .font(.monstral(25 * scale))
                .foregroundColor(.adios_black)

            ForEach(entry.benefits, id: \.self) { benefit in
                Text("• \(benefit)")
                    .font(.roundelay(13 * scale))
                    .foregroundColor(.adios_black.opacity(0.75))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Radius.card)
                    .fill(Color.adios_pink.opacity(0.75))
                    .offset(y: 4)
                RoundedRectangle(cornerRadius: Radius.card)
                    .fill(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.card)
                            .stroke(Color.adios_black, lineWidth: 2 * scale)
                    )
            }
        )
    }
}
