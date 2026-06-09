//
//  TTGPuzzleVerifyView.swift
//  TTGPuzzleVerify
//
//  Created by tutuge on 2016/12/10.
//  Migrated to Swift in 2026.
//

import UIKit

@objc(TTGPuzzleVerifyPattern)
public enum TTGPuzzleVerifyPattern: Int {
    case classicPattern = 0
    case squarePattern
    case circlePattern
    case customPattern
}

@objc(TTGPuzzleVerifyViewDelegate)
public protocol TTGPuzzleVerifyViewDelegate: AnyObject {
    @objc optional func puzzleVerifyView(_ puzzleVerifyView: TTGPuzzleVerifyView, didChangedVerification isVerified: Bool)
    @objc optional func puzzleVerifyView(_ puzzleVerifyView: TTGPuzzleVerifyView,
                                         didChangedPuzzlePosition newPosition: CGPoint,
                                         xPercentage: CGFloat,
                                         yPercentage: CGFloat)
}

@objcMembers
@objc(TTGPuzzleVerifyView)
public final class TTGPuzzleVerifyView: UIView {
    private enum Defaults {
        static let puzzleSize = CGSize(width: 100, height: 100)
        static let puzzlePosition = CGPoint(x: 20, y: 20)
        static let animationDuration: TimeInterval = 0.3
        static let verificationTolerance: CGFloat = 8
        static let puzzleBlankAlpha: CGFloat = 0.5
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Float = 0.5
        static let shadowInset: CGFloat = -20
    }

    public var image: UIImage? {
        didSet {
            backImageView.image = image
            frontImageView.image = image
            puzzleImageView.image = image
            updatePuzzleMask()
        }
    }

    public var puzzlePattern: TTGPuzzleVerifyPattern = .classicPattern {
        didSet { updatePuzzleMask() }
    }

    public var customPuzzlePatternPath: UIBezierPath? {
        didSet { updatePuzzleMask() }
    }

    public var puzzleSize: CGSize {
        get { rawPuzzleSize }
        set {
            rawPuzzleSize = sanitizedPuzzleSize(newValue)
            setPuzzlePosition(puzzlePosition, notify: false)
            updatePuzzleMask()
        }
    }

    public var puzzleBlankPosition: CGPoint {
        get { rawPuzzleBlankPosition }
        set {
            rawPuzzleBlankPosition = clampedPuzzlePosition(newValue)
            setPuzzlePosition(puzzlePosition, notify: false)
            updatePuzzleMask()
        }
    }

    public var puzzlePosition: CGPoint {
        get {
            CGPoint(x: puzzleContainerPosition.x + rawPuzzleBlankPosition.x,
                    y: puzzleContainerPosition.y + rawPuzzleBlankPosition.y)
        }
        set { setPuzzlePosition(newValue, notify: false) }
    }

    public var puzzleXPercentage: CGFloat {
        get {
            let range = puzzleMaxX - puzzleMinX
            guard range > 0 else { return 0 }
            return (puzzlePosition.x - puzzleMinX) / range
        }
        set {
            guard enable else { return }
            let percentage = clampedPercentage(newValue)
            var position = puzzlePosition
            position.x = percentage * (puzzleMaxX - puzzleMinX) + puzzleMinX
            setPuzzlePosition(position, notify: true)
        }
    }

    public var puzzleYPercentage: CGFloat {
        get {
            let range = puzzleMaxY - puzzleMinY
            guard range > 0 else { return 0 }
            return (puzzlePosition.y - puzzleMinY) / range
        }
        set {
            guard enable else { return }
            let percentage = clampedPercentage(newValue)
            var position = puzzlePosition
            position.y = percentage * (puzzleMaxY - puzzleMinY) + puzzleMinY
            setPuzzlePosition(position, notify: true)
        }
    }

    public var verificationTolerance: CGFloat = Defaults.verificationTolerance

    public var isVerified: Bool {
        abs(puzzlePosition.x - rawPuzzleBlankPosition.x) <= verificationTolerance &&
        abs(puzzlePosition.y - rawPuzzleBlankPosition.y) <= verificationTolerance
    }

    public var enable: Bool = true {
        didSet { isUserInteractionEnabled = enable }
    }

