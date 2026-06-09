//
//  TTGPuzzleVerifyView.swift
//  TTGPuzzleVerify
//
//  Created by tutuge on 2016/12/10.
//  Migrated to Swift in 2026.
//

import UIKit

/// Built-in puzzle shapes. Use `.customPattern` with `customPuzzlePatternPath` for custom shapes.
@objc(TTGPuzzleVerifyPattern)
public enum TTGPuzzleVerifyPattern: Int {
    case classicPattern = 0
    case squarePattern
    case circlePattern
    case customPattern
}

/// Axis policy for user pan gestures.
@objc(TTGPuzzleVerifyAllowedAxes)
public enum TTGPuzzleVerifyAllowedAxes: Int {
    case horizontal = 0
    case vertical
    case both
}

/// Public state machine for verification lifecycle.
@objc(TTGPuzzleVerifyState)
public enum TTGPuzzleVerifyState: Int {
    case idle = 0
    case dragging
    case verified
    case failed
    case locked
}

@objc(TTGPuzzleVerifySuccessAnimation)
public enum TTGPuzzleVerifySuccessAnimation: Int {
    case none = 0
    case snap
    case snapAndFade
}

@objc(TTGPuzzleVerifyFailureAnimation)
public enum TTGPuzzleVerifyFailureAnimation: Int {
    case none = 0
    case shake
    case reset
    case shakeAndReset
}

/// One sampled movement point used for lightweight behavior analysis.
@objcMembers
public final class TTGPuzzleVerifyTrackPoint: NSObject {
    public let point: CGPoint
    public let timestamp: TimeInterval
    public let velocity: CGPoint

    public init(point: CGPoint, timestamp: TimeInterval, velocity: CGPoint) {
        self.point = point
        self.timestamp = timestamp
        self.velocity = velocity
        super.init()
    }
}

/// Verification result snapshot delivered on completion/failure callbacks.
@objcMembers
public final class TTGPuzzleVerifyResult: NSObject {
    public let isVerified: Bool
    public let puzzlePosition: CGPoint
    public let blankPosition: CGPoint
    public let xOffset: CGFloat
    public let yOffset: CGFloat
    public let elapsedTime: TimeInterval
    public let dragDistance: CGFloat
    public let interactionCount: Int

    public init(isVerified: Bool,
                puzzlePosition: CGPoint,
                blankPosition: CGPoint,
                xOffset: CGFloat,
                yOffset: CGFloat,
                elapsedTime: TimeInterval,
                dragDistance: CGFloat,
                interactionCount: Int) {
        self.isVerified = isVerified
        self.puzzlePosition = puzzlePosition
        self.blankPosition = blankPosition
        self.xOffset = xOffset
        self.yOffset = yOffset
        self.elapsedTime = elapsedTime
        self.dragDistance = dragDistance
        self.interactionCount = interactionCount
        super.init()
    }
}

@objcMembers
public final class TTGPuzzleVerifyShadowStyle: NSObject, NSCopying {
    public var color: UIColor
    public var radius: CGFloat
    public var opacity: CGFloat
    public var offset: CGSize

    public override convenience init() {
        self.init(color: .black, radius: 4, opacity: 0.5, offset: .zero)
    }

    public init(color: UIColor = .black, radius: CGFloat = 4, opacity: CGFloat = 0.5, offset: CGSize = .zero) {
        self.color = color
        self.radius = radius
        self.opacity = opacity
        self.offset = offset
        super.init()
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        TTGPuzzleVerifyShadowStyle(color: color, radius: radius, opacity: opacity, offset: offset)
    }
}

@objcMembers
public final class TTGPuzzleVerifyStyle: NSObject, NSCopying {
    public var blankAlpha: CGFloat
    public var blankInnerShadow: TTGPuzzleVerifyShadowStyle
    public var puzzleShadow: TTGPuzzleVerifyShadowStyle
    public var backgroundColor: UIColor
    public var cornerRadius: CGFloat

