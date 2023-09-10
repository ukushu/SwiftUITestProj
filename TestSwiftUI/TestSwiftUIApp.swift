import SwiftUI

@main
struct TestSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
//            ContentView()
            DirContentView()
        }
    }
}

struct DirContentView: View {
    @State var files: [String] = try! FileManager.default.contentsOfDirectory(atPath: "/Users/uks/Dox/pix")
    @State var sel: Set<String> = []
    
    var body: some View {
        DirectoryTableView(dirContent: $files, selection: $sel)
    }
}
