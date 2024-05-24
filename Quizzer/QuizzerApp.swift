import SwiftUI
import OSLog
import UniformTypeIdentifiers

@main
struct QuizzerApp: App {
    @StateObject private var currentState = CurrentState.shared
    @State private var saveDialogShown = false
    @State private var saveDialogIsCSV = false
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
    
    var fileName: String {
        currentState.lastFileName ?? "Quiz.quiz"
    }
    
    private var fittingFileType: UTType {
        if saveDialogIsCSV {
            return .commaSeparatedText
        } else {
            return .quizDocument
        }
    }
    
    private var fittingFileName: String {
        if saveDialogIsCSV {
            return "Questions"
        } else {
            return fileName
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
                .fileExporter(isPresented: $saveDialogShown, document: currentState.storageContainer, contentType: fittingFileType, defaultFilename: fittingFileName) { result in
                    if !saveDialogIsCSV,
                       case .success(let url) = result {
                        currentState.lastFileName = url.lastPathComponent
                    }
                }
                .fileImporter(isPresented: $loadDialogShown, allowedContentTypes: [.quizDocument, .gameDocument]) { result in
                    do {
                        let url = try result.get()
                        if url.startAccessingSecurityScopedResource() {
                            defer {
                                url.stopAccessingSecurityScopedResource()
                            }
                            let data = try Data(contentsOf: url)
                            
                            let key = currentState.lockReloading()
                            
                            if try url.resourceValues(forKeys: [.contentTypeKey]).contentType == .quizDocument {
                                currentState.storageContainer = try StorageContainer(data: data)
                                currentState.lastFileName = url.lastPathComponent
                            } else {
                                let gameStorage = try GameStorage(data: data)
                                currentState.storageContainer = gameStorage.quiz
                                currentState.gameContainer = gameStorage.container
                            }
                            
                            currentState.unlockReloadingAndCatchUp(id: key)
                            
                        } else {
                            throw CocoaError(.fileReadCorruptFile)
                        }
                    } catch {
                        loadError = error
                        loadErrorShown = true
                    }
                }
//                .fileExporter(isPresented: $saveCSVDialogShown, document: CSVHandler(), contentType: .commaSeparatedText, defaultFilename: "Questions") {_ in}
                .alert("Could not be loaded", isPresented: $loadErrorShown) {
                    Button("OK"){}
                } message: {
                    if let loadError {
                        Text("\(loadError.localizedDescription)")
                    }
                }
                .onChange(of: currentState.gameContainer.teams.count) { oldValue, newValue in
                    currentState.saveGame()
                }
                .onChange(of: currentState.gameContainer.questionsAnswered) { oldValue, newValue in
                    currentState.saveGame()
                }
                .onChange(of: currentState.gameContainer.questionsExempt) { oldValue, newValue in
                    currentState.saveGame()
                }
                .onChange(of: currentState.gameContainer.currentQuestion) { oldValue, newValue in
                    currentState.saveGame()
                }
                .onChange(of: currentState.gameContainer.currentImage) { oldValue, newValue in
                    currentState.saveGame()
                }
                .onChange(of: currentState.gameContainer.showMasterQuestion) { oldValue, newValue in
                    currentState.saveGame()
                }
        }
        .windowResizability(.contentSize)
        .keyboardShortcut("c")
        .commands {
            CommandGroup(after: .newItem) {
                Button("Save Quiz") {
                    saveDialogIsCSV = false
                    currentState.storageContainer.saveAsCSV = false
                    saveDialogShown = true
                }
                .keyboardShortcut("S")
                Button("Open") {
                    loadDialogShown = true
                }
                .keyboardShortcut("O")
                Button("Save Quiz as CSV") {
                    saveDialogIsCSV = true
                    currentState.storageContainer.saveAsCSV = true
                    saveDialogShown = true
                }
                Divider()
                if let url = try? currentState.getGameLocation() {
                    Button("Open Game Directory") {
                        let directoryURL = url.deletingLastPathComponent()
                        NSWorkspace.shared.open(directoryURL)
                    }
                }
                Divider()
                Button("Load default Quiz") {
                    _ = CurrentState.examples
                }
                Button("Reset Quiz") {
                    currentState.resetQuiz() 
                }
                Button("Reset Game") {
                    currentState.resetGame()
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
        
        WindowGroup("Image", for: Data.self) { dataBind in
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
        
        Settings {
            Form {
                Section("Strings") {
                    LabeledContent("Intro") {
                        TextEditor(text: $currentState.introTitle)
                    }
                    TextField("Points", text: $currentState.pointsName)
                    TextField("Point", text: $currentState.pointName)
                    TextField("Place / Rank", text: $currentState.placeName)
                    TextField("Answers", text: $currentState.answersName)
                    TextField("Answer", text: $currentState.answerName)
                    TextField("Question", text: $currentState.questionName)
                    TextField("Master Question", text: $currentState.masterQuestionName)
                    TextField("Master Question Prompt", text: $currentState.masterQuestionPrompt)
                }
            }
            .padding()
            .frame(minWidth: 300, idealWidth: 400, minHeight: 325)
        }
    }
}