    public override convenience init() {
        self.init(blankAlpha: 0.5,
                  blankInnerShadow: TTGPuzzleVerifyShadowStyle(),
                  puzzleShadow: TTGPuzzleVerifyShadowStyle(),
                  backgroundColor: .clear,
                  cornerRadius: 0)
    }

    public init(blankAlpha: CGFloat = 0.5,
                blankInnerShadow: TTGPuzzleVerifyShadowStyle = TTGPuzzleVerifyShadowStyle(),
                puzzleShadow: TTGPuzzleVerifyShadowStyle = TTGPuzzleVerifyShadowStyle(),
                backgroundColor: UIColor = .clear,
                cornerRadius: CGFloat = 0) {
        self.blankAlpha = blankAlpha
        self.blankInnerShadow = blankInnerShadow
        self.puzzleShadow = puzzleShadow
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        super.init()
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        TTGPuzzleVerifyStyle(blankAlpha: blankAlpha,
                             blankInnerShadow: blankInnerShadow.copy() as! TTGPuzzleVerifyShadowStyle,
                             puzzleShadow: puzzleShadow.copy() as! TTGPuzzleVerifyShadowStyle,
                             backgroundColor: backgroundColor,
                             cornerRadius: cornerRadius)
    }
}

/// Behavior and style bundle for applying consistent setup in one call.
@objcMembers
public final class TTGPuzzleVerifyConfiguration: NSObject, NSCopying {
    public var puzzlePattern: TTGPuzzleVerifyPattern
    public var puzzleSize: CGSize
    public var verificationTolerance: CGFloat
    public var allowedAxes: TTGPuzzleVerifyAllowedAxes
    public var autoSnapWhenWithinTolerance: Bool
    public var recordsTrack: Bool
    public var maxRetryCount: Int
    public var style: TTGPuzzleVerifyStyle

    public override convenience init() {
        self.init(puzzlePattern: .classicPattern,
                  puzzleSize: CGSize(width: 100, height: 100),
                  verificationTolerance: 8,
                  allowedAxes: .both,
                  autoSnapWhenWithinTolerance: true,
                  recordsTrack: true,
                  maxRetryCount: 0,
                  style: TTGPuzzleVerifyStyle())
    }

    public init(puzzlePattern: TTGPuzzleVerifyPattern = .classicPattern,
                puzzleSize: CGSize = CGSize(width: 100, height: 100),
                verificationTolerance: CGFloat = 8,
                allowedAxes: TTGPuzzleVerifyAllowedAxes = .both,
                autoSnapWhenWithinTolerance: Bool = true,
                recordsTrack: Bool = true,
                maxRetryCount: Int = 0,
                style: TTGPuzzleVerifyStyle = TTGPuzzleVerifyStyle()) {
        self.puzzlePattern = puzzlePattern
        self.puzzleSize = puzzleSize
        self.verificationTolerance = verificationTolerance
        self.allowedAxes = allowedAxes
        self.autoSnapWhenWithinTolerance = autoSnapWhenWithinTolerance
        self.recordsTrack = recordsTrack
        self.maxRetryCount = maxRetryCount
        self.style = style
        super.init()
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        TTGPuzzleVerifyConfiguration(puzzlePattern: puzzlePattern,
                                     puzzleSize: puzzleSize,
                                     verificationTolerance: verificationTolerance,
                                     allowedAxes: allowedAxes,
                                     autoSnapWhenWithinTolerance: autoSnapWhenWithinTolerance,
                                     recordsTrack: recordsTrack,
                                     maxRetryCount: maxRetryCount,
                                     style: style.copy() as! TTGPuzzleVerifyStyle)
    }
}

