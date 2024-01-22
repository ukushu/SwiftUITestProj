import SwiftUI
import AVKit
import Witness
import MoreSwiftUI

@main
struct TestSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            ScrollView {
                
                VStack(alignment: .leading, spacing: 30) {
                    ForEach(AaronBack.allCases, id: \.self) { item in
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(item.asAnswerKeys(), id: \.self) { answerKey in
                                HStack {
                                    Text("lastWeekI".localized)
                                    
                                    Text( answerKey.localized )
                                }
                            }
                            
                            Divider()
                        }
                    }
                }
                .padding(30)
            }
        }
    }
}

enum AaronBack: String, RawRepresentable, CaseIterable {
    case q01
    case q02
    case q03
    case q04
    case q05
    case q06
    case q07
    case q08
    case q09
    case q10
    case q11
    case q12
    case q13
    case q14
    case q15
    case q16
    case q17
    case q18
    case q19
    case q20
    case q21
}

extension AaronBack {
    func asAnswerKeys() -> [String] {
        return Array(1...4).map { self.rawValue + ".answer"+"\($0)" }
    }
}
