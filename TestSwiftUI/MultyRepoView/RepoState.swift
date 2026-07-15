
import SwiftUI
import MoreSwiftUI

enum RepoState: CaseIterable {
    case neutral
    case notInitialized
    case headDetached
    case notCommitedData
    case operationInProgress
    case bareRepo
    case pushNeeded
    case conflictsInside
    case unregistered
    case missingObjects
}

extension RepoState {
    var syncBtnsAccessible: Bool {
        switch self {
        case .neutral:
            true
        case .notInitialized:
            true
        case .headDetached:
            true
        case .notCommitedData:
            true
        case .operationInProgress:
            false
        case .bareRepo:
            true
        case .pushNeeded:
            true
        case .conflictsInside:
            true
        case .unregistered:
            false
        case .missingObjects:
            false
        }
    }
    
    var color: Color {
        switch self {
        case .neutral:
            Color.accentColor
        case .notInitialized:
            Color(hex: 0xff5555)
        case .headDetached:
            RepoState.notInitialized.color
        case .notCommitedData:
            Color.orange
        case .operationInProgress:
            Color.clear
        case .bareRepo:
            Color.orange
        case .pushNeeded:
            Color.orange
        case .conflictsInside:
            RepoState.notInitialized.color
        case .unregistered:
            RepoState.notInitialized.color
        case .missingObjects:
            RepoState.notInitialized.color
        }
    }
    
    private var helpStr: String? {
        switch self {
        case .neutral:
            nil
        case .operationInProgress:
            nil
        case .notInitialized:
            "Not initialized"
        case .headDetached:
            "Detached HEAD"
        case .notCommitedData:
            "Uncommited data"
        case .bareRepo:
            "Bare repo (no working tree)"
        case .pushNeeded:
            "Push needed"
        case .conflictsInside:
            "Conflicts inside"
        case .unregistered:
            "Unregistered (no gitlink in index)"
        case .missingObjects:
            "Missing objects (.git dir is broken)"
        }
    }
    
    @ViewBuilder
    func asHelpStrView() -> some View {
        if let helpStr {
            Text(helpStr)
                .font(.custom("SF Pro", size: 10).monospaced())
                .foregroundStyle(color)
        }
    }
    
    var subIconStr: String? {
        switch self {
        case .operationInProgress:
            return nil
        case .notInitialized:
            return nil
        case .neutral:
            return nil
        case .headDetached:
            return "face.dashed"
        case .notCommitedData:
            return "exclamationmark.circle.fill"
        case .bareRepo:
            return "rectangle.3.group.dashed"
        case .pushNeeded:
            return "arrow.up.circle.fill"
        case .conflictsInside:
            return "timelapse"
        case .unregistered:
            return "signpost.left"
        case .missingObjects:
            return "waveform.path.ecg"
        }
    }
    
    @ViewBuilder
    func asIconView() -> some View {
        switch self {
        case .operationInProgress:
            LoadingView()
            
        case .notInitialized:
            Image(systemName: "externaldrive")
                .renderingMode(.template)
                .resizable()
                .scaledToFill()
                .frame(width: 30, height: 25)
                .foregroundStyle(color)
            
        case .neutral:
            Image(systemName: "externaldrive.fill")
                .renderingMode(.template)
                .resizable()
                .scaledToFill()
                .frame(width: 30, height: 25)
            
        case .headDetached, .notCommitedData, .bareRepo, .pushNeeded, .conflictsInside, .unregistered, .missingObjects:
            
            let subIcon = subIconStr ?? "trash"
            
            DoubleIcon(icon: "externaldrive.fill",
                       iconSize: 30,
                       subIcon: subIcon,
                       subIconColor: color,
                       subIconSize: 13,
                       subOffsetX: 5,
                       subOffsetY: 1,
                       maskPadding: 4)
        }
    }
}
