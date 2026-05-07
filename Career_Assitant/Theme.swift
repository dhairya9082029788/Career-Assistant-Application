//
//  Theme.swift
//  Career_Assitant
//
//  Created by Dhairya on 01/05/26.
//
import UIKit
// MARK: - Design Tokens
struct DS {
    static let bg          = UIColor(hex: "#0A0A0F")
    static let surface     = UIColor(hex: "#13131A")
    static let surfaceHigh = UIColor(hex: "#1C1C27")
    static let border      = UIColor(hex: "#2A2A3D")
    static let accent      = UIColor(hex: "#7C6EFA")
    static let accentSoft  = UIColor(hex: "#7C6EFA").withAlphaComponent(0.15)
    static let accentGlow  = UIColor(hex: "#7C6EFA").withAlphaComponent(0.35)
    static let green       = UIColor(hex: "#4ADE80")
    static let orange      = UIColor(hex: "#FB923C")
    static let red         = UIColor(hex: "#F87171")
    static let textPrimary = UIColor(hex: "#F0F0FF")
    static let textSecond  = UIColor(hex: "#8888AA")
    static let textMuted   = UIColor(hex: "#44445A")

    static func font(_ size: CGFloat, _ weight: UIFont.Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
    static func monoFont(_ size: CGFloat) -> UIFont {
        return UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
    }
}


// MARK: - UIColor Hex Extension
extension UIColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        if h.count == 6 { h = "FF" + h }
        var val: UInt64 = 0
        Scanner(string: h).scanHexInt64(&val)
        self.init(
            red:   CGFloat((val >> 16) & 0xFF) / 255,
            green: CGFloat((val >>  8) & 0xFF) / 255,
            blue:  CGFloat( val  & 0xFF) / 255,
            alpha: CGFloat((val >> 24) & 0xFF) / 255
        )
    }
}


// MARK: - GlowButton
final class GlowButton: UIButton {
    private let glowLayer = CALayer()
    var glowColor: UIColor = DS.accent { didSet { updateGlow() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(glowLayer, at: 0)
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp),   for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
    }
    required init?(coder: NSCoder) { fatalError() }

    private func updateGlow() {
        glowLayer.shadowColor  = glowColor.cgColor
        glowLayer.shadowRadius = 12
        glowLayer.shadowOpacity = 0
        glowLayer.shadowOffset  = .zero
        glowLayer.backgroundColor = glowColor.withAlphaComponent(0.18).cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        glowLayer.frame = bounds
        glowLayer.cornerRadius = layer.cornerRadius
        updateGlow()
    }

    @objc private func touchDown() {
        UIView.animate(withDuration: 0.12, delay: 0,
                       usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        }
        let anim = CABasicAnimation(keyPath: "shadowOpacity")
        anim.toValue = 0.9; anim.duration = 0.15; anim.fillMode = .forwards; anim.isRemovedOnCompletion = false
        glowLayer.add(anim, forKey: "glow")
        glowLayer.shadowOpacity = 0.9
    }

    @objc private func touchUp() {
        UIView.animate(withDuration: 0.25, delay: 0,
                       usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3) {
            self.transform = .identity
        }
        let anim = CABasicAnimation(keyPath: "shadowOpacity")
        anim.toValue = 0.0; anim.duration = 0.3; anim.fillMode = .forwards; anim.isRemovedOnCompletion = false
        glowLayer.add(anim, forKey: "glow")
        glowLayer.shadowOpacity = 0
    }
}

// MARK: - Animated Score Ring
final class ScoreRingView: UIView {
    private let trackLayer = CAShapeLayer()
    private let fillLayer  = CAShapeLayer()
    private let percentagelabel = UILabel()
    private let subLabel   = UILabel()

