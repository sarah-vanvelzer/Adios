import SwiftUI

struct LogView: View {
    @EnvironmentObject var state: AppState
    @State private var input: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        GeometryReader { geo in
            // SCALE FACTOR
            let scale = CGFloat.adiosScale(for: geo.size.width)

            ZStack {
                Color.adios_cream.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {

                    BackButton(action: { state.navigate(to: .home) }, scale: scale)
                        .padding(.top, Spacing.md)
                        .padding(.leading, Spacing.md)

                    Text("DESCRIBE\nYOUR\nBITE...")
                        .font(.monstral(55 * scale))
                        .foregroundColor(.adios_black)
                        .lineSpacing(4)
                        .padding(.top, Spacing.md)
                        .padding(.horizontal, Spacing.lg)

                    Spacer()

                    TextField("What did you eat?", text: $input)
                        .font(.roundelay(18 * scale))
                        .foregroundColor(.adios_black)
                        .tint(.adios_pink)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, 14 * scale)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.input)
                                .stroke(Color.adios_black, lineWidth: 2)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: Radius.input)
                                .fill(Color.white)
                        )
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onSubmit { submit() }
                        // LIMIT CHARACTER INPUT
                        .onChange(of: input) { _, newValue in
                            let limited = String(newValue.prefix(50))
                            if limited != newValue {
                                input = limited
                            }
                        }
                        .padding(.horizontal, Spacing.lg)

                    HStack {
                        Spacer()
                        Text("\(input.count)/50")
                            .font(.roundelay(12 * scale))
                            .foregroundColor(input.count > 40 ? .adios_pink : .adios_black.opacity(0.4))
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, 6)

                    Spacer()

                    Button("Submit") { submit() }
                        .buttonStyle(AdiosButtonStyle(fill: .adios_pink, text: .adios_black, stroke: .adios_black, scale: scale))
                        .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                        .animation(.easeInOut(duration: 0.2), value: input.isEmpty)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, Spacing.lg)
                }
            }
            .onAppear { isFocused = true }
        }
    }

    // MARK: SUBMIT
    
    private func submit() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let benefits = BenefitsEngine.benefits(for: trimmed)
        state.navigate(to: .benefits(food: trimmed, lines: benefits))
    }
}
