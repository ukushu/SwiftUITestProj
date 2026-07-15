
import SwiftUI
import MoreSwiftUI

let branchNameFont: NSFont = NSFont(name: "SF Pro", size: 16)!
let branchNameMaxWidth: CGFloat = 150

struct RepositoryItemLine: View {
    let folder: RepoSubmodInfo
    var plateOffsetLvl: CGFloat
    
    @State private var hovering = false
    private var childOffsetH: CGFloat { plateOffsetLvl * 40 }
    
    var body: some View {
        HStack {
            RepoPlate(isRoot: plateOffsetLvl == 0, folder: folder)
                .offset(x: childOffsetH)
            
            Spacer(minLength: 100)
            
            HStack(spacing: 0) {
                Button(action: { }) {
                    Text(folder.branchName)
                        .font(Font(branchNameFont))
                }
            }
            .buttonStyle(ButtStyle.InBetween())
            
            SyncBtnsPanel(folder: folder)
        }
        .onHover { h in
            withAnimation {
                self.hovering = h
            }
        }
        .frame(minHeight: 44)
        .background(Color.clickableAlpha)
        .background {
            if hovering {
                Rectangle()
                    .frame(width: 1500)
                    .mask {
                        LinearGradient(
                            colors: [.black, .black, .clear, .clear],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                    }
                    .opacity(0.2)
            }
        }
    }
}

fileprivate struct SyncBtnsPanel: View {
    let folder: RepoSubmodInfo
    
    var body: some View {
        HStack(spacing: 3) {
            commitDetailsBtn()
            
            Spacer(minLength: 0)
            
            switch folder.state {
            case .pushNeeded:
                Button(action: { }) {
                    BtnPlate {
                        HStack(spacing: 1) {
                            Text.sfSymbol("arrow.up")
                                .font(.custom("SF Pro", size: 11).weight(.bold))
                            
                            Text("Push")
                        }
                    }
                }
                
            case .notInitialized:
                Button(action: { }) {
                    BtnPlate {
                        Text("Init")
                    }
                }
            case .headDetached:
                Button(action: { }) {
                    BtnPlate {
                        Text("Try fix")
                    }
                }
            case .notCommitedData:
                Button(action: { }) {
                    BtnPlate {
                        Text("Review")
                    }
                }
            case .conflictsInside:
                Button(action: { }) {
                    BtnPlate {
                        Text("Resolve")
                    }
                }
            default:
                Button(action: { }) {
                    Text.sfIcon("arrow.down.square", size: 20)
                }
                
                Button(action: { }) {
                    Text.sfIcon("arrow.down.square.fill", size: 20)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(width: 80)
        .theme(.normal(.lvl_8))
        .disabled(!folder.state.syncBtnsAccessible)
        .opacity(folder.state.syncBtnsAccessible ? 1 : 0.5)
    }
    
    
    func commitDetailsBtn() -> some View {
        PopoverButtSimple(label: {
            BtnPlate(width: 18) {
                Text("i")
                    .bold()
            }
        }) {
            VStack {
                Image("repoContent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 550)
            }
            .padding(20)
        }
        .buttonStyle(.plain)
    }

}

fileprivate struct RepoPlate: View {
    var isRoot: Bool
    var folder: RepoSubmodInfo
    
    var body: some View {
        HStack {
            RepoPoint(folder: folder, isRoot: isRoot, color: .black)
            
            VStack(alignment: .leading) {
                Text(folder.name)
                    .font(.custom("SF Pro", size: 15))
                    .opacity(folder.state == .notInitialized ? 0.5 : 1)
                
                folder.state.asHelpStrView()
            }
        }
        .frame(minHeight: 30)
    }
}

//
// Helpers
//

fileprivate struct RepoPoint: View {
    var folder: RepoSubmodInfo
    
    let isRoot: Bool
    let color: Color
    
    static var diameter: CGFloat = 20
    static var lineWidth: CGFloat = 2
    static var pointOffset: CGFloat = 30
    
    let uninitOpacity: CGFloat = 0.4
    private let detachedHeadColor = Color.red.opacity(0.7)
    
    
    var body: some View {
        folder.state.asIconView()
            .if(isRoot == false) {
                $0.background {
                    LeftBottomRoundedRect(size: RepoPoint.diameter, radius: RepoPoint.diameter/2)
                        .stroke(Color.primary, lineWidth: 2)
                        .padding(3)
                        .mask(
                            LinearGradient(
                                colors: [.clear, .black],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .offset(x: -27, y: -9)
                }
            }
            
    }
}

fileprivate struct LeftBottomRoundedRect: Shape {
    var size: CGFloat = 50
    var radius: CGFloat = 10
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let s = size
        let r = min(radius, s / 2)
        
        // Старт — ліва сторона (зверху вниз до радіуса)
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: s - r))
        
        // Лівий нижній кут
        path.addArc(
            center: CGPoint(x: r, y: s - r),
            radius: r,
            startAngle: .degrees(180),
            endAngle: .degrees(90),
            clockwise: true
        )
        
        // Нижня сторона
        path.addLine(to: CGPoint(x: s, y: s))
        
        return path
    }
}

struct BtnPlate<C: View>: View {
    var width: CGFloat? = nil
    var content: () -> C
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .frame(width: width ?? 55, height: 18)
            .maskReverse {
                content()
            }
    }
}
