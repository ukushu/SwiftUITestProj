import SwiftUI
import AVKit
import SwiftFileSystemEvents
import Witness


@main
struct TestSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
//            ContentView()
//            DirContentView()
        }
    }
}

//struct DirContentView: View {
//    @State var files: [String] = try! FileManager.default.contentsOfDirectory(atPath: "/Users/uks/Dox/pix")
//    @State var sel: Set<String> = []
//
//    var body: some View {
//        DirectoryTableView(dirContent: $files, selection: $sel)
//    }
//}

struct MainView: View {
    @ObservedObject var model = MainViewModel()
    
    var body: some View {
        Text("hello")
            .padding()
    }
}


class MainViewModel: ObservableObject {
    let witness: Witness
    
    init() {
        let desktopPath = "/Users/uks/Desktop"
        
        self.witness = Witness(paths: [desktopPath], flags: [.NoDefer, .FileEvents], latency: 0) { events in
            var events = events
                .filter({ !$0.path.ends(with: ".DS_Store") })
                .filter{ !"\($0)".ends(with: "flags: Item Is File)") } // empty event with no usefull data
            
            guard events.count > 0 else { return }
            print("\n\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
            
            var uksEvents = [UKSFileEvent]()
            
            // REMOVED with skipping RecicleBin
            if events.allSatisfy({ $0.flags.contains(.ItemRemoved)})
            {
                events.forEach { uksEvents.append(.removed(from: $0.path) ) }
                events = []
            }
            else
            // REMOVED
            if events.allSatisfy({ $0.flags.contains(.ItemRenamed) && !FileManager.default.fileExists(atPath: $0.path) })
            {
                events.forEach { uksEvents.append(.removed(from: $0.path) ) }
                events = []
            }
            else
            //RENAMED
            if (events.count % 2 == 0) && events.allSatisfy({ $0.flags.contains(.ItemRenamed) }) {
                stride(from: 0, to: events.count - 1, by: 2).forEach { idx in
                    uksEvents.append(.renamed(from: events[idx].path, to: events[idx+1].path))
                }
                events = []
            }
            
            events.filter({ $0.flags.contains(.ItemCreated) }).forEach{ event in
                let currPath = event.path
                uksEvents.append( .modified(currPath) )
                events.removeFirst{ $0 == event }
            }
            
            print("\n----\nuksEvents: \n\(uksEvents)")
            
            if events.count > 0 {
                print("MISSED Events:")
                events.forEach{ $0.printDetails() }
                
                fatalError("horrible error")
            }
        }
    }
}


enum UKSFileEvent {
    case renamed(from: String, to: String)
    case modified(String)
    case removed(from: String)
}

extension FileEvent {
    var uksIsDeleted: Bool {
        flags.contains(.ItemRenamed) && !FileManager.default.fileExists(atPath: self.path)
    }
    
    func printDetails() {
        print("=================")
        let event = self
        print(event)
    }
}

extension FileEvent: Equatable {
    public static func == (lhs: FileEvent, rhs: FileEvent) -> Bool {
        lhs.path == rhs.path &&
        lhs.flags == rhs.flags
    }
    
    
}

/*
* Видалений в корзину:
    * FileEvent(path: "/Users/uks/Desktop/Untitled_.rtf", flags: Item Renamed, Item Is File)
    * тепер файлу не існує
 
* Відновлений з корзини:
    * FileEvent(path: "/Users/uks/Desktop/Untitled_.rtf", flags: Item Renamed, Item Is File)
    * тепер файл існує
 
 * перейменовується папка
 * Перейменувати файл:
     * FileEvent(path: "/Users/uks/Desktop/Untitled_.rtf", flags: Item Renamed,Item Is File)
     * FileEvent(path: "/Users/uks/Desktop/Untitled.rtf" , flags: Item Renamed,Item Is File)
 
 * Переписати файл поверх перенісши його:
    * FileEvent(path: "/Users/uks/Desktop/Untitled.rtf", flags: Item Removed,Item Is File)
    * FileEvent(path: "/Users/uks/Desktop/untitled folder_/Untitled.rtf", flags: Item Renamed,Item Is File)
    * FileEvent(path: "/Users/uks/Desktop/Untitled.rtf", flags: Item Renamed,Item Is File)
 
 * скопіювати папку з файлами
    * створюється папка
    * створюються всі підфайли купою івент сетів


 
 
 
 * Переписати файл поверх скопіювавши його:
    * FileEvent(path: "/Users/uks/Desktop/Untitled.rtf", flags: Item Removed,Item Is File)
    * FileEvent(path: "/Users/uks/Desktop/untitled folder_/Untitled.rtf", flags: Item Inode Meta Modification,Item Renamed,Item Xattr Modification,Item Is File)
    * FileEvent(path: "/Users/uks/Desktop/Untitled.rtf", flags: Item Is File)
    * FileEvent(path: "/Users/uks/Desktop/Untitled.rtf", flags: Item created,Item Inode Meta Modification,Item Change Owner,Item Is File)
    
* Створити файл:
    * FileEvent(path: "/Users/uks/Desktop/Untitled.rtf", flags: Item Renamed,Item Xattr Modification,Item Is File)
    * FileEvent(path: "/Users/uks/Desktop/Untitled.rtf", flags: Item Xattr Modification,Item Is File)
    
* Переписати 2 файли:
    * FileEvent(path: "/Users/uks/Desktop/untitled folder_/book 2 copy 10.txt", flags: Item Renamed,Item Is File)
    * FileEvent(path: "/Users/uks/Desktop/book 2 copy 10.txt", flags: Item Renamed,Item Is File)
    * FileEvent(path: "/Users/uks/Desktop/untitled folder_/book 2 copy 11.txt", flags: Item Renamed,Item Is File)
    * FileEvent(path: "/Users/uks/Desktop/book 2 copy 11.txt", flags: Item Renamed,Item Is File)
 
*/


