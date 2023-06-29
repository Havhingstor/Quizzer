import SwiftUI

struct MasterQuestionEditView: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedOptions = Set<String>()
    @State private var trueOption = nil as String?
    @State private var addOptionSheetPresented = false
    
    @Bindable private var referencedQuestion: QuestionVars
    
    init() {
        referencedQuestion = QuestionVars.initFromMasterQuestion()
    }
    
    func deleteSelected() {
        for option in selectedOptions {
            referencedQuestion.options.removeAll { optionItem in
                optionItem == option
            }
        }
        
        selectedOptions.removeAll()
    }
    
    func submit() {
        withAnimation {
            referencedQuestion.saveToMasterQuestion()
        }
        dismiss()
        currentState.storageContainer.cleanImages()
    }
    
    var body: some View {
        Form {
            GeneralQuestionEditView(referencedQuestion: referencedQuestion)
            
            Group {
                List(selection: $selectedOptions) {
                    ForEach(referencedQuestion.options, id: \.self) { option in
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
                        referencedQuestion.options.move(fromOffsets: fromOffsets, toOffset: toOffset)
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
        .sheet(isPresented: $addOptionSheetPresented) {
            NameSelectionSheet(groundType: "Option") { option in
                guard !referencedQuestion.options.contains(where: { optionItem in
                    option == optionItem
                }) else { throw QuizError.optionAlreadyExists }
                
                referencedQuestion.options.append(option)
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
