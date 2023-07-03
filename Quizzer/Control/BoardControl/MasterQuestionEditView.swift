import SwiftUI

struct MasterQuestionEditView: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedOptions = Set<String>()
    @State private var addOptionSheetPresented = false
    @State private var editOptionSheetPresented = false
    @State private var editOption = 0
    @State private var editOptionText = ""
    
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
        currentState.pauseReloading = true
        withAnimation {
            referencedQuestion.saveToMasterQuestion()
        }
        dismiss()
        currentState.storageContainer.cleanImages()
        currentState.pauseReloading = false
    }
    
    var options: [(index: Int, option: String)] {
        referencedQuestion.options.enumerated().map { element in
            (index: element.offset, option: element.element)
        }
    }
    
    var body: some View {
        Form {
            GeneralQuestionEditView(referencedQuestion: referencedQuestion)
            
            Group {
                List(selection: $selectedOptions) {
                    ForEach(options, id: \.index) { (index, option) in
                        HStack {
                            Text("\(option)")
                                .foregroundColor(index == referencedQuestion.answerIndex ? .accentColor : .primary)
                                .contextMenu {
                                    Button("Set as True Answer") {
                                        referencedQuestion.answerIndex = index
                                    }
                                    Button("Edit") {
                                        editOption = index
                                        editOptionText = option
                                        editOptionSheetPresented = true
                                    }
                                    Button("Remove Option") {
                                        referencedQuestion.options.remove(at: index)
                                    }
                                }
                            Spacer()
                            Button {
                                referencedQuestion.answerIndex = index
                            } label: {
                                Image(systemName: "checkmark.circle")
                            }
                            .buttonStyle(.borderless)
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
            NameSelectionSheet(groundType: "Option", multiline: true) { option in
                guard !referencedQuestion.options.contains(where: { optionItem in
                    option == optionItem
                }) else { throw QuizError.optionAlreadyExists }
                
                referencedQuestion.options.append(option)
            }
        }
        .sheet(isPresented: $editOptionSheetPresented) {
            NameSelectionSheet(groundType: "Option", typeOfInteraction: "Change", multiline: true, startText: $editOptionText) { option in
                referencedQuestion.options[editOption] = option
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
