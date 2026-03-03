import SwiftUI
import SwiftData

@main
struct MyGeckoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Gecko.self, EggRecord.self])
    }
}
