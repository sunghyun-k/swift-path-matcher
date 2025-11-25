import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
struct SettingsView: View {
    struct Destination: Hashable {}

    init(_ destination: Destination = .init()) {}

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 80))
                .foregroundStyle(.gray)
            Text("Settings")
                .font(.title)
                .bold()
        }
        .navigationTitle("Settings")
    }
}
