//
//  File.swift
//
//
//  Created by loki on 16.05.2021.
//

import Foundation

public enum TmpDir {
    case userRoot
    case userUnique
    case systemRoot
    case systemUnique
}

@available(iOS 13.4, *)
public extension URL {
    var isDirExist: Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: self.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    func makeSureDirExist() -> Result<URL,Error> {
        if self.isDirExist {
            return .success(self)
        } else {
            return self.mkdir()
        }
    }
    
    static var temporaryDirectory : URL {
//        if #available(macOS 10.12, *) {
//            return FileManager.default.temporaryDirectory
//        } else {
            return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        //}
    }
    
    static func tmp(_ type: TmpDir, prefix: String = "") -> Result<URL, Error> {
        switch type {
        case .userRoot:
            return .success(URL.temporaryDirectory.appendingPathComponent(prefix, isDirectory: true))
        case .userUnique:
            return .success(URL.temporaryDirectory.appendingPathComponent(prefix).appendingPathComponent(UUID().uuidString, isDirectory: true))
        case .systemRoot:
            return .success(URL(fileURLWithPath: "/tmp/", isDirectory: true).appendingPathComponent(prefix, isDirectory: true))
        case .systemUnique:
            return .success(URL(fileURLWithPath: "/tmp/", isDirectory: true).appendingPathComponent(prefix).appendingPathComponent(UUID().uuidString, isDirectory: true))
        }
    }
    
    static func randomTempDirectory() -> Result<URL,Error> {
        let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID().uuidString)
        return url.makeSureDirExist()
    }

    func mkdir() -> Result<URL,Error> {
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return .failure(error)
        }
        
        return .success(self)
    }
        
    var exists   : Bool  { FileManager.default.fileExists(atPath: self.path) }
    
    func rm() -> Result<(),Error> {
        do {
            try FileManager.default.removeItem(atPath: self.path)
        } catch {
            if let err = (error as NSError).userInfo["NSUnderlyingError"] as? NSError {
                if err.domain == "NSPOSIXErrorDomain" || err.code == 4 { // if file does'nt exist, do not treat it like error
                    return .success(())
                }
            }
            
            return .failure(error)
        }
        
        return .success(())
    }
    
    func write(content: String) -> Result<URL, Error> {
        do {
            try content.write(to: self, atomically: true, encoding: .utf8)
            return .success(self)
        } catch {
            return .failure(error)
        }
    }

    
    var isDirectory: Bool {
        return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    var isEmptyDirectory: Bool {
        return !isDirContainsFiles()
    }
    
    var isFileExists: Bool {
        if self.isDirectory { return false }
        return (try? self.checkResourceIsReachable()) ?? false
    }
    
    func isDirContainsFiles() -> Bool {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: self.path)
            
            if contents.count > 0 { return true }
        } catch { }
        
        return false
    }
    
    func getFiles() -> [URL] {
        var urls : [URL] = []
        
        if self.isDirExist {
            let enumerator:FileManager.DirectoryEnumerator? = FileManager.default.enumerator(at: self, includingPropertiesForKeys: nil, options: [], errorHandler: nil)
            
            while let url = enumerator?.nextObject() as? URL {
                if url.lastPathComponent == ".DS_Store" {
                    continue
                }
                urls.append(url)
            }
        }
        
        return urls
    }
    
    func getSubDirectories() -> [URL] {
        guard isDirectory else { return [] }
        return (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter(\.isDirectory)) ?? []
    }
}


public extension URL {
    static var userHome : URL   {
        URL(fileURLWithPath: userHomePath, isDirectory: true)
    }
    
    static var userHomePath : String   {
        let pw = getpwuid(getuid())
        if let home = pw?.pointee.pw_dir {
            return FileManager.default.string(withFileSystemRepresentation: home, length: Int(strlen(home)))
        }
        
        fatalError()
    }
}