/// Objective-C compatible delegate for state, position, success, and failure events.
@objc(TTGPuzzleVerifyViewDelegate)
public protocol TTGPuzzleVerifyViewDelegate: AnyObject {
    @objc optional func puzzleVerifyView(_ puzzleVerifyView: TTGPuzzleVerifyView, didChangedVerification isVerified: Bool)
    @objc optional func puzzleVerifyView(_ puzzleVerifyView: TTGPuzzleVerifyView,
                                         didChangedPuzzlePosition newPosition: CGPoint,
                                         xPercentage: CGFloat,
                                         yPercentage: CGFloat)
    @objc optional func puzzleVerifyView(_ puzzleVerifyView: TTGPuzzleVerifyView, didChangeState state: TTGPuzzleVerifyState)
    @objc optional func puzzleVerifyView(_ puzzleVerifyView: TTGPuzzleVerifyView, didCompleteWith result: TTGPuzzleVerifyResult)
    @objc optional func puzzleVerifyView(_ puzzleVerifyView: TTGPuzzleVerifyView, didFailWith result: TTGPuzzleVerifyResult)
}

/// Puzzle verification view. The class is Swift-native and exported to Objective-C.
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
        static let shadowOpacity: CGFloat = 0.5
        static let shadowInset: CGFloat = -20
    }

    /// Source image displayed by background and puzzle piece layers.
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
            setPuzzlePosition(puzzlePosition, notify: false, source: .programmatic)
            updatePuzzleMask()
        }
    }

    public var puzzleBlankPosition: CGPoint {
        get { rawPuzzleBlankPosition }
        set {
            rawPuzzleBlankPosition = clampedPuzzlePosition(newValue)
            setPuzzlePosition(puzzlePosition, notify: false, source: .programmatic)
            updatePuzzleMask()
        }
    }

    public var puzzlePosition: CGPoint {
        get {
            CGPoint(x: puzzleContainerPosition.x + rawPuzzleBlankPosition.x,
                    y: puzzleContainerPosition.y + rawPuzzleBlankPosition.y)
        }
        set { setPuzzlePosition(newValue, notify: false, source: .programmatic) }
    }

    public var puzzleXPercentage: CGFloat {
        get {
            let range = puzzleMaxX - puzzleMinX
            guard range > 0 else { return 0 }
            return (puzzlePosition.x - puzzleMinX) / range
        }
        set {
            guard canMove else { return }
            let percentage = clampedPercentage(newValue)
            var position = puzzlePosition
            position.x = percentage * (puzzleMaxX - puzzleMinX) + puzzleMinX
            setPuzzlePosition(position, notify: true, source: .programmatic)
        }
    }

    public var puzzleYPercentage: CGFloat {
        get {
            let range = puzzleMaxY - puzzleMinY
            guard range > 0 else { return 0 }
            return (puzzlePosition.y - puzzleMinY) / range
        }
        set {
            guard canMove else { return }
            let percentage = clampedPercentage(newValue)
            var position = puzzlePosition
            position.y = percentage * (puzzleMaxY - puzzleMinY) + puzzleMinY
            setPuzzlePosition(position, notify: true, source: .programmatic)
        }
    }

    public var verificationTolerance: CGFloat = Defaults.verificationTolerance {
        didSet { verificationTolerance = max(0, verificationTolerance) }
    }

    public var isVerified: Bool {
        abs(puzzlePosition.x - rawPuzzleBlankPosition.x) <= verificationTolerance &&
        abs(puzzlePosition.y - rawPuzzleBlankPosition.y) <= verificationTolerance
    }

    public var enable: Bool = true {
        didSet { isUserInteractionEnabled = enable && state != .locked }
    }

    public private(set) var state: TTGPuzzleVerifyState = .idle {
        didSet {
            guard oldValue != state else { return }
            delegate?.puzzleVerifyView?(self, didChangeState: state)
            stateChangeBlock?(self, state)
        }
    }

    /// Controls whether user panning moves horizontally, vertically, or freely.
    public var allowedAxes: TTGPuzzleVerifyAllowedAxes = .both
    /// Automatically snaps the puzzle to the blank when the position enters the tolerance range.
    public var autoSnapWhenWithinTolerance = true
    public var successAnimation: TTGPuzzleVerifySuccessAnimation = .snapAndFade
    public var failureAnimation: TTGPuzzleVerifyFailureAnimation = .shake
    public var resetOnFailure = false
    public var recordsTrack = true
    public var maxRetryCount: Int = 0 {
        didSet { maxRetryCount = max(0, maxRetryCount) }
    }
    public private(set) var retryCount: Int = 0
    /// Recorded movement samples. Clear with `clearTrack()` when reusing the same challenge.
    public private(set) var trackPoints: [TTGPuzzleVerifyTrackPoint] = []

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

    public var puzzleBlankInnerShadowOpacity: CGFloat = Defaults.shadowOpacity {
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

    public var puzzleShadowOpacity: CGFloat = Defaults.shadowOpacity {
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
    public var positionChangeBlock: ((TTGPuzzleVerifyView, CGPoint, CGFloat, CGFloat) -> Void)?
    public var stateChangeBlock: ((TTGPuzzleVerifyView, TTGPuzzleVerifyState) -> Void)?
    public var completionBlock: ((TTGPuzzleVerifyView, TTGPuzzleVerifyResult) -> Void)?
    public var failureBlock: ((TTGPuzzleVerifyView, TTGPuzzleVerifyResult) -> Void)?

    private enum MoveSource {
        case programmatic
        case user
        case internalAnimation
    }

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
    private var interactionStartTime: TimeInterval?
    private var lastTrackPoint: TTGPuzzleVerifyTrackPoint?

    private var canMove: Bool {
        enable && state != .locked
    }

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
        finishVerification(withAnimation: withAnimation, forceCallback: true)
    }

    public func resetVerification() {
        resetInteractionMetrics()
        retryCount = 0
        state = .idle
        setPuzzlePosition(Defaults.puzzlePosition, notify: true, source: .internalAnimation)
    }

    /// Applies a complete behavior/style configuration.
    public func applyConfiguration(_ configuration: TTGPuzzleVerifyConfiguration) {
        puzzlePattern = configuration.puzzlePattern
        puzzleSize = configuration.puzzleSize
        verificationTolerance = configuration.verificationTolerance
        allowedAxes = configuration.allowedAxes
        autoSnapWhenWithinTolerance = configuration.autoSnapWhenWithinTolerance
        recordsTrack = configuration.recordsTrack
        maxRetryCount = configuration.maxRetryCount
        applyStyle(configuration.style)
    }

    public func applyStyle(_ style: TTGPuzzleVerifyStyle) {
        puzzleBlankAlpha = style.blankAlpha
        puzzleBlankInnerShadowColor = style.blankInnerShadow.color
        puzzleBlankInnerShadowRadius = style.blankInnerShadow.radius
        puzzleBlankInnerShadowOpacity = style.blankInnerShadow.opacity
        puzzleBlankInnerShadowOffset = style.blankInnerShadow.offset
        puzzleShadowColor = style.puzzleShadow.color
        puzzleShadowRadius = style.puzzleShadow.radius
        puzzleShadowOpacity = style.puzzleShadow.opacity
        puzzleShadowOffset = style.puzzleShadow.offset
        backgroundColor = style.backgroundColor
        layer.cornerRadius = max(0, style.cornerRadius)
        layer.masksToBounds = style.cornerRadius > 0
    }

    public func clearTrack() {
        trackPoints.removeAll()
        lastTrackPoint = nil
        interactionStartTime = nil
    }

    /// Builds a result snapshot for the current puzzle position and interaction metrics.
    public func currentResult() -> TTGPuzzleVerifyResult {
        makeResult(isVerified: isVerified)
    }

    public func markVerificationFailed() {
        handleFailure(shouldAnimate: true)
    }

    public func unlock() {
        retryCount = 0
        state = .idle
        isUserInteractionEnabled = enable
    }

    @objc private func onPanGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard canMove else { return }

        switch panGestureRecognizer.state {
        case .began:
            beginInteractionIfNeeded()
            state = .dragging
            movePuzzle(to: position(for: panGestureRecognizer), animated: true, source: .user)
        case .changed:
            setPuzzlePosition(position(for: panGestureRecognizer), notify: true, source: .user)
        case .ended, .cancelled, .failed:
            setPuzzlePosition(position(for: panGestureRecognizer), notify: true, source: .user)
            completeOrFailAfterUserInteraction()
        default:
            break
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

    private func position(for panGestureRecognizer: UIPanGestureRecognizer) -> CGPoint {
        let panLocation = panGestureRecognizer.location(in: self)
        let requestedPosition = CGPoint(x: panLocation.x - rawPuzzleSize.width / 2,
                                        y: panLocation.y - rawPuzzleSize.height / 2)
        return constrainedPositionForAllowedAxes(requestedPosition)
    }

    private func constrainedPositionForAllowedAxes(_ position: CGPoint) -> CGPoint {
        var constrained = position
        switch allowedAxes {
        case .horizontal:
            constrained.y = puzzlePosition.y
        case .vertical:
            constrained.x = puzzlePosition.x
        case .both:
            break
        }
        return constrained
    }

    private func movePuzzle(to position: CGPoint, animated: Bool, source: MoveSource) {
        if animated {
            UIView.animate(withDuration: Defaults.animationDuration) {
                self.setPuzzlePosition(position, notify: false, source: source)
            } completion: { _ in
                self.performCallback()
            }
        } else {
            setPuzzlePosition(position, notify: true, source: source)
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
        positionChangeBlock?(self, position, xPercentage, yPercentage)

        guard lastVerification != verified else { return }
        lastVerification = verified
        delegate?.puzzleVerifyView?(self, didChangedVerification: verified)
        verificationChangeBlock?(self, verified)

        if verified, autoSnapWhenWithinTolerance, state != .verified {
            finishVerification(withAnimation: true, forceCallback: false)
        }
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

    private func setPuzzlePosition(_ newPosition: CGPoint, notify: Bool, source: MoveSource) {
        guard canMove || source == .internalAnimation else { return }

        let position = clampedPuzzlePosition(newPosition)
        puzzleImageContainerView.layer.shadowOpacity = Float(puzzleShadowOpacity)
        puzzleContainerPosition = CGPoint(x: position.x - rawPuzzleBlankPosition.x,
                                          y: position.y - rawPuzzleBlankPosition.y)
        var frame = puzzleImageContainerView.frame
        frame.origin = puzzleContainerPosition
        puzzleImageContainerView.frame = frame

        if source == .user || (source == .programmatic && recordsTrack) {
            appendTrackPoint(position)
        }

        if notify {
            performCallback()
        }
    }

    private func beginInteractionIfNeeded() {
        if interactionStartTime == nil {
            interactionStartTime = CACurrentMediaTime()
        }
    }

    private func resetInteractionMetrics() {
        clearTrack()
        lastVerification = isVerified
    }

    private func appendTrackPoint(_ position: CGPoint) {
        guard recordsTrack else { return }
        beginInteractionIfNeeded()
        let timestamp = CACurrentMediaTime()
        let velocity: CGPoint
        if let lastTrackPoint {
            let delta = max(timestamp - lastTrackPoint.timestamp, .ulpOfOne)
            velocity = CGPoint(x: (position.x - lastTrackPoint.point.x) / delta,
                               y: (position.y - lastTrackPoint.point.y) / delta)
        } else {
            velocity = .zero
        }
        let point = TTGPuzzleVerifyTrackPoint(point: position, timestamp: timestamp, velocity: velocity)
        trackPoints.append(point)
        lastTrackPoint = point
    }

    private func completeOrFailAfterUserInteraction() {
        if isVerified {
            finishVerification(withAnimation: autoSnapWhenWithinTolerance, forceCallback: false)
        } else {
            handleFailure(shouldAnimate: true)
        }
    }

    private func finishVerification(withAnimation: Bool, forceCallback: Bool) {
        let updates = {
            self.setPuzzlePosition(self.rawPuzzleBlankPosition, notify: false, source: .internalAnimation)
            if self.successAnimation == .snapAndFade {
                self.puzzleImageContainerView.layer.shadowOpacity = 0
            }
        }
        let completion = {
            self.state = .verified
            let result = self.makeResult(isVerified: true)
            self.delegate?.puzzleVerifyView?(self, didCompleteWith: result)
            self.completionBlock?(self, result)
            if forceCallback || self.lastVerification != true {
                self.performCallback()
            }
        }

        guard successAnimation != .none else {
            updates()
            completion()
            return
        }

        if withAnimation {
            UIView.animate(withDuration: Defaults.animationDuration, animations: updates) { _ in completion() }
        } else {
            updates()
            completion()
        }
    }

    private func handleFailure(shouldAnimate: Bool) {
        retryCount += 1
        state = maxRetryCount > 0 && retryCount >= maxRetryCount ? .locked : .failed
        isUserInteractionEnabled = enable && state != .locked

        let result = makeResult(isVerified: false)
        delegate?.puzzleVerifyView?(self, didFailWith: result)
        failureBlock?(self, result)

        guard shouldAnimate else { return }
        showFailureFeedback()
    }

    private func showFailureFeedback() {
        switch failureAnimation {
        case .none:
            if resetOnFailure { setPuzzlePosition(Defaults.puzzlePosition, notify: true, source: .internalAnimation) }
        case .shake:
            applyShakeAnimation()
            if resetOnFailure { setPuzzlePosition(Defaults.puzzlePosition, notify: true, source: .internalAnimation) }
        case .reset:
            UIView.animate(withDuration: Defaults.animationDuration) {
                self.setPuzzlePosition(Defaults.puzzlePosition, notify: false, source: .internalAnimation)
            } completion: { _ in self.performCallback() }
        case .shakeAndReset:
            applyShakeAnimation()
            UIView.animate(withDuration: Defaults.animationDuration, delay: 0.12, options: [.beginFromCurrentState]) {
                self.setPuzzlePosition(Defaults.puzzlePosition, notify: false, source: .internalAnimation)
            } completion: { _ in self.performCallback() }
        }
    }

    private func applyShakeAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.values = [-10, 8, -6, 4, 0]
        animation.duration = 0.28
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        puzzleImageContainerView.layer.add(animation, forKey: "TTGPuzzleVerifyFailureShake")
    }

    private func makeResult(isVerified: Bool) -> TTGPuzzleVerifyResult {
        let position = puzzlePosition
        let blankPosition = rawPuzzleBlankPosition
        return TTGPuzzleVerifyResult(isVerified: isVerified,
                                     puzzlePosition: position,
                                     blankPosition: blankPosition,
                                     xOffset: position.x - blankPosition.x,
                                     yOffset: position.y - blankPosition.y,
                                     elapsedTime: elapsedTime,
                                     dragDistance: dragDistance,
                                     interactionCount: trackPoints.count)
    }

    private var elapsedTime: TimeInterval {
        guard let interactionStartTime else { return 0 }
        return CACurrentMediaTime() - interactionStartTime
    }

    private var dragDistance: CGFloat {
        guard trackPoints.count > 1 else { return 0 }
        return zip(trackPoints, trackPoints.dropFirst()).reduce(CGFloat(0)) { partialResult, pair in
            let dx = pair.1.point.x - pair.0.point.x
            let dy = pair.1.point.y - pair.0.point.y
            return partialResult + hypot(dx, dy)
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