    var score: Int = 0 {
        didSet { animateToScore(score) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        trackLayer.fillColor   = UIColor.clear.cgColor
        trackLayer.strokeColor = DS.border.cgColor
        trackLayer.lineWidth   = 8
        layer.addSublayer(trackLayer)

        fillLayer.fillColor     = UIColor.clear.cgColor
        fillLayer.strokeColor   = DS.accent.cgColor
        fillLayer.lineWidth     = 8
        fillLayer.lineCap       = .round
        fillLayer.strokeEnd     = 0
        fillLayer.shadowColor   = DS.accent.cgColor
        fillLayer.shadowRadius  = 6
        fillLayer.shadowOpacity = 0.8
        fillLayer.shadowOffset  = .zero
        layer.addSublayer(fillLayer)

        percentagelabel.text = "--%"
        percentagelabel.font = DS.font(28, .bold)
        percentagelabel.textColor = DS.textPrimary
        percentagelabel.textAlignment = .center
        addSubview(percentagelabel)

        subLabel.text = "ATS SCORE"
        subLabel.font = DS.font(9, .semibold)
        subLabel.textColor = DS.textSecond
        subLabel.textAlignment = .center
        addSubview(subLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let r = min(bounds.width, bounds.height) / 2 - 10
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let startAngle = -CGFloat.pi / 2
        let endAngle   =  startAngle + 2 * CGFloat.pi
        let path = UIBezierPath(arcCenter: center, radius: r,
                                startAngle: startAngle, endAngle: endAngle, clockwise: true)
        trackLayer.path = path.cgPath
        fillLayer.path  = path.cgPath

        percentagelabel.frame = CGRect(x: 0, y: bounds.midY - 22, width: bounds.width, height: 30)
        subLabel.frame = CGRect(x: 0, y: bounds.midY + 10, width: bounds.width, height: 16)
    }

    private func animateToScore(_ s: Int) {
        let pct = CGFloat(s) / 100.0
        percentagelabel.text = "\(s)%"

        if s >= 85      { fillLayer.strokeColor = DS.green.cgColor;  fillLayer.shadowColor = DS.green.cgColor;  percentagelabel.textColor = DS.green  }
        else if s >= 65 { fillLayer.strokeColor = DS.orange.cgColor; fillLayer.shadowColor = DS.orange.cgColor; percentagelabel.textColor = DS.orange }
        else            { fillLayer.strokeColor = DS.red.cgColor;    fillLayer.shadowColor = DS.red.cgColor;    percentagelabel.textColor = DS.red    }

        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue       = fillLayer.presentation()?.strokeEnd ?? 0
        anim.toValue         = pct
        anim.duration        = 1.4
        anim.timingFunction  = CAMediaTimingFunction(name: .easeInEaseOut)
        anim.fillMode        = .forwards
        anim.isRemovedOnCompletion = false
        fillLayer.strokeEnd  = pct
        fillLayer.add(anim, forKey: "ring")

        // Bounce label
        UIView.animate(withDuration: 0.3, delay: 0.5,
                       usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8) {
            self.percentagelabel.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) { self.percentagelabel.transform = .identity }
        }
    }
}

// MARK: - Pill Tag View
final class TagView: UIView {
    private let label = UILabel()
    init(text: String, color: UIColor) {
        super.init(frame: .zero)
        backgroundColor = color.withAlphaComponent(0.15)
        layer.cornerRadius = 10
        layer.borderWidth  = 1
        layer.borderColor  = color.withAlphaComponent(0.4).cgColor
        label.text      = text
        label.font      = DS.font(11, .semibold)
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Floating Label Text Field Container
final class FloatingCard: UIView {
    let headerLabel = UILabel()
    let textView    = UITextView()
    let accessoryView: UIView?

    init(title: String, placeholder: String, height: CGFloat, accessory: UIView? = nil) {
        self.accessoryView = accessory
        super.init(frame: .zero)
        backgroundColor    = DS.surface
        layer.cornerRadius = 16
        layer.borderWidth  = 1
        layer.borderColor  = DS.border.cgColor

        headerLabel.text      = title
        headerLabel.font      = DS.font(11, .bold)
        headerLabel.textColor = DS.textSecond
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        textView.backgroundColor       = .clear
        textView.font                  = DS.font(13.5)
        textView.textColor             = DS.textPrimary
        textView.tintColor             = DS.accent
        textView.textContainerInset    = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.translatesAutoresizingMaskIntoConstraints = false
        setPlaceholder(placeholder)

        addSubview(headerLabel)
        addSubview(textView)

        var constraints: [NSLayoutConstraint] = [
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
        ]

        if let acc = accessory {
            acc.translatesAutoresizingMaskIntoConstraints = false
            addSubview(acc)
            constraints += [
                acc.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
                acc.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
                headerLabel.trailingAnchor.constraint(lessThanOrEqualTo: acc.leadingAnchor, constant: -8),
                textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
            ]
        } else {
            constraints += [textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)]
        }
        NSLayoutConstraint.activate(constraints)
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setPlaceholder(_ text: String) {
        textView.text      = text
        textView.textColor = DS.textMuted
    }

    func highlight(_ on: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.layer.borderColor = on ? DS.accent.cgColor : DS.border.cgColor
            self.layer.shadowColor  = on ? DS.accent.cgColor : UIColor.clear.cgColor
            self.layer.shadowOpacity = on ? 0.25 : 0
            self.layer.shadowRadius  = on ? 8 : 0
            self.layer.shadowOffset  = .zero
        }
    }
}

// MARK: - Pulsing Loader
final class PulsingLoader: UIView {
    private let ring1 = UIView()
    private let ring2 = UIView()
    private let ring3 = UIView()
    private let dotView = UIView()
    private var isAnimating = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor       = DS.surface.withAlphaComponent(0.95)
        layer.cornerRadius    = 20
        layer.borderWidth     = 1
        layer.borderColor     = DS.border.cgColor

