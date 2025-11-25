import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
struct PostView: View {
    struct Destination: Hashable {
        let userID: String
        let postID: String
    }

    let destination: Destination

    init(_ destination: Destination) {
        self.destination = destination
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 80))
                .foregroundStyle(.orange)
            Text("Post Detail")
                .font(.title)
                .bold()
            Text("User: \(destination.userID)")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Post: \(destination.postID)")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Post")
    }
}
