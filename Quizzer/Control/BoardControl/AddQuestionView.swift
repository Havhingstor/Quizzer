import SwiftUI

enum AddedQuestionType {
    case masterQuestion
    case question(category: Category)
}

fileprivate enum ImageType {
    case question
    case solution
}

struct AddQuestionView: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openWindow) private var openWindow
    
    @State private var weight: Int = 0
    @State private var question = ""
    @State private var trueAnswer = ""
    @State private var alreadyExistsErrorShown = false
    @State private var showFileImportDialog = false
    @State private var questionImage = nil as NamedData?
    @State private var solutionImage = nil as NamedData?
    @State private var category = nil as Category?
    @State private var imageType = ImageType.question
    
    private var referencedQuestion = nil as Binding<Question>?
    
    private var weightPos: UInt {
        return UInt(abs(weight))
    }
    
    var paramsIllegal: Bool {
        guard let category else { return false }
        
        if let referencedQuestion,
           weightPos == referencedQuestion.weight.wrappedValue,
           category.id == referencedQuestion.category.wrappedValue {
            return false
        } else {
            return currentState.testExistenceOfQuestionParams(weight: weightPos, category: category.id)
        }
    }
    
    func submit() {
        if let category {
            if let referencedQuestion {
                if paramsIllegal {
                    alreadyExistsErrorShown = true
                } else {
                    withAnimation {
                        referencedQuestion.wrappedValue.question = question
                        referencedQuestion.wrappedValue.answer = trueAnswer
                        referencedQuestion.wrappedValue.category = category.id
                        referencedQuestion.wrappedValue.weight = weightPos
                        referencedQuestion.wrappedValue.image = questionImage
                        referencedQuestion.wrappedValue.solutionImage = solutionImage
                    }
                    dismiss()
                }
            } else {
                let question = Question(question: question, answer: trueAnswer, category: category, weight: weightPos, image: questionImage, solutionImage: solutionImage)
                do {
                    try withAnimation {
                        try currentState.addQuestion(question: question)
                    }
                    dismiss()
                } catch {
                    alreadyExistsErrorShown = true
                }
            }
        }
        
    }
    
    init(questionType: AddedQuestionType) {
        if case let .question(category) = questionType {
            _category = State(initialValue: category)
        }
    }
    
    init(question: Binding<Question>) {
        referencedQuestion = question
        let wrappedQuestion = question.wrappedValue
        _weight = State(initialValue: Int(wrappedQuestion.weight))
        self._question = State(initialValue: wrappedQuestion.question)
        _trueAnswer = State(initialValue: wrappedQuestion.answer)
        _questionImage = State(initialValue: wrappedQuestion.image)
        _solutionImage = State(initialValue: wrappedQuestion.solutionImage)
        _category = State(initialValue: wrappedQuestion.categoryObject ?? Category(name: "N/A"))
    }
    
    var body: some View {
        Form {
            Group {
                if category != nil {
                    Picker("Category", selection: $category) {
                        ForEach(currentState.categories) { category in
                            Text("\(category.name)").tag(Optional(category))
                        }
                    }
                }
                TextField("Weight:", value: $weight, format: .number)
                Text("Points: \(weightPos * currentState.baseScore)")
            }
            
            Spacer(minLength: 20)
            
            Group {
                TextField("Question:", text: $question)
                TextField("True Answer:", text: $trueAnswer)
            }
            
            Spacer(minLength: 20)
            
            Group {
                LabeledContent(questionImage?.name ?? "") {
                    HStack {
                        Button("Select Question Image") {
                            imageType = .question
                            showFileImportDialog = true
                        }
                        Button {
                            if let questionImage {
                                let data = questionImage.data
                                openWindow(value: data)
                            }
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(.borderless)
                        .hide(if: questionImage == nil)
                    }
                }
                .padding(.bottom, 5)
                
                LabeledContent(solutionImage?.name ?? "") {
                    HStack {
                        Button("Select Solution Image") {
                            imageType = .solution
                            showFileImportDialog = true
                        }
                        Button {
                            if let solutionImage {
                                let data = solutionImage.data
                                openWindow(value: data)
                            }
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(.borderless)
                        .hide(if: solutionImage == nil)
                    }
                }
            }
            
            Spacer(minLength: 20)
            
            Group {
                Button("Submit") {
                    submit()
                }
                
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
        .padding()
        .onChange(of: weight) { oldValue, newValue in
            if newValue < 0 {
                weight = oldValue
            }
        }
        .onSubmit {
            submit()
        }
        .alert("The combination of Category and Weight already exists", isPresented: $alreadyExistsErrorShown) {
            Button("OK") {}
        }
        .fileImporter(isPresented: $showFileImportDialog, allowedContentTypes: [.image]) { result in
            switch result {
                case let .success(url):
                    if url.startAccessingSecurityScopedResource() {
                        defer {
                            url.stopAccessingSecurityScopedResource()
                        }
                        
                        if let data = try? Data(contentsOf: url) {
                            let namedData = NamedData(name: url.lastPathComponent, data: data)
                            switch imageType {
                                case .question:
                                    questionImage = namedData
                                case .solution:
                                    solutionImage = namedData
                            }
                        }
                    }
                case .failure(_):
                    break
            }
        }
        .fixedSize()
    }
}

#Preview {
    AddQuestionView(questionType: .question(category: Category(name: "Category")))
        .fixedSize()
        .padding()
        .environmentObject(CurrentState.examples)
}

#Preview {
    AddQuestionView(questionType: .masterQuestion)
        .fixedSize()
        .padding()
        .environmentObject(CurrentState.examples)
}