    public var puzzleBlankAlpha: CGFloat = Defaults.puzzleBlankAlpha {
        didSet {
            puzzleBlankAlpha = clampedAlpha(puzzleBlankAlpha)
            backImageView.alpha = puzzleBlankAlpha
        }
    }

    public var puzzleBlankInnerShadowColor: UIColor = .black {
        didSet { applyInnerShadowStyle() }
    }

    public var puzzleBlankInnerShadowRadius: CGFloat = Defaults.shadowRadius {
        didSet {
            puzzleBlankInnerShadowRadius = max(0, puzzleBlankInnerShadowRadius)
            applyInnerShadowStyle()
        }
    }

    public var puzzleBlankInnerShadowOpacity: CGFloat = CGFloat(Defaults.shadowOpacity) {
        didSet {
            puzzleBlankInnerShadowOpacity = clampedAlpha(puzzleBlankInnerShadowOpacity)
            applyInnerShadowStyle()
        }
    }

    public var puzzleBlankInnerShadowOffset: CGSize = .zero {
        didSet { applyInnerShadowStyle() }
    }

    public var puzzleShadowColor: UIColor = .black {
        didSet { applyPuzzleShadowStyle() }
    }

    public var puzzleShadowRadius: CGFloat = Defaults.shadowRadius {
        didSet {
            puzzleShadowRadius = max(0, puzzleShadowRadius)
            applyPuzzleShadowStyle()
        }
    }

    public var puzzleShadowOpacity: CGFloat = CGFloat(Defaults.shadowOpacity) {
        didSet {
            puzzleShadowOpacity = clampedAlpha(puzzleShadowOpacity)
            applyPuzzleShadowStyle()
        }
    }

    public var puzzleShadowOffset: CGSize = .zero {
        didSet { applyPuzzleShadowStyle() }
    }

    public weak var delegate: TTGPuzzleVerifyViewDelegate?
    public var verificationChangeBlock: ((TTGPuzzleVerifyView, Bool) -> Void)?

    private let backImageView = UIImageView()
    private let backMaskLayer = CAShapeLayer()
    private let backInnerShadowLayer = CAShapeLayer()
    private let frontImageView = UIImageView()
    private let frontMaskLayer = CAShapeLayer()
    private let puzzleImageView = UIImageView()
    private let puzzleMaskLayer = CAShapeLayer()
    private let puzzleImageContainerView = UIView()

