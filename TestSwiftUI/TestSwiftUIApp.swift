import SwiftUI
import AVKit
import Witness
import MoreSwiftUI
import Essentials

@main
struct TestSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @ObservedObject var model = ContentViewModel()
    
    var body: some View {
        VStack {
            if model.displayResults {
                ResultsView()
            } else {
                TestView()
            }
        }
    }
    
    @ViewBuilder
    func TestView() -> some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    ForEach(model.testResults.indices, id: \.self) { idx in
                        HStack {
                            Text("lastWeekI".localized)
                            
                            VStack{
                                Picker(selection: $model.testResults[idx].selectedAnswer, label: Text("")) {
                                    ForEach(model.testResults[idx].answers, id: \.self) { answerKey in
                                        Text( answerKey.localized ).tag(answerKey)
                                    }
                                }.pickerStyle(RadioGroupPickerStyle())
                            }
                        }
                    }
                }
                .padding(30)
            }
            Button("Show results") { model.switchDisplayResults() }
        }
    }
    
    
    @ViewBuilder
    func ResultsView() -> some View {
        VStack {
            Text("Depression Rate")
            
            ZStack {
                ProgressLine(progressRatio: $model.depressionRate , fillColor: .red)
                    .frame(height: 30)
                
                Text("\( Int(model.depressionPoints) )/\(model.depressionPointsMax)")
            }
            
            HStack {
                VStack {
                    Text("(C-A) Психічні проявлення")
                    
                    ZStack {
                        ProgressLine(progressRatio: $model.psihRate , fillColor: .red)
                            .frame(height: 20)
                        
                        Text("\( Int(model.psihPoints) )/\(model.psihPointsMax)")
                    }
                }
                
                VStack {
                    Text("(S-P) Фізичні проявлення")
                    
                    ZStack {
                        ProgressLine(progressRatio: $model.phizRate , fillColor: .red)
                            .frame(height: 20)
                        
                        Text("\(Int(model.phizPoints))/\(model.phizPointsMax)")
                    }
                }
            }
            
            HStack {
                Button("Back") { model.switchDisplayResults() }
                
                Button("Ok") { }
            }
        }
        .padding(10)
    }
}

class ContentViewModel: ObservableObject {
    @Published var testResults: [AaronBackPair] = AaronBack.allCases.map{ AaronBackPair(item: $0) }
    @Published private(set) var displayResults: Bool = true
    
    @Published private(set) var depressionPoints: CGFloat = 0
    let depressionPointsMax: Int = 63
    @Published var depressionRate: CGFloat = 0
    
    @Published var psihPoints: Int = 0
    let psihPointsMax: Int = 39
    @Published var psihRate: CGFloat = 0
    
    @Published var phizPoints: Int = 0
    let phizPointsMax: Int = 24
    @Published var phizRate: CGFloat = 0
    
    func switchDisplayResults() {
        if displayResults {
            displayResults = false
            return
        }
        
        let groupPoints = testResults.map { item in item.answers.firstIndexInt(where: { $0 == item.selectedAnswer})! }
        depressionPoints = CGFloat( groupPoints.reduce(0, +) )
        
        depressionRate = depressionPoints/57
        
        var tempPoints = testResults.first(13).map { item in item.answers.firstIndexInt(where: { $0 == item.selectedAnswer})! }
        psihPoints = tempPoints.reduce(0, +)
        psihRate = CGFloat( psihPoints ) / CGFloat(psihPointsMax)
        
        tempPoints = testResults.last(testResults.count-13).map { item in item.answers.firstIndexInt(where: { $0 == item.selectedAnswer})! }
        phizPoints = tempPoints.reduce(0, +)
        phizRate = CGFloat( phizPoints ) / CGFloat(phizPointsMax)
        
        displayResults.toggle()
    }
    
    /*
     Общий балл по шкале может интерпретироваться следующим образом:
     • 0−9 – отсутствие депрессивных симптомов;
     • 10−18 – субдепрессия, умеренная депрессия;
     • 19−29 – выраженная депрессия средней тяжести;
     • 30−63 – тяжелая депрессия.
     Результат онлайн-теста сам по себе не может быть критерием для постановки диагноза депрессии. Диагноз может поставить только специалист по совокупности факторов.
     */
}

struct AaronBackPair: Hashable {
    let item: AaronBack
    var selectedAnswer: String
    var answers: [String]
    
    init(item: AaronBack) {
        self.item = item
        answers = item.asAnswerKeys()
        selectedAnswer = answers.first!
    }
}

enum AaronBack: String, RawRepresentable, CaseIterable {
    case q01,q02,q03,q04,q05,q06,q07,q08,q09,q10,q11,q12,q13,q14,q15,q16,q17,q18,q19,q20,q21
}

extension AaronBack {
    func asAnswerKeys() -> [String] {
        return Array(1...4).map { self.rawValue + ".answer"+"\($0)" }
    }
}
