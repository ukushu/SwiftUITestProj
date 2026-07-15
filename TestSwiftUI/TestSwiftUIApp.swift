import SwiftUI
import AVKit
import MoreSwiftUI
import Essentials

@main
struct TestSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            MultyRepoViewNew()
        }
    }
}


let folderMain = RepoSubmodInfo(name: "Taogit", state: .neutral, branchName: "main", children: [
    RepoSubmodInfo(name: "Essentials", state: .neutral, branchName: "master", children: []),
    RepoSubmodInfo(name: "MoreSwiftUI", state: .headDetached, branchName: "masterClone", children: []),
    RepoSubmodInfo(name: "STTextView", state: .notCommitedData, branchName: "assignSuccess", children: [
        RepoSubmodInfo(name: "Submod Push needed", state: .pushNeeded, branchName: "infiniteChannels", children: []),
        RepoSubmodInfo(name: "Submod conflicts", state: .conflictsInside, branchName: "lazyFutures", children: []),
        RepoSubmodInfo(name: "Submod missigObj", state: .missingObjects, branchName: "withMacross", children: []),
    ]),
    RepoSubmodInfo(name: "OctoKit", state: .notInitialized, branchName: "SuperLongBranchNameFuckYouFuckingFuck_FuckYouFuckingFuck_FuckYouFuckingFuck_Motherfucker", children: []),
    RepoSubmodInfo(name: "OctoCat", state: .unregistered, branchName: "main", children: []),
    RepoSubmodInfo(name: "AppCore", state: .neutral, branchName: "main", children: [
        RepoSubmodInfo(name: "SomeSubmod 1", state: .bareRepo, branchName: "main", children: []),
        RepoSubmodInfo(name: "SomeSubmod 2", state: .operationInProgress, branchName: "main", children: [])
    ])
])

//let folderMain = RepoInfo(name: "Taogit", state: .neutral, branchName: "main", children: [
//    RepoInfo(name: "Essentials", state: .neutral, branchName: "master", children: []),
//    RepoInfo(name: "MoreSwiftUI", state: .headDetached, branchName: "main", children: []),
//    RepoInfo(name: "STTextView", state: .notCommitedData, branchName: "main", children: [
//        RepoInfo(name: "Submod Push needed", state: .pushNeeded, branchName: "main", children: []),
//        RepoInfo(name: "Submod conflicts", state: .conflictsInside, branchName: "main", children: []),
//        RepoInfo(name: "Submod missigObj", state: .missingObjects, branchName: "main", children: []),
//    ]),
//    RepoInfo(name: "OctoKit", state: .notInitialized, branchName: "main", children: []),
//    RepoInfo(name: "OctoCat", state: .unregistered, branchName: "main", children: []),
//    RepoInfo(name: "AppCore", state: .neutral, branchName: "main", children: [
//        RepoInfo(name: "SomeSubmod 1", state: .bareRepo, branchName: "main", children: []),
//        RepoInfo(name: "SomeSubmod 2", state: .operationInProgress, branchName: "main", children: [])
//    ])
//])
