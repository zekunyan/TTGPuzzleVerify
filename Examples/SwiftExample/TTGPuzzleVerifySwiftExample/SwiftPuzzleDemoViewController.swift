import UIKit
import TTGPuzzleVerify

final class SwiftPuzzleDemoViewController: UIViewController, TTGPuzzleVerifyViewDelegate {
    private let puzzleView = TTGPuzzleVerifyView()
    private let statusLabel = UILabel()
    private let horizontalSlider = UISlider()
    private var didApplyInitialReset = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Swift UIKit"
        configurePuzzleView()
        configureControls()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !didApplyInitialReset, !puzzleView.bounds.isEmpty else { return }
        didApplyInitialReset = true
        resetPuzzleToStart()
    }

    private func configurePuzzleView() {
        puzzleView.translatesAutoresizingMaskIntoConstraints = false
        puzzleView.image = UIImage.ttg_demoGradientImage(size: CGSize(width: 640, height: 400))
        let configuration = TTGPuzzleVerifyConfiguration()
        configuration.puzzlePattern = .circlePattern
        configuration.puzzleSize = CGSize(width: 92, height: 92)
        configuration.verificationTolerance = 7
        configuration.allowedAxes = .horizontal
        puzzleView.applyConfiguration(configuration)
        puzzleView.failureAnimation = .shakeAndReset
        puzzleView.delegate = self
        puzzleView.layer.cornerRadius = 18
        puzzleView.layer.masksToBounds = true
        view.addSubview(puzzleView)
    }

    private func configureControls() {
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.text = "Not verified · horizontal mode"
        statusLabel.font = .preferredFont(forTextStyle: .headline)

        horizontalSlider.translatesAutoresizingMaskIntoConstraints = false
        horizontalSlider.minimumValue = 0
        horizontalSlider.maximumValue = 1
        horizontalSlider.value = Float(puzzleView.puzzleXPercentage)
        horizontalSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

        let completeButton = UIButton(type: .system)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.configuration = .borderedProminent()
        completeButton.setTitle("Complete", for: .normal)
        completeButton.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)

        let resetButton = UIButton(type: .system)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.configuration = .bordered()
        resetButton.setTitle("Reset", for: .normal)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [statusLabel, horizontalSlider, completeButton, resetButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            puzzleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            puzzleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            puzzleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            puzzleView.heightAnchor.constraint(equalToConstant: 240),

            stack.topAnchor.constraint(equalTo: puzzleView.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: puzzleView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: puzzleView.trailingAnchor)
        ])
    }

    @objc private func sliderChanged() {
        puzzleView.puzzleXPercentage = CGFloat(horizontalSlider.value)
    }

    @objc private func completeTapped() {
        puzzleView.completeVerification(withAnimation: true)
    }

    @objc private func resetTapped() {
        resetPuzzleToStart()
        statusLabel.text = "Not verified · horizontal mode"
    }

    private func resetPuzzleToStart() {
        puzzleView.puzzleBlankPosition = CGPoint(x: 210, y: 20)
        puzzleView.resetVerification()
        horizontalSlider.value = Float(puzzleView.puzzleXPercentage)
    }

    func puzzleVerifyView(_ puzzleVerifyView: TTGPuzzleVerifyView, didChangedVerification isVerified: Bool) {
        statusLabel.text = isVerified ? "Verified" : "Not verified · horizontal mode"
    }

    func puzzleVerifyView(_ puzzleVerifyView: TTGPuzzleVerifyView,
                          didChangedPuzzlePosition newPosition: CGPoint,
                          xPercentage: CGFloat,
                          yPercentage: CGFloat) {
        horizontalSlider.value = Float(xPercentage)
    }

    func puzzleVerifyView(_ puzzleVerifyView: TTGPuzzleVerifyView, didCompleteWith result: TTGPuzzleVerifyResult) {
        statusLabel.text = "Verified · points: \(result.interactionCount)"
    }

    func puzzleVerifyView(_ puzzleVerifyView: TTGPuzzleVerifyView, didFailWith result: TTGPuzzleVerifyResult) {
        statusLabel.text = "Failed · offset: \(Int(result.xOffset))"
    }
}
