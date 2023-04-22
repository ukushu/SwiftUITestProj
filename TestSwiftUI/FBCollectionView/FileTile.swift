import Foundation
import SwiftUI

struct FileTile: View {
    let url: URL
    let isSelected: Bool
    let recent: RecentFile
    
    init(url: URL, isSelected: Bool) {
        self.url = url
        self.isSelected = isSelected
        self.recent = FBCollectionCache.getMetaFor(url: url)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            FileIcon()
            
            Space(6)
            
            AppTitle()
            
            Space(2)
            
            AppTimeStamp()
        }
        .background(Color.clickableAlpha)
        .help(recent.name)
    }
}


extension FileTile {
    func FileIcon() -> some View {
        RoundedRectangle(cornerRadius: 8)
            .background{
                if isSelected {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color.gray)
                        .opacity(0.2)
                        .padding(.all, -4)
                } else {
                    EmptyView()
                }
            }
            .foregroundColor(.clear)
            .frame(width: 126, height: 126)
            .overlay {
                FilePreview(url: url)
            }
    }
    
    func AppTitle() -> some View {
        Text(recent.name)
            .fontWeight(.regular)
            .lineLimit(1)
            .truncationMode(.middle)
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .background(isSelected ? Color(hex: 0x4184E9) : Color.clear)
            .cornerRadius(4)
    }
    
    @ViewBuilder
    func AppTimeStamp() -> some View {
        if let date = recent.lastUseDate {
            Text(date.readableString)
                .multilineTextAlignment(.center)
                .font(.system(size: 11))
                .lineLimit(1)
        } else {
            Text("-")
        }
    }
}

////////////////////////////
///AppTileEmpty
///////////////////////////



//    .onDrag {
//        appState.isDragging = true
//        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
//            appDelegate.hideMainWindows()
//        }
//        let provider = NSItemProvider(item: app.url! as NSSecureCoding?, typeIdentifier: UTType.fileURL.identifier as String)
//        provider.suggestedName = app.url!.lastPathComponent
//        return provider
//    } preview: {
//        if let icon = app.icon {
//            Image(nsImage: icon)
//                .resizable()
//                .frame(width: 125, height: 125)
//        }
//    }

