import SwiftUI
import TTGPuzzleVerify

struct ContentView: View {
    @State private var isVerified = false
    @State private var horizontalProgress = 0.0
    @State private var verticalProgress = 0.0
    @State private var resultSummary = "No verification yet"
    private let demoItems = TTGPuzzleDemoItem.all

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

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Puzzle demos")
                            .font(.headline)
                        Text("Try different axes, puzzle shapes, manual verification, and custom styling.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        VStack(spacing: 12) {
                            ForEach(demoItems) { demo in
                                NavigationLink {
                                    PuzzleDemoDetailView(demo: demo)
                                } label: {
                                    PuzzleDemoRow(demo: demo)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
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

    func makeUIView(context: Context) -> SwiftUIDemoPuzzleHostView {
        let view = SwiftUIDemoPuzzleHostView()
        let puzzleView = view.puzzleView
        puzzleView.image = UIImage.ttg_demoGradientImage(size: CGSize(width: 640, height: 400))
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
        puzzleView.applyConfiguration(configuration)
        view.initialBlankPosition = CGPoint(x: 220, y: 96)
        puzzleView.delegate = context.coordinator
        puzzleView.verificationChangeBlock = { _, verified in
            DispatchQueue.main.async {
                isVerified = verified
            }
        }
        puzzleView.completionBlock = { _, result in
            resultSummary = "verified offset=(\(Int(result.xOffset)), \(Int(result.yOffset))) points=\(result.interactionCount)"
        }
        puzzleView.failureBlock = { _, result in
            resultSummary = "failed offset=(\(Int(result.xOffset)), \(Int(result.yOffset))) points=\(result.interactionCount)"
        }
        return view
    }

    func updateUIView(_ uiView: SwiftUIDemoPuzzleHostView, context: Context) {
        guard uiView.didApplyInitialLayout else { return }
        if abs(uiView.puzzleView.puzzleXPercentage - CGFloat(xPercentage)) > 0.001 {
            uiView.puzzleView.puzzleXPercentage = CGFloat(xPercentage)
        }
        if abs(uiView.puzzleView.puzzleYPercentage - CGFloat(yPercentage)) > 0.001 {
            uiView.puzzleView.puzzleYPercentage = CGFloat(yPercentage)
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

final class SwiftUIDemoPuzzleHostView: UIView {
    let puzzleView = TTGPuzzleVerifyView()
    var initialBlankPosition = CGPoint.zero
    private(set) var didApplyInitialLayout = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(puzzleView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        puzzleView.frame = bounds
        guard !didApplyInitialLayout, !bounds.isEmpty else { return }
        didApplyInitialLayout = true
        puzzleView.puzzleBlankPosition = initialBlankPosition
        puzzleView.resetVerification()
    }
}

struct SwiftUIKitDemoControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SwiftPuzzleDemoViewController {
        SwiftPuzzleDemoViewController()
    }

    func updateUIViewController(_ uiViewController: SwiftPuzzleDemoViewController, context: Context) {}
}

private struct PuzzleDemoRow: View {
    let demo: TTGPuzzleDemoItem

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(demo.tint.gradient)
                Image(systemName: demo.symbolName)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(demo.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(demo.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 12)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.quaternary)
        }
    }
}

private struct PuzzleDemoDetailView: View {
    let demo: TTGPuzzleDemoItem
    @State private var isVerified = false
    @State private var xPercentage: Double
    @State private var yPercentage: Double
    @State private var resultSummary: String
    @State private var resetToken = 0
    @State private var manualVerifyToken = 0
    @State private var sliderChangeToken = 0
    @State private var sliderEndToken = 0

    init(demo: TTGPuzzleDemoItem) {
        self.demo = demo
        _xPercentage = State(initialValue: 0)
        _yPercentage = State(initialValue: 0)
        _resultSummary = State(initialValue: demo.initialSummary)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(isVerified ? demo.verifiedTitle : demo.title)
                        .font(.headline)
                    Text(demo.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                PuzzleDemoRepresentable(demo: demo,
                                        isVerified: $isVerified,
                                        resultSummary: $resultSummary,
                                        xPercentage: $xPercentage,
                                        yPercentage: $yPercentage,
                                        resetToken: resetToken,
                                        manualVerifyToken: manualVerifyToken,
                                        sliderChangeToken: sliderChangeToken,
                                        sliderEndToken: sliderEndToken)
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(radius: 12)

                Text(resultSummary)
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)

                VStack(spacing: 16) {
                    if demo.showsHorizontalSlider {
                        Slider(value: Binding(get: {
                            xPercentage
                        }, set: { newValue in
                            xPercentage = newValue
                            sliderChangeToken += 1
                        }), in: 0...1, onEditingChanged: { editing in
                            if !editing { sliderEndToken += 1 }
                        }) {
                            Text("Horizontal")
                        }
                    }

                    if demo.showsVerticalSlider {
                        Slider(value: Binding(get: {
                            yPercentage
                        }, set: { newValue in
                            yPercentage = newValue
                            sliderChangeToken += 1
                        }), in: 0...1, onEditingChanged: { editing in
                            if !editing { sliderEndToken += 1 }
                        }) {
                            Text("Vertical")
                        }
                    }
                }

                HStack(spacing: 12) {
                    if demo.requiresManualVerification {
                        Button("Verify") {
                            manualVerifyToken += 1
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Button("Reset") {
                        isVerified = false
                        resultSummary = demo.initialSummary
                        resetToken += 1
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(24)
        }
        .navigationTitle(demo.shortTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PuzzleDemoRepresentable: UIViewRepresentable {
    let demo: TTGPuzzleDemoItem
    @Binding var isVerified: Bool
    @Binding var resultSummary: String
    @Binding var xPercentage: Double
    @Binding var yPercentage: Double
    let resetToken: Int
    let manualVerifyToken: Int
    let sliderChangeToken: Int
    let sliderEndToken: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> PuzzleDemoHostView {
        let hostView = PuzzleDemoHostView(demo: demo)
        hostView.configure(coordinator: context.coordinator,
                           onVerificationChange: { verified in
                               isVerified = verified
                               if demo.requiresManualVerification {
                                   resultSummary = verified ? demo.readyToVerifySummary : demo.initialSummary
                               }
                           },
                           onCompletion: { result in
                               resultSummary = demo.completionSummary(for: result)
                           },
                           onFailure: { result in
                               resultSummary = demo.failureSummary(for: result)
                           },
                           onPositionSync: { xPercentage, yPercentage in
                               self.xPercentage = xPercentage
                               self.yPercentage = yPercentage
                           })
        return hostView
    }

    func updateUIView(_ uiView: PuzzleDemoHostView, context: Context) {
        if context.coordinator.resetToken != resetToken {
            context.coordinator.resetToken = resetToken
            uiView.resetToStart()
            return
        }

        if context.coordinator.sliderChangeToken != sliderChangeToken {
            context.coordinator.sliderChangeToken = sliderChangeToken
            if demo.showsHorizontalSlider, abs(uiView.puzzleView.puzzleXPercentage - CGFloat(xPercentage)) > 0.001 {
                uiView.puzzleView.puzzleXPercentage = CGFloat(xPercentage)
            }
            if demo.showsVerticalSlider, abs(uiView.puzzleView.puzzleYPercentage - CGFloat(yPercentage)) > 0.001 {
                uiView.puzzleView.puzzleYPercentage = CGFloat(yPercentage)
            }
        }

        if context.coordinator.sliderEndToken != sliderEndToken {
            context.coordinator.sliderEndToken = sliderEndToken
            uiView.finishSliderInteraction()
        }

        if context.coordinator.manualVerifyToken != manualVerifyToken {
            context.coordinator.manualVerifyToken = manualVerifyToken
            if uiView.puzzleView.isVerified {
                uiView.puzzleView.completeVerification(withAnimation: true)
            } else {
                uiView.puzzleView.markVerificationFailed()
            }
        }
    }

    final class Coordinator: NSObject, TTGPuzzleVerifyViewDelegate {
        private let parent: PuzzleDemoRepresentable
        var resetToken: Int
        var manualVerifyToken: Int
        var sliderChangeToken: Int
        var sliderEndToken: Int

        init(_ parent: PuzzleDemoRepresentable) {
            self.parent = parent
            self.resetToken = parent.resetToken
            self.manualVerifyToken = parent.manualVerifyToken
            self.sliderChangeToken = parent.sliderChangeToken
            self.sliderEndToken = parent.sliderEndToken
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
            parent.isVerified = true
            parent.resultSummary = parent.demo.completionSummary(for: result)
        }

        func puzzleVerifyView(_ puzzleVerifyView: TTGPuzzleVerifyView, didFailWith result: TTGPuzzleVerifyResult) {
            parent.isVerified = false
            parent.resultSummary = parent.demo.failureSummary(for: result)
        }
    }
}

private final class PuzzleDemoHostView: UIView {
    let puzzleView = TTGPuzzleVerifyView()

    private let demo: TTGPuzzleDemoItem
    private var didApplyInitialReset = false
    private var onPositionSync: ((Double, Double) -> Void)?

    init(demo: TTGPuzzleDemoItem) {
        self.demo = demo
        super.init(frame: .zero)
        addSubview(puzzleView)
        configurePuzzleView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(coordinator: TTGPuzzleVerifyViewDelegate,
                   onVerificationChange: @escaping (Bool) -> Void,
                   onCompletion: @escaping (TTGPuzzleVerifyResult) -> Void,
                   onFailure: @escaping (TTGPuzzleVerifyResult) -> Void,
                   onPositionSync: @escaping (Double, Double) -> Void) {
        self.onPositionSync = onPositionSync
        puzzleView.delegate = coordinator
        puzzleView.verificationChangeBlock = { _, verified in
            onVerificationChange(verified)
        }
        puzzleView.completionBlock = { _, result in
            onCompletion(result)
        }
        puzzleView.failureBlock = { [weak self] _, result in
            onFailure(result)
            self?.restoreStartAfterFailure()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        puzzleView.frame = bounds
        guard !didApplyInitialReset, !bounds.isEmpty else { return }
        didApplyInitialReset = true
        resetToStart()
    }

    func resetToStart() {
        puzzleView.enable = true
        puzzleView.unlock()
        puzzleView.clearTrack()
        puzzleView.puzzleBlankPosition = demo.blankPosition
        puzzleView.resetVerification()
        syncPosition()
    }

    func finishSliderInteraction() {
        guard !demo.requiresManualVerification,
              puzzleView.state != .verified,
              !puzzleView.isVerified else { return }
        puzzleView.markVerificationFailed()
    }

    private func configurePuzzleView() {
        if let imageName = demo.imageName, let image = UIImage(named: imageName) {
            puzzleView.image = image
        } else {
            puzzleView.image = UIImage.ttg_demoGradientImage(size: CGSize(width: 640, height: 400),
                                                             variant: demo.imageVariant)
        }
        puzzleView.applyConfiguration(demo.configuration)
        puzzleView.customPuzzlePatternPath = demo.customPuzzlePatternPath
        puzzleView.failureAnimation = .shake
    }

    private func restoreStartAfterFailure() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) { [weak self] in
            guard let self, self.puzzleView.state == .failed else { return }
            self.resetToStart()
        }
    }

    private func syncPosition() {
        onPositionSync?(Double(puzzleView.puzzleXPercentage),
                        Double(puzzleView.puzzleYPercentage))
    }
}

struct TTGPuzzleDemoItem: Identifiable {
    enum ImageVariant {
        case ocean
        case sunset
        case mint
    }

    enum StyleKind {
        case standard
        case lowBlankAlpha
        case customShadow

        func makeStyle() -> TTGPuzzleVerifyStyle {
            let style = TTGPuzzleVerifyStyle()
            style.blankAlpha = 0.45
            style.cornerRadius = 18
            style.puzzleShadow.opacity = 0.42

            switch self {
            case .standard:
                break
            case .lowBlankAlpha:
                style.blankAlpha = 0.1
            case .customShadow:
                style.blankInnerShadow.color = .systemYellow
                style.blankInnerShadow.radius = 6
                style.blankInnerShadow.opacity = 0.8
                style.blankInnerShadow.offset = CGSize(width: 2, height: 2)
                style.puzzleShadow.color = .systemGreen
                style.puzzleShadow.radius = 6
                style.puzzleShadow.opacity = 0.6
                style.puzzleShadow.offset = CGSize(width: 2, height: 2)
            }

            return style
        }
    }

    let id: String
    let title: String
    let shortTitle: String
    let subtitle: String
    let symbolName: String
    let tint: Color
    let pattern: TTGPuzzleVerifyPattern
    let axes: TTGPuzzleVerifyAllowedAxes
    let blankPosition: CGPoint
    let requiresManualVerification: Bool
    let maxRetryCount: Int
    let styleKind: StyleKind
    let imageVariant: ImageVariant
    let usesImageBackground: Bool
    let customPuzzlePatternPath: UIBezierPath?

    var showsHorizontalSlider: Bool {
        axes == .horizontal || axes == .both || requiresManualVerification
    }

    var showsVerticalSlider: Bool {
        axes == .vertical || axes == .both
    }

    var initialSummary: String {
        requiresManualVerification ? "Adjust the slider, then tap Verify." : "Drag the puzzle or use the slider to verify."
    }

    var readyToVerifySummary: String {
        "Position matched. Tap Verify to complete."
    }

    var verifiedTitle: String {
        requiresManualVerification ? "Ready to verify" : "Verified"
    }

    var imageName: String? {
        usesImageBackground ? "pic3" : nil
    }

    var configuration: TTGPuzzleVerifyConfiguration {
        let configuration = TTGPuzzleVerifyConfiguration()
        configuration.puzzlePattern = pattern
        configuration.puzzleSize = CGSize(width: 86, height: 86)
        configuration.verificationTolerance = 6
        configuration.allowedAxes = axes
        configuration.autoSnapWhenWithinTolerance = !requiresManualVerification
        configuration.recordsTrack = true
        configuration.maxRetryCount = maxRetryCount
        configuration.style = styleKind.makeStyle()
        return configuration
    }

    func completionSummary(for result: TTGPuzzleVerifyResult) -> String {
        "verified in \(String(format: "%.2f", result.elapsedTime))s, distance \(Int(result.dragDistance)), points \(result.interactionCount)"
    }

    func failureSummary(for result: TTGPuzzleVerifyResult) -> String {
        "failed offset=(\(Int(result.xOffset)), \(Int(result.yOffset))) points=\(result.interactionCount)"
    }

    static let all: [TTGPuzzleDemoItem] = [
        TTGPuzzleDemoItem(id: "horizontal",
                        title: "Slide horizontally to verify",
                        shortTitle: "Horizontal",
                        subtitle: "Horizontal-only movement that returns to the starting point after a miss.",
                        symbolName: "arrow.left.and.right",
                        tint: .blue,
                        pattern: .classicPattern,
                        axes: .horizontal,
                        blankPosition: CGPoint(x: 200, y: 20),
                        requiresManualVerification: false,
                        maxRetryCount: 0,
                        styleKind: .standard,
                        imageVariant: .ocean,
                        usesImageBackground: false,
                        customPuzzlePatternPath: nil),
        TTGPuzzleDemoItem(id: "vertical",
                        title: "Slide vertically to verify",
                        shortTitle: "Vertical",
                        subtitle: "Vertical-only movement with the same slider-driven control.",
                        symbolName: "arrow.up.and.down",
                        tint: .teal,
                        pattern: .classicPattern,
                        axes: .vertical,
                        blankPosition: CGPoint(x: 20, y: 100),
                        requiresManualVerification: false,
                        maxRetryCount: 0,
                        styleKind: .standard,
                        imageVariant: .mint,
                        usesImageBackground: false,
                        customPuzzlePatternPath: nil),
        TTGPuzzleDemoItem(id: "drag",
                        title: "Drag to verify",
                        shortTitle: "Drag",
                        subtitle: "Free two-axis dragging with retry tracking enabled.",
                        symbolName: "hand.draw",
                        tint: .indigo,
                        pattern: .classicPattern,
                        axes: .both,
                        blankPosition: CGPoint(x: 200, y: 40),
                        requiresManualVerification: false,
                        maxRetryCount: 3,
                        styleKind: .standard,
                        imageVariant: .ocean,
                        usesImageBackground: false,
                        customPuzzlePatternPath: nil),
        TTGPuzzleDemoItem(id: "manual",
                        title: "Slide and verify manually",
                        shortTitle: "Manual",
                        subtitle: "Move the piece first, then explicitly run verification.",
                        symbolName: "checkmark.seal",
                        tint: .orange,
                        pattern: .classicPattern,
                        axes: .horizontal,
                        blankPosition: CGPoint(x: 200, y: 20),
                        requiresManualVerification: true,
                        maxRetryCount: 0,
                        styleKind: .standard,
                        imageVariant: .sunset,
                        usesImageBackground: false,
                        customPuzzlePatternPath: nil),
        TTGPuzzleDemoItem(id: "image-background",
                        title: "Image background",
                        shortTitle: "Image",
                        subtitle: "Use a bundled photo as the puzzle background.",
                        symbolName: "photo",
                        tint: .brown,
                        pattern: .classicPattern,
                        axes: .horizontal,
                        blankPosition: CGPoint(x: 200, y: 20),
                        requiresManualVerification: false,
                        maxRetryCount: 0,
                        styleKind: .standard,
                        imageVariant: .ocean,
                        usesImageBackground: true,
                        customPuzzlePatternPath: nil),
        TTGPuzzleDemoItem(id: "square",
                        title: "Square pattern",
                        shortTitle: "Square",
                        subtitle: "A square cutout with the same smooth slider control.",
                        symbolName: "square.dashed",
                        tint: .purple,
                        pattern: .squarePattern,
                        axes: .horizontal,
                        blankPosition: CGPoint(x: 200, y: 20),
                        requiresManualVerification: false,
                        maxRetryCount: 0,
                        styleKind: .standard,
                        imageVariant: .ocean,
                        usesImageBackground: false,
                        customPuzzlePatternPath: nil),
        TTGPuzzleDemoItem(id: "circle",
                        title: "Circle pattern",
                        shortTitle: "Circle",
                        subtitle: "A circular puzzle piece with automatic verification.",
                        symbolName: "circle.dashed",
                        tint: .pink,
                        pattern: .circlePattern,
                        axes: .horizontal,
                        blankPosition: CGPoint(x: 200, y: 20),
                        requiresManualVerification: false,
                        maxRetryCount: 0,
                        styleKind: .standard,
                        imageVariant: .sunset,
                        usesImageBackground: false,
                        customPuzzlePatternPath: nil),
        TTGPuzzleDemoItem(id: "custom-pattern",
                        title: "Custom pattern",
                        shortTitle: "Custom",
                        subtitle: "Rounded custom UIBezierPath pattern with lighter blank opacity.",
                        symbolName: "app.dashed",
                        tint: .cyan,
                        pattern: .customPattern,
                        axes: .horizontal,
                        blankPosition: CGPoint(x: 120, y: 20),
                        requiresManualVerification: false,
                        maxRetryCount: 0,
                        styleKind: .lowBlankAlpha,
                        imageVariant: .mint,
                        usesImageBackground: false,
                        customPuzzlePatternPath: UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 80, height: 80),
                                                              cornerRadius: 20)),
        TTGPuzzleDemoItem(id: "custom-shadow",
                        title: "Custom shadow",
                        shortTitle: "Shadow",
                        subtitle: "Custom blank inner shadow and puzzle-piece shadow styling.",
                        symbolName: "sparkles",
                        tint: .green,
                        pattern: .classicPattern,
                        axes: .horizontal,
                        blankPosition: CGPoint(x: 200, y: 20),
                        requiresManualVerification: false,
                        maxRetryCount: 0,
                        styleKind: .customShadow,
                        imageVariant: .ocean,
                        usesImageBackground: false,
                        customPuzzlePatternPath: nil)
    ]
}

extension UIImage {
    static func ttg_demoGradientImage(size: CGSize,
                                      variant: TTGPuzzleDemoItem.ImageVariant = .ocean) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let colors: [CGColor]
            switch variant {
            case .ocean:
                colors = [UIColor.systemIndigo.cgColor, UIColor.systemTeal.cgColor, UIColor.systemOrange.cgColor]
            case .sunset:
                colors = [UIColor.systemPink.cgColor, UIColor.systemOrange.cgColor, UIColor.systemYellow.cgColor]
            case .mint:
                colors = [UIColor.systemBlue.cgColor, UIColor.systemMint.cgColor, UIColor.systemGreen.cgColor]
            }
            let locations: [CGFloat] = [0, 0.55, 1]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locations)!
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
