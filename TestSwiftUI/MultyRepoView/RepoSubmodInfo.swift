
import Foundation

struct RepoSubmodInfo: Identifiable {
    let id = UUID()
    let name: String
    let state: RepoState
    let branchName: String
    
    var children: [RepoSubmodInfo] = []
}
