import SwiftUI

struct MasterQuestionEditView: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.dismiss) private var dismiss
    
    @State var options = [String]()
    @State var selectedOptions = Set<String>()
    @State var trueOption = nil as String?
    @State var addOptionSheetPresented = false
    
    private var referencedQuestion: QuestionVars
    
    init() {
        let question = Question(question: "", answer: "", category: Category(name: ""), weight: 0)
        referencedQuestion = QuestionVars(questionObject: question)
    }
    
    func loadFromMasterQuestion() {
        guard let masterQuestion = currentState.masterQuestion else { return }
        referencedQuestion.question = masterQuestion.question
        referencedQuestion.image = masterQuestion.image
        referencedQuestion.solutionImage = masterQuestion.solutionImage
        options = masterQuestion.optionsInternal
        trueOption = options[masterQuestion.answerInternal]
    }
    
    func deleteSelected() {
        for option in selectedOptions {
            options.removeAll { optionItem in
                optionItem == option
            }
        }
        
        selectedOptions.removeAll()
    }
    
    func submit() {
        defer {
            dismiss()
        }
        
        let id = currentState.masterQuestion?.id ?? UUID()
        let answerIndex = options.firstIndex(of: trueOption ?? "") ?? 0
        let options = !options.isEmpty ? options : ["N/A"]
        
        let newMasterQuestion = MasterQuestion(question: referencedQuestion.question, answerInternal: answerIndex, optionsInternal: options, id: id, image: referencedQuestion.image, solutionImage: referencedQuestion.solutionImage)
        
        withAnimation {
            currentState.masterQuestion = newMasterQuestion
        }
    }
    
    var body: some View {
        Form {
            GeneralQuestionEditView(referencedQuestion: referencedQuestion)
            
            Group {
                List(selection: $selectedOptions) {
                    ForEach(options, id: \.self) { option in
                        Text("\(option)")
                            .foregroundColor(option == trueOption ? .accentColor : .primary)
                            .onTapGesture(count: 2) {
                                if trueOption == option {
                                    trueOption = nil
                                } else {
                                    trueOption = option
                                }
                            }
                            .contextMenu {
                                if trueOption == option {
                                    Button("Remove as True Answer") {
                                        trueOption = nil
                                    }
                                } else {
                                    Button("Set as True Answer") {
                                        trueOption = option
                                    }
                                }
                            }
                    }
                    .onMove { fromOffsets, toOffset in
                        options.move(fromOffsets: fromOffsets, toOffset: toOffset)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(height: 150)
                .padding(.bottom)
                .overlay(alignment: .bottomLeading) {
                    HStack {
                        Button {
                            addOptionSheetPresented = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(.borderless)
                        Button {
                            deleteSelected()
                        } label: {
                            Image(systemName: "minus")
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .onDeleteCommand {
                    deleteSelected()
                }
                
                Spacer(minLength: 20)
            }
            
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
        .onAppear {
            loadFromMasterQuestion()
        }
        .sheet(isPresented: $addOptionSheetPresented) {
            NameSelectionSheet(groundType: "Option") { option in
                guard !options.contains(where: { optionItem in
                    option == optionItem
                }) else { throw QuizError.optionAlreadyExists }
                
                options.append(option)
            }
        }
        .frame(minWidth: 400)
        .fixedSize()
    }
}

#Preview {
    MasterQuestionEditView()
        .environmentObject(CurrentState.examples)
}
