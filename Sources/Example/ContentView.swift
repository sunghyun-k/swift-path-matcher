import PathMatcher
import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
struct ContentView: View {
    @State private var path = NavigationPath()
    @State private var pathRouter: PathRouter!

    var body: some View {
        NavigationStack(path: $path) {
            RootView()
                .navigationDestination(for: UserView.Destination.self) { UserView($0) }
                .navigationDestination(for: PostView.Destination.self) { PostView($0) }
                .navigationDestination(for: SettingsView.Destination.self) { SettingsView($0) }
                .navigationDestination(for: SearchView.Destination.self) { SearchView($0) }
        }
        .environment(\.openURL, OpenURLAction { url in
            pathRouter.handle(url)
            return .handled
        })
        .onAppear {
            setupRouter()
        }
    }

    private func setupRouter() {
        guard pathRouter == nil else { return }

        pathRouter = PathRouter()
        pathRouter.append {
            Literal("users")
            Parameter()
        } handler: { _, userID in
            path.append(UserView.Destination(id: userID))
        }

        pathRouter.append {
            Literal("users")
            Parameter()
            Literal("posts")
            Parameter()
        } handler: { _, params in
            let (userID, postID) = params
            path.append(UserView.Destination(id: userID))
            path.append(PostView.Destination(userID: userID, postID: postID))
        }

        pathRouter.append {
            Literal("settings")
        } handler: { _, _ in
            path.append(SettingsView.Destination())
        }

        pathRouter.append {
            Literal("search")
            OptionalParameter()
        } handler: { _, query in
            path.append(SearchView.Destination(query: query))
        }
    }
}

@available(iOS 16.0, macOS 13.0, *)
#Preview {
    ContentView()
}
