import Foundation


//extension NSImage {
//    var pixelSize: NSSize? {
//        guard let rep = self.representations.first else { return nil }
//
//        return NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
//    }
//}










//InternalCollectionView
//override func becomeFirstResponder() -> Bool {
////        becomeFirstResponder(idx: 0)
//    super.becomeFirstResponder()
//}
//
//func becomeFirstResponder(idx: Int) -> Bool {
//    if selectionIndexPaths.count == 0 {
//        for section in 0..<numberOfSections {
//            if numberOfItems(inSection: section) >= idx {
//                selectionIndexPaths = [IndexPath(item: idx, section: section)]
//                break
//            }
//        }
//    }
//
//    return super.becomeFirstResponder()
//}











//
//struct FileTileEmpty: View {
//    var body: some View {
//        VStack(alignment: .center, spacing: 0) {
//            RRect()
//                .frame(width: 90, height: 118)
//                .frame(width: 126, height: 126)
//
//            Space(6)
//
//            RRect()
//                .frame(width: 90, height: 15)
//
//            Space(4)
//
//            RRect()
//                .frame(width: 126, height: 13)
//        }
//    }
//}
//
//fileprivate struct RRect: View {
////    @Environment(\.colorScheme) var colorScheme
//
//    var body: some View {
//        RoundedRectangle(cornerRadius: 12)
//            .fill(Color("Filler"))
////            .foregroundColor( colorScheme == .dark ? Color(rgbaHex: 0xffffff07) : Color(rgbaHex: 0x00000007) )
//    }
//}
