import Foundation
import SwiftUI

struct AppTile: View {
    let app: RecentFile
    let isSelected: Bool
//    @Binding var selections: Set<String>
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            AppIcon()
            
            Space(6)
            
            AppTitle()
            
            Space(2)
            
            AppTimeStamp()
        }
        .background(Color.clickableAlpha)
        .help(app.name)
    }
}

extension AppTile {
    func AppIcon() -> some View {
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
                //UKSImage(url: app.url, size: 125)
                UKSImagePath2(path: app.path, size: 125)
                    .frame(width: 125, height: 125)
            }
    }
    
    func AppTitle() -> some View {
        Text(app.name)
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
        if let date = app.lastUseDate {
            Text(date.readableString)
                .multilineTextAlignment(.center)
                .font(.system(size: 11))
                .lineLimit(1)
        } else {
            Text("-")
        }
    }
}

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

