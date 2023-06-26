import SwiftUI

@main
struct QuizzerApp: App {
    @StateObject private var currentState = CurrentState.examples
    
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
        .keyboardShortcut("q")
        
        Window("Control", id: "ctrl") {
            BoardControl()
                .environmentObject(currentState)
        }
        .windowResizability(.contentSize)
        .keyboardShortcut("c")
        
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
        .keyboardShortcut("q", modifiers: [.shift, .command])
        
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
        .keyboardShortcut("r")
        
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
