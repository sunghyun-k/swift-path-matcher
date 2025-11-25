import SwiftUI

struct RootView: View {
    @State private var urlText = "https://example.com/users/123"
    @Environment(\.openURL) private var openURL

    private let sampleURLs = [
        "/users/123",
        "/users/42/posts/999",
        "/settings",
        "/search/swift",
        "/search",
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("PathRouter Demo")
                .font(.title)
                .bold()

            VStack(alignment: .leading, spacing: 8) {
                Text("Enter URL:")
                    .font(.headline)
                TextField("URL", text: $urlText)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                VStack(spacing: 8) {
                    ForEach(sampleURLs, id: \.self) { sample in
                        Button(sample) {
                            urlText = "https://example.com\(sample)"
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.horizontal)

            Button("Route") {
                if let url = URL(string: urlText) {
                    openURL(url)
                }
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding(.vertical)
    }
}