        for (v, size, color) in [(ring1, 70.0, DS.accent.withAlphaComponent(0.2)),
                                  (ring2, 50.0, DS.accent.withAlphaComponent(0.35)),
                                  (ring3, 30.0, DS.accent.withAlphaComponent(0.6))] {
            v.backgroundColor    = color
            v.layer.cornerRadius = CGFloat(size / 2)
            v.translatesAutoresizingMaskIntoConstraints = false
            addSubview(v)
            NSLayoutConstraint.activate([
                v.centerXAnchor.constraint(equalTo: centerXAnchor),
                v.centerYAnchor.constraint(equalTo: centerYAnchor),
                v.widthAnchor.constraint(equalToConstant: CGFloat(size)),
                v.heightAnchor.constraint(equalToConstant: CGFloat(size))
            ])
        }
        dotView.backgroundColor    = DS.accent
        dotView.layer.cornerRadius = 6
        dotView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dotView)
        NSLayoutConstraint.activate([
            dotView.centerXAnchor.constraint(equalTo: centerXAnchor),
            dotView.centerYAnchor.constraint(equalTo: centerYAnchor),
            dotView.widthAnchor.constraint(equalToConstant: 12),
            dotView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        pulseRing(ring1, delay: 0,    scale: 1.3)
        pulseRing(ring2, delay: 0.2,  scale: 1.25)
        pulseRing(ring3, delay: 0.4,  scale: 1.2)
        UIView.animate(withDuration: 0.6, delay: 0,
                       options: [.repeat, .autoreverse]) {
            self.dotView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.dotView.alpha     = 0.6
        }
    }

    private func pulseRing(_ v: UIView, delay: Double, scale: CGFloat) {
        UIView.animate(withDuration: 0.9, delay: delay,
                       options: [.repeat, .autoreverse, .allowUserInteraction]) {
            v.transform = CGAffineTransform(scaleX: scale, y: scale)
            v.alpha     = 0.4
        }
    }

    func stopAnimating() {
        isAnimating = false
        [ring1, ring2, ring3, dotView].forEach {
            $0.layer.removeAllAnimations()
            $0.transform = .identity
            $0.alpha     = 1
        }
    }
}
