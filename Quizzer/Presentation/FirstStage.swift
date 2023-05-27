import SwiftUI

struct FirstStage: View {
    @EnvironmentObject var currentState: CurrentState
    
    func getQuestions(category: Category) -> [UInt8 : Binding<Question>] {
        var result = [UInt8 : Binding<Question>]()
        $currentState.questions.forEach { $question in
            if question.category == category.id {
                result[question.weight] = $question
            }
        }
        
        return result
    }
    
    private var usedWeights: [UInt8] {
        var result = Set([UInt8]())
        
        for category in currentState.categories {
            for (weight, _) in getQuestions(category: category) {
                result.insert(weight)
            }
        }
        
        return result.sorted()
    }
    
    private var filteredCategories: [Binding<Category>] {
        $currentState.categories.filter {
            $0.isShown.wrappedValue
        }
    }
    
    var body: some View {
        HStack {
            if filteredCategories.count != 0 {
                Spacer()
                ForEach(filteredCategories) { $category in
                    VStack {
                        Spacer()
                        ForEach(usedWeights, id: \.self) { weight in
                            if let question = getQuestions(category: category)[weight] {
                                FirstStageQuestion(question: question)
                            } else {
                                FirstStageQuestion(question: .constant(Question(question: "", answer: "", category: "", weight: 0, answered: true)))
                                    .hidden()
                            }
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}