    private var rawPuzzleSize = Defaults.puzzleSize
    private var rawPuzzleBlankPosition = CGPoint.zero
    private var puzzleContainerPosition = Defaults.puzzlePosition
    private var lastVerification = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isUserInteractionEnabled = true
        clipsToBounds = true
        customPuzzlePatternPath = UIBezierPath(cgPath: Self.path(for: .classicPattern).cgPath)
        configureSubviews()
        configureMaskLayers()
        configureGestureRecognizers()
    }

    private func configureSubviews() {
        configure(imageView: backImageView)
        backImageView.alpha = puzzleBlankAlpha
        addSubview(backImageView)

        configure(imageView: frontImageView)
        addSubview(frontImageView)

        puzzleImageContainerView.backgroundColor = .clear
        puzzleImageContainerView.isUserInteractionEnabled = false
        applyPuzzleShadowStyle()
        addSubview(puzzleImageContainerView)

        configure(imageView: puzzleImageView)
        puzzleImageContainerView.addSubview(puzzleImageView)
    }

    private func configure(imageView: UIImageView) {
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .clear
    }

    private func configureMaskLayers() {
        backMaskLayer.fillRule = .evenOdd
        backImageView.layer.mask = backMaskLayer

        frontMaskLayer.fillRule = .evenOdd
        frontImageView.layer.mask = frontMaskLayer

        puzzleImageView.layer.mask = puzzleMaskLayer

        backInnerShadowLayer.fillRule = .evenOdd
        applyInnerShadowStyle()
        backImageView.layer.addSublayer(backInnerShadowLayer)
    }

    private func configureGestureRecognizers() {
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(_:))))
    }

    @objc(completeVerificationWithAnimation:)
    public func completeVerification(withAnimation: Bool) {
        let updates = {
            self.setPuzzlePosition(self.rawPuzzleBlankPosition, notify: false)
            self.puzzleImageContainerView.layer.shadowOpacity = 0
        }

        if withAnimation {
            UIView.animate(withDuration: Defaults.animationDuration, animations: updates) { _ in
                self.performCallback()
            }
        } else {
            updates()
            performCallback()
        }
    }

    public func resetVerification() {
        setPuzzlePosition(Defaults.puzzlePosition, notify: true)
    }

    @objc private func onPanGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard enable else { return }

        let panLocation = panGestureRecognizer.location(in: self)
        let position = CGPoint(x: panLocation.x - rawPuzzleSize.width / 2,
                               y: panLocation.y - rawPuzzleSize.height / 2)

        if panGestureRecognizer.state == .began {
            UIView.animate(withDuration: Defaults.animationDuration) {
                self.setPuzzlePosition(position, notify: false)
            } completion: { _ in
                self.performCallback()
            }
        } else {
            setPuzzlePosition(position, notify: true)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        backImageView.frame = bounds
        frontImageView.frame = bounds
        puzzleImageContainerView.frame = CGRect(x: puzzleContainerPosition.x,
                                                y: puzzleContainerPosition.y,
                                                width: bounds.width,
                                                height: bounds.height)
        puzzleImageView.frame = puzzleImageContainerView.bounds
        updatePuzzleMask()
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil {
            updatePuzzleMask()
        }
    }

    private func updatePuzzleMask() {
        guard !bounds.isEmpty else { return }

        let puzzlePath = newScaledPuzzlePath()
        let maskPath = UIBezierPath(rect: bounds)
        maskPath.append(UIBezierPath(cgPath: puzzlePath.cgPath))
        maskPath.usesEvenOddFillRule = true

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        backMaskLayer.frame = bounds
        backMaskLayer.path = puzzlePath.cgPath
        frontMaskLayer.frame = bounds
        frontMaskLayer.path = maskPath.cgPath
        puzzleMaskLayer.frame = bounds
        puzzleMaskLayer.path = puzzlePath.cgPath

        let shadowPath = UIBezierPath(rect: bounds.insetBy(dx: Defaults.shadowInset, dy: Defaults.shadowInset))
        shadowPath.append(puzzlePath)
        backInnerShadowLayer.frame = bounds
        backInnerShadowLayer.path = shadowPath.cgPath

        CATransaction.commit()
    }

    private func performCallback() {
        let verified = isVerified
        let xPercentage = puzzleXPercentage
        let yPercentage = puzzleYPercentage
        let position = puzzlePosition

        delegate?.puzzleVerifyView?(self,
                                    didChangedPuzzlePosition: position,
                                    xPercentage: xPercentage,
                                    yPercentage: yPercentage)

        guard lastVerification != verified else { return }
        lastVerification = verified
        delegate?.puzzleVerifyView?(self, didChangedVerification: verified)
        verificationChangeBlock?(self, verified)
    }

    private func newScaledPuzzlePath() -> UIBezierPath {
        let sourcePath: UIBezierPath

        if puzzlePattern == .customPattern, let customPuzzlePatternPath {
            sourcePath = UIBezierPath(cgPath: customPuzzlePatternPath.cgPath)
            rawPuzzleSize = sanitizedPuzzleSize(sourcePath.bounds.size)
        } else {
            sourcePath = UIBezierPath(cgPath: Self.path(for: puzzlePattern).cgPath)
            let sourceSize = sourcePath.bounds.size
            if sourceSize.width > 0, sourceSize.height > 0 {
                sourcePath.apply(CGAffineTransform(scaleX: rawPuzzleSize.width / sourceSize.width,
                                                   y: rawPuzzleSize.height / sourceSize.height))
            }
        }

        let sourceBounds = sourcePath.bounds
        sourcePath.apply(CGAffineTransform(translationX: rawPuzzleBlankPosition.x - sourceBounds.origin.x,
                                           y: rawPuzzleBlankPosition.y - sourceBounds.origin.y))
        return sourcePath
    }

    private func setPuzzlePosition(_ newPosition: CGPoint, notify: Bool) {
        guard enable else { return }

        let position = clampedPuzzlePosition(newPosition)
        puzzleImageContainerView.layer.shadowOpacity = Float(puzzleShadowOpacity)
        puzzleContainerPosition = CGPoint(x: position.x - rawPuzzleBlankPosition.x,
                                          y: position.y - rawPuzzleBlankPosition.y)
        var frame = puzzleImageContainerView.frame
        frame.origin = puzzleContainerPosition
        puzzleImageContainerView.frame = frame

        if notify {
            performCallback()
        }
    }

    private func sanitizedPuzzleSize(_ size: CGSize) -> CGSize {
        CGSize(width: max(1, size.width), height: max(1, size.height))
    }

    private func clampedPuzzlePosition(_ position: CGPoint) -> CGPoint {
        CGPoint(x: min(max(puzzleMinX, position.x), puzzleMaxX),
                y: min(max(puzzleMinY, position.y), puzzleMaxY))
    }

    private func clampedPercentage(_ percentage: CGFloat) -> CGFloat {
        guard percentage.isFinite else { return 0 }
        return min(max(0, percentage), 1)
    }

    private func clampedAlpha(_ alpha: CGFloat) -> CGFloat {
        min(max(0, alpha), 1)
    }

    private var puzzleMinX: CGFloat { 0 }
    private var puzzleMaxX: CGFloat { max(puzzleMinX, bounds.width - rawPuzzleSize.width) }
    private var puzzleMinY: CGFloat { 0 }
    private var puzzleMaxY: CGFloat { max(puzzleMinY, bounds.height - rawPuzzleSize.height) }

    private func applyPuzzleShadowStyle() {
        puzzleImageContainerView.layer.shadowColor = puzzleShadowColor.cgColor
        puzzleImageContainerView.layer.shadowRadius = puzzleShadowRadius
        puzzleImageContainerView.layer.shadowOpacity = Float(puzzleShadowOpacity)
        puzzleImageContainerView.layer.shadowOffset = puzzleShadowOffset
    }

    private func applyInnerShadowStyle() {
        backInnerShadowLayer.shadowColor = puzzleBlankInnerShadowColor.cgColor
        backInnerShadowLayer.shadowRadius = puzzleBlankInnerShadowRadius
        backInnerShadowLayer.shadowOpacity = Float(puzzleBlankInnerShadowOpacity)
        backInnerShadowLayer.shadowOffset = puzzleBlankInnerShadowOffset
    }
}

