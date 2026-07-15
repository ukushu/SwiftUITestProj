
import SwiftUI
import MoreSwiftUI

struct MultyRepoViewNew: View {
    var body: some View {
        RecursiveRepoView(folder: folderMain)
            .padding(.leading, 1)
            .padding(30)
    }
}

struct RecursiveRepoView: View {
    var plateOffsetLvl: CGFloat = 0
    
    var folder: RepoSubmodInfo
    
    var body: some View {
        VStack(spacing: 0) {
            RepositoryItemLine(folder: folder, plateOffsetLvl: plateOffsetLvl)
                .contextMenu {
                    if folder.state == .headDetached {
                        CtxMenuBtn(sfImg: "externaldrive.badge.plus", lbl: "Try fix detached HEAD", action: { })
                    }
                    
                    if folder.state == .operationInProgress {
                        
                    } else if folder.state == .notInitialized {
                        CtxMenuBtn(sfImg: "wand.and.sparkles.inverse", lbl: "Initialize + update", action: { })
                    } else {
                        CtxMenuBtn(sfImg: "line.3.horizontal.decrease", lbl: "Open", action: { })
                        
                        CtxMenuBtn(sfImg: "trash", lbl: "Fetch", action: { })
                        
                        CtxMenuBtn(sfImg: "trash", lbl: "Pull",  action: { })
                        
                        CtxMenuBtn(sfImg: "externaldrive.badge.plus", lbl: "Add submodule", action: { })
                    }
                    
                    Divider()
                    
                    CtxMenu(sfImg: "exclamationmark.3", lbl: "Destructive"){
                        CtxMenuBtn(sfImg: "externaldrive.badge.plus", lbl: "Change URL", action: { })
                        
                        CtxMenuBtn(sfImg: "trash", lbl: "Deinit + delete", action: { })
                    }
                }
            
            if !folder.children.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(folder.children) { child in
                        RecursiveRepoView(plateOffsetLvl: plateOffsetLvl + 1, folder: child)
                    }
                }
            }
        }
    }
}

//
// Preview
//

struct FolderTreeView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(.vertical) {
            MultyRepoViewNew()
        }
        .frame(width: 700, height: 700)
    }
}
