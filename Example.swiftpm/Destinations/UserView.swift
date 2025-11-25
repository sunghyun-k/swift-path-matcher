import SwiftUI

struct UserView: View {
    struct Destination: Hashable {
        let id: String
    }

    let destination: Destination

    init(_ destination: Destination) {
        self.destination = destination
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            Text("User Profile")
                .font(.title)
                .bold()
            Text("ID: \(destination.id)")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("User")
    }
}
