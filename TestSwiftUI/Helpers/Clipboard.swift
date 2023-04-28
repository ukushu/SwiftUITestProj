import AppKit

public class Clipboard {
    public static func set(text: String?) {
        if let text = text {
            let pasteBoard = NSPasteboard.general
                pasteBoard.clearContents()
                pasteBoard.setString(text, forType: .string)
        }
    }
    
    @available(macOS 10.13, *)
    public static func set(url: URL?) {
        guard let url = url else { return }
        let pasteBoard = NSPasteboard.general
        
        pasteBoard.clearContents()
        pasteBoard.setData(url.dataRepresentation, forType: .URL)
    }
    
    @available(macOS 10.13, *)
    public static func set(imageFrom urlContent: URL?) {
        guard let url = urlContent,
              let nsImage = NSImage(contentsOf: url)
        else { return }
        
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.writeObjects([nsImage])
    }
    
    public static func clear() {
        NSPasteboard.general.clearContents()
    }
    
    public static func copyFileContent(withUrl url: URL?) {
        guard let url = url else { return }
        
        if let fileRefURL = (url as NSURL).fileReferenceURL() as NSURL? {
            print(fileRefURL)
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.writeObjects([fileRefURL])
            pasteboard.setString(fileRefURL.relativeString, forType: .fileURL)
        }
    }
    
    public static func copyFilesContent(_ urls: [URL]) {
        let fileRefs = urls.compactMap{ ($0 as NSURL).fileReferenceURL() as NSURL? }
        
        if fileRefs.count > 0 {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.writeObjects(fileRefs)
            
            let descr = fileRefs.map{ $0.relativeString }.joined(separator: "; ").dropLast(2).asString()
            pasteboard.setString(descr, forType: .fileURL)
        }
    }
    
    public static func copyFileContent(withPath path: String?) {
        copyFileContent(withUrl: path?.asURL())
    }
}
