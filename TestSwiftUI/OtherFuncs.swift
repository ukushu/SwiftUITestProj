import Foundation
import AppKit

func getDirContents1() -> ArraySlice<URL>  {
    let wallpapers = URL.userHome.appendingPathComponent("/Desktop/Wallpapers")
    
    let url = wallpapers.exists ? wallpapers : URL.userHome.appendingPathComponent("Desktop")
    
    return getDirContentsFor(url: url)
        .sorted { $0 < $1 }
        .compactMap{ val -> URL? in val }
        .first(99999)
}

func getDirContents2() -> ArraySlice<URL> {
    return getDirContentsFor(url: URL.userHome.appendingPathComponent("Downloads") )
        .sorted { $0 < $1 }
        .compactMap{ val -> URL? in val }
        .first(99999)
}

func getDirContents3() -> ArraySlice<URL>  {
    return getDirContentsFor(url: URL.userHome.appendingPathComponent("/Desktop/Test") )
        .sorted { $0 < $1 }
        .compactMap{ val -> URL? in val }
        .first(99999)
}

func getDirContentsFor(url: URL) -> [URL] {
    let fileManager = FileManager.default
    
    do {
        let directoryContents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        
        return directoryContents
    } catch {
        print("Error while enumerating files \(url.path): \(error.localizedDescription)")
    }
    
    return []
}

///////////////////////////
///HELPERS
//////////////////////////
