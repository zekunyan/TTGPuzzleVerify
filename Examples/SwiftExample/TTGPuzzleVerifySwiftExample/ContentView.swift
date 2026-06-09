import SwiftUI
import TTGPuzzleVerify

struct ContentView: View {
    @State private var isVerified = false
    @State private var horizontalProgress = 0.1
    @State private var verticalProgress = 0.2
    @State private var resultSummary = "No verification yet"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(isVerified ? "Verified" : "Slide the puzzle into the blank")
                            .font(.headline)
                        Text("SwiftUI wraps TTGPuzzleVerifyView with configuration, state, result, and track callbacks.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    PuzzleVerifyRepresentable(isVerified: $isVerified,
                                              resultSummary: $resultSummary,
                                              xPercentage: $horizontalProgress,
                                              yPercentage: $verticalProgress)
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(radius: 12)

                    Text(resultSummary)
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(.secondary)

                    VStack(spacing: 16) {
                        Slider(value: $horizontalProgress, in: 0...1) {
                            Text("Horizontal")
                        }
                        Slider(value: $verticalProgress, in: 0...1) {
                            Text("Vertical")
                        }
                    }

                    NavigationLink("Open Swift UIKit demo") {
                        SwiftUIKitDemoControllerRepresentable()
                            .ignoresSafeArea()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(24)
            }
            .navigationTitle("Swift Example")
        }
    }
}

struct PuzzleVerifyRepresentable: UIViewRepresentable {
    @Binding var isVerified: Bool
    @Binding var resultSummary: String
    @Binding var xPercentage: Double
    @Binding var yPercentage: Double

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> TTGPuzzleVerifyView {
        let view = TTGPuzzleVerifyView()
        view.image = UIImage.ttg_demoGradientImage(size: CGSize(width: 640, height: 400))
        let style = TTGPuzzleVerifyStyle()
        style.blankAlpha = 0.45
        style.cornerRadius = 18

        let configuration = TTGPuzzleVerifyConfiguration()
        configuration.puzzlePattern = .classicPattern
        configuration.puzzleSize = CGSize(width: 86, height: 86)
        configuration.verificationTolerance = 6
        configuration.allowedAxes = .both
        configuration.autoSnapWhenWithinTolerance = true
        configuration.recordsTrack = true
        configuration.style = style
        view.applyConfiguration(configuration)
        view.puzzleBlankPosition = CGPoint(x: 220, y: 96)
        view.puzzlePosition = CGPoint(x: 24, y: 118)
        view.delegate = context.coordinator
        view.verificationChangeBlock = { _, verified in
            DispatchQueue.main.async {
                isVerified = verified
            }
        }
        view.completionBlock = { _, result in
            resultSummary = "verified offset=(\(Int(result.xOffset)), \(Int(result.yOffset))) points=\(result.interactionCount)"
        }
        view.failureBlock = { _, result in
            resultSummary = "failed offset=(\(Int(result.xOffset)), \(Int(result.yOffset))) points=\(result.interactionCount)"
        }
        return view
    }

    func updateUIView(_ uiView: TTGPuzzleVerifyView, context: Context) {
        if abs(uiView.puzzleXPercentage - CGFloat(xPercentage)) > 0.001 {
            uiView.puzzleXPercentage = CGFloat(xPercentage)
        }
        if abs(uiView.puzzleYPercentage - CGFloat(yPercentage)) > 0.001 {
            uiView.puzzleYPercentage = CGFloat(yPercentage)
        }
    }

    final class Coordinator: NSObject, TTGPuzzleVerifyViewDelegate {
        private let parent: PuzzleVerifyRepresentable

        init(_ parent: PuzzleVerifyRepresentable) {
            self.parent = parent
        }

        func puzzleVerifyView(_ puzzleVerifyView: TTGPuzzleVerifyView, didChangedVerification isVerified: Bool) {
            parent.isVerified = isVerified
        }

        func puzzleVerifyView(_ puzzleVerifyView: TTGPuzzleVerifyView,
                              didChangedPuzzlePosition newPosition: CGPoint,
                              xPercentage: CGFloat,
                              yPercentage: CGFloat) {
            parent.xPercentage = Double(xPercentage)
            parent.yPercentage = Double(yPercentage)
        }

        func puzzleVerifyView(_ puzzleVerifyView: TTGPuzzleVerifyView, didCompleteWith result: TTGPuzzleVerifyResult) {
            parent.resultSummary = "verified in \(String(format: "%.2f", result.elapsedTime))s, distance \(Int(result.dragDistance))"
        }

        func puzzleVerifyView(_ puzzleVerifyView: TTGPuzzleVerifyView, didFailWith result: TTGPuzzleVerifyResult) {
            parent.resultSummary = "failed, retry with offset \(Int(result.xOffset)), \(Int(result.yOffset))"
        }
    }
}

struct SwiftUIKitDemoControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SwiftPuzzleDemoViewController {
        SwiftPuzzleDemoViewController()
    }

    func updateUIViewController(_ uiViewController: SwiftPuzzleDemoViewController, context: Context) {}
}

extension UIImage {
    static func ttg_demoGradientImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let colors = [UIColor.systemIndigo.cgColor, UIColor.systemTeal.cgColor, UIColor.systemOrange.cgColor] as CFArray
            let locations: [CGFloat] = [0, 0.55, 1]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: locations)!
            context.cgContext.drawLinearGradient(gradient,
                                                 start: CGPoint(x: 0, y: 0),
                                                 end: CGPoint(x: size.width, y: size.height),
                                                 options: [])

            let title = "TTGPuzzleVerify"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 48),
                .foregroundColor: UIColor.white.withAlphaComponent(0.9)
            ]
            title.draw(at: CGPoint(x: 36, y: size.height - 96), withAttributes: attributes)
        }
    }
}
