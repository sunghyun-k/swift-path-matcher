import SwiftUI

struct SearchView: View {
    struct Destination: Hashable {
        let query: String?
    }

    let destination: Destination

    init(_ destination: Destination) {
        self.destination = destination
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 80))
                .foregroundStyle(.purple)
            Text("Search")
                .font(.title)
                .bold()
            if let query = destination.query {
                Text("Query: \(query)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            } else {
                Text("No query provided")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Search")
    }
}
