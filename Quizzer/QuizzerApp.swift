import SwiftUI
import OSLog

@main
struct QuizzerApp: App {
    @StateObject private var currentState = CurrentState.shared
    @State private var saveDialogShown = false
    @State private var loadDialogShown = false
    @State private var loadErrorShown = false
    @State private var loadError = nil as Error?
    
    func calculateSize(image: NSImage) -> NSSize {
        let maxWidth = 1300 as Double
        let maxHeight = 800 as Double
        let originalSize = image.size
        let toLargeWidth = originalSize.width / maxWidth
        let toLargeHeight = originalSize.height / maxHeight
        if originalSize.width <= maxWidth && originalSize.height <= maxHeight {
            return originalSize
        } else {
            let scale = max(toLargeWidth, toLargeHeight)
            return NSSize(width: originalSize.width / scale, height: originalSize.height / scale)
        }
        
        
    }
    
    var body: some Scene {
        Window("Quiz", id: "quiz") {
            QuizBoard()
                .environmentObject(currentState)
                .foregroundColor(.black)
        }
        
        Window("Control", id: "ctrl") {
            BoardControl()
                .environmentObject(currentState)
                .fileExporter(isPresented: $saveDialogShown, document: currentState.storageContainer, contentType: .quizDocument, defaultFilename: "Quiz.quiz") { _ in }
                .fileImporter(isPresented: $loadDialogShown, allowedContentTypes: [.quizDocument]) { result in
                    do {
                        let url = try result.get()
                        if url.startAccessingSecurityScopedResource() {
                            defer {
                                url.stopAccessingSecurityScopedResource()
                            }
                            let data = try Data(contentsOf: url)
                            currentState.storageContainer = try StorageContainer(data: data)
                        } else {
                            throw CocoaError(.fileReadCorruptFile)
                        }
                    } catch {
                        loadError = error
                        loadErrorShown = true
                    }
                }
                .alert("Could not be loaded", isPresented: $loadErrorShown) {
                    Button("OK"){}
                } message: {
                    if let loadError {
                        Text("\(loadError.localizedDescription)")
                    }
                }

        }
        .windowResizability(.contentSize)
        .keyboardShortcut("c")
        .commands {
            CommandGroup(after: .newItem) {
                Button("Save Quiz") {
                    saveDialogShown = true
                }
                .keyboardShortcut("S")
                Button("Open Quiz") {
                    loadDialogShown = true
                }
                .keyboardShortcut("O")
                Button("Load default Quiz") {
                    _ = CurrentState.examples
                }
            }
        }
        
        Window("Question Presentation", id: "qst") {
            if currentState.showMasterQuestion {
                MasterQuestionControl(question: $currentState.masterQuestion)
                    .environmentObject(currentState)
            } else {
                let questionBinding = Binding<Question?>(get: {
                    currentState.currentQuestionResolved
                }, set: { newValue in
                    if let newQuestion = newValue {
                        currentState.currentQuestion = currentState.getIndexOfQuestion(newQuestion)
                    } else {
                        currentState.currentQuestion = nil
                    }
                })
                QuestionControl(question: questionBinding, isQL: false)
                    .environmentObject(currentState)
            }
        }
        .windowResizability(.contentSize)
        
        WindowGroup("Question - QuickLook", for: Question.self) { q in
            QuestionControl(question: q, isQL: true)
                .environmentObject(currentState)
        }
        .windowResizability(.contentSize)
        
        Window("Result Control", id: "rslt") {
            EndControl()
                .environmentObject(currentState)
        }
        .windowResizability(.contentSize)
        
        WindowGroup(for: Data.self) { dataBind in
            if let data = dataBind.wrappedValue,
               let image = NSImage(data: data) {
                let size = calculateSize(image: image)
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width, height: size.height)
                    .fixedSize()
            }
        }
        .windowResizability(.contentSize)
    }
}