private extension TTGPuzzleVerifyView {
    static func path(for pattern: TTGPuzzleVerifyPattern) -> UIBezierPath {
        switch pattern {
        case .classicPattern, .customPattern:
            return classicPuzzlePath
        case .squarePattern:
            return squarePath
        case .circlePattern:
            return circlePath
        }
    }

    static let squarePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 100, height: 100))
    static let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 100, height: 100))

    static let classicPuzzlePath: UIBezierPath = {
        let puzzleShape = UIBezierPath()
        puzzleShape.move(to: CGPoint(x: 17.45, y: 71.16))
        puzzleShape.addCurve(to: CGPoint(x: 25, y: 74.69), controlPoint1: CGPoint(x: 20.83, y: 67.76), controlPoint2: CGPoint(x: 25, y: 69.2))
        puzzleShape.addLine(to: CGPoint(x: 25, y: 100))
        puzzleShape.addLine(to: CGPoint(x: 50.31, y: 100))
        puzzleShape.addCurve(to: CGPoint(x: 53.84, y: 92.45), controlPoint1: CGPoint(x: 55.79, y: 100), controlPoint2: CGPoint(x: 57.24, y: 95.83))
        puzzleShape.addCurve(to: CGPoint(x: 50, y: 85.33), controlPoint1: CGPoint(x: 52.18, y: 90.78), controlPoint2: CGPoint(x: 50, y: 89.4))
        puzzleShape.addCurve(to: CGPoint(x: 62.5, y: 75), controlPoint1: CGPoint(x: 50, y: 80.8), controlPoint2: CGPoint(x: 54.62, y: 75))
        puzzleShape.addCurve(to: CGPoint(x: 75, y: 85.33), controlPoint1: CGPoint(x: 70.38, y: 75), controlPoint2: CGPoint(x: 75, y: 80.8))
        puzzleShape.addCurve(to: CGPoint(x: 71.16, y: 92.45), controlPoint1: CGPoint(x: 75, y: 89.4), controlPoint2: CGPoint(x: 72.82, y: 90.78))
        puzzleShape.addCurve(to: CGPoint(x: 74.69, y: 100), controlPoint1: CGPoint(x: 67.76, y: 95.83), controlPoint2: CGPoint(x: 69.2, y: 100))
        puzzleShape.addLine(to: CGPoint(x: 100, y: 100))
        puzzleShape.addLine(to: CGPoint(x: 100, y: 74.69))
        puzzleShape.addCurve(to: CGPoint(x: 92.45, y: 71.16), controlPoint1: CGPoint(x: 100, y: 69.21), controlPoint2: CGPoint(x: 95.83, y: 67.76))
        puzzleShape.addCurve(to: CGPoint(x: 85.33, y: 75), controlPoint1: CGPoint(x: 90.78, y: 72.82), controlPoint2: CGPoint(x: 89.4, y: 75))
        puzzleShape.addCurve(to: CGPoint(x: 75, y: 62.5), controlPoint1: CGPoint(x: 80.8, y: 75), controlPoint2: CGPoint(x: 75, y: 70.38))
        puzzleShape.addCurve(to: CGPoint(x: 85.33, y: 50), controlPoint1: CGPoint(x: 75, y: 54.62), controlPoint2: CGPoint(x: 80.8, y: 50))
        puzzleShape.addCurve(to: CGPoint(x: 92.45, y: 53.84), controlPoint1: CGPoint(x: 89.4, y: 50), controlPoint2: CGPoint(x: 90.78, y: 52.18))
        puzzleShape.addCurve(to: CGPoint(x: 100, y: 50.31), controlPoint1: CGPoint(x: 95.83, y: 57.24), controlPoint2: CGPoint(x: 100, y: 55.8))
        puzzleShape.addLine(to: CGPoint(x: 100, y: 25))
        puzzleShape.addLine(to: CGPoint(x: 74.69, y: 25))
        puzzleShape.addCurve(to: CGPoint(x: 71.16, y: 17.45), controlPoint1: CGPoint(x: 69.21, y: 25), controlPoint2: CGPoint(x: 67.76, y: 20.83))
        puzzleShape.addCurve(to: CGPoint(x: 75, y: 10.33), controlPoint1: CGPoint(x: 72.82, y: 15.78), controlPoint2: CGPoint(x: 75, y: 14.4))
        puzzleShape.addCurve(to: CGPoint(x: 62.5, y: 0), controlPoint1: CGPoint(x: 75, y: 5.8), controlPoint2: CGPoint(x: 70.38, y: 0))
        puzzleShape.addCurve(to: CGPoint(x: 50, y: 10.33), controlPoint1: CGPoint(x: 54.62, y: 0), controlPoint2: CGPoint(x: 50, y: 5.8))
        puzzleShape.addCurve(to: CGPoint(x: 53.84, y: 17.45), controlPoint1: CGPoint(x: 50, y: 14.4), controlPoint2: CGPoint(x: 52.18, y: 15.78))
        puzzleShape.addCurve(to: CGPoint(x: 50.31, y: 25), controlPoint1: CGPoint(x: 57.24, y: 20.83), controlPoint2: CGPoint(x: 55.8, y: 25))
        puzzleShape.addLine(to: CGPoint(x: 25, y: 25))
        puzzleShape.addLine(to: CGPoint(x: 25, y: 50.31))
        puzzleShape.addCurve(to: CGPoint(x: 17.45, y: 53.84), controlPoint1: CGPoint(x: 25, y: 55.79), controlPoint2: CGPoint(x: 20.83, y: 57.24))
        puzzleShape.addCurve(to: CGPoint(x: 10.33, y: 50), controlPoint1: CGPoint(x: 15.78, y: 52.18), controlPoint2: CGPoint(x: 14.4, y: 50))
        puzzleShape.addCurve(to: CGPoint(x: 0, y: 62.5), controlPoint1: CGPoint(x: 5.8, y: 50), controlPoint2: CGPoint(x: 0, y: 54.62))
        puzzleShape.addCurve(to: CGPoint(x: 10.33, y: 75), controlPoint1: CGPoint(x: 0, y: 70.38), controlPoint2: CGPoint(x: 5.8, y: 75))
        puzzleShape.addCurve(to: CGPoint(x: 17.45, y: 71.16), controlPoint1: CGPoint(x: 14.4, y: 75), controlPoint2: CGPoint(x: 15.78, y: 72.82))
        puzzleShape.move(to: CGPoint(x: 17.45, y: 71.16))
        puzzleShape.close()
        return puzzleShape
    }()
}
