import SwiftUI

fileprivate enum ImageType {
    case question
    case solution
}

struct GeneralQuestionEditView: View {
    @EnvironmentObject private var currentState: CurrentState
    @Environment(\.openWindow) private var openWindow
    
    @State private var showFileImportDialog = false
    @State private var imageType = ImageType.question
    
    @Bindable var referencedQuestion: QuestionVars
    
    @ViewBuilder
    var questionImageSelector: some View {
        LabeledContent(referencedQuestion.image?.name ?? "") {
            HStack {
                Button("Select Question Image") {
                    imageType = .question
                    showFileImportDialog = true
                }
                Button {
                    if let questionImage = referencedQuestion.image {
                        let data = questionImage.data
                        openWindow(value: data)
                    }
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.borderless)
                .hide(if: referencedQuestion.image == nil)
            }
        }
    }
    
    @ViewBuilder
    var solutionImageSelector: some View {
        LabeledContent(referencedQuestion.solutionImage?.name ?? "") {
            HStack {
                Button("Select Solution Image") {
                    imageType = .solution
                    showFileImportDialog = true
                }
                Button {
                    if let solutionImage = referencedQuestion.solutionImage {
                        let data = solutionImage.data
                        openWindow(value: data)
                    }
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.borderless)
                .hide(if: referencedQuestion.solutionImage == nil)
            }
        }
        
    }
    
    var body: some View {
        Group {
            Group {
                Text("Question")
                TextEditor(text: $referencedQuestion.question)
                    .frame(minHeight: 50)
                Spacer(minLength: 20)
            }
            
            Group {
                questionImageSelector
                    .padding(.bottom, 5)
                solutionImageSelector
                Spacer(minLength: 20)
            }
        }
        .fileImporter(isPresented: $showFileImportDialog, allowedContentTypes: [.image]) { result in
            switch result {
                case let .success(url):
                    if url.startAccessingSecurityScopedResource() {
                        defer {
                            url.stopAccessingSecurityScopedResource()
                        }
                        
                        if let data = try? Data(contentsOf: url) {
                            let namedData = StoredNamedData(name: url.lastPathComponent, data: data)
                            switch imageType {
                                case .question:
                                    referencedQuestion.image = namedData
                                case .solution:
                                    referencedQuestion.solutionImage = namedData
                            }
                        }
                    }
                case .failure(_):
                    break
            }
        }
    }
}

#Preview {
    let currentState = CurrentState.examples
    return GeneralQuestionEditView(referencedQuestion: QuestionVars(questionObject: currentState.questions[0]))
        .environmentObject(currentState)
}
