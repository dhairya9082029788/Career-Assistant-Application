import UIKit
import PDFKit
import UniformTypeIdentifiers

// MARK: - Main View Controller
final class ViewController: UIViewController, UITextViewDelegate, UIDocumentPickerDelegate {

    private let scrollView   = UIScrollView()
    private let contentView  = UIView()
    private let headerView   = UIView()
    private let logoLabel    = UILabel()
    private let subtitleLabel = UILabel()
    private let particleLayer = CAEmitterLayer()

    private var resumeCard: FloatingCard!
    private var jobCard: FloatingCard!
    private let uploadBtn   = GlowButton()

    private let scoreRing   = ScoreRingView()
    private let flagsCard   = UIView()
    private let flagsTitle  = UILabel()
    private let flagsTextView = UITextView()

    private let tabBar      = UIView()
    private var tabButtons: [GlowButton] = []
    private let tabIndicator = UIView()
    private var selectedTab = 0

    private let resultCard  = UIView()
    private let resultHeader = UIView()
    private let resultTitle = UILabel()
    private let copyBtn     = UIButton(type: .system)
    private let resultTextView = UITextView()

    private let loader      = PulsingLoader()

    private var placeholderResume = "Paste or upload your resume content here…"
    private var placeholderJob    = "Paste the job description here…"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.bg
        navigationController?.navigationBar.isHidden = true
        buildUI()
        animateEntrance()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        particleLayer.emitterPosition = CGPoint(x: headerView.bounds.width / 2, y: 0)
        particleLayer.emitterSize     = CGSize(width: headerView.bounds.width, height: 1)
    }

    private func buildUI() {
        buildHeader()
        buildScrollContent()
        buildLoader()
    }

    private func buildHeader() {
        headerView.backgroundColor = DS.surface
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        let cell       = CAEmitterCell()
        cell.contents  = UIImage(systemName: "sparkle")?.cgImage
        cell.birthRate = 1.5
        cell.lifetime  = 5
        cell.velocity  = 60
        cell.velocityRange = 30
        cell.emissionLongitude = .pi
        cell.scale     = 0.04
        cell.scaleRange = 0.02
        cell.alphaSpeed = -0.2
        cell.color     = DS.accent.withAlphaComponent(0.5).cgColor
        particleLayer.emitterCells = [cell]
        particleLayer.emitterShape = .line
        headerView.layer.addSublayer(particleLayer)

        logoLabel.text          = "CAREER\nASSISTANT"
        logoLabel.font          = UIFont(name: "Futura-Bold", size: 28) ?? DS.font(28, .black)
        logoLabel.textColor     = DS.textPrimary
        logoLabel.numberOfLines = 2
        logoLabel.translatesAutoresizingMaskIntoConstraints = false

        let accentDot       = UILabel()
        accentDot.text      = "PRO"
        accentDot.font      = DS.font(10, .bold)
        accentDot.textColor = DS.bg
        accentDot.backgroundColor = DS.accent
        accentDot.layer.cornerRadius = 4
        accentDot.clipsToBounds = true
        accentDot.textAlignment = .center
        accentDot.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.text          = "AI-Powered Resume Intelligence"
        subtitleLabel.font          = DS.font(12)
        subtitleLabel.textColor     = DS.textSecond
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let divider       = UIView()
        divider.backgroundColor = DS.border
        divider.translatesAutoresizingMaskIntoConstraints = false

        [logoLabel, accentDot, subtitleLabel, divider].forEach { headerView.addSubview($0) }

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            logoLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            accentDot.centerYAnchor.constraint(equalTo: logoLabel.topAnchor, constant: 8),
            accentDot.leadingAnchor.constraint(equalTo: logoLabel.trailingAnchor, constant: 8),
            accentDot.widthAnchor.constraint(equalToConstant: 32),
            accentDot.heightAnchor.constraint(equalToConstant: 18),
            subtitleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            divider.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
    }

    private func buildScrollContent() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        buildInputSection()
        buildAnalyticsSection()
        buildActionTabs()
        buildResultCard()
    }

    private func buildInputSection() {
        uploadBtn.setImage(UIImage(systemName: "paperclip"), for: .normal)
        uploadBtn.setTitle(" PDF", for: .normal)
        uploadBtn.tintColor      = DS.accent
        uploadBtn.setTitleColor(DS.accent, for: .normal)
        uploadBtn.titleLabel?.font = DS.font(12, .semibold)
        uploadBtn.backgroundColor  = DS.accentSoft
        uploadBtn.layer.cornerRadius = 10
        uploadBtn.layer.borderWidth = 1
        uploadBtn.layer.borderColor = DS.accent.withAlphaComponent(0.3).cgColor
        uploadBtn.glowColor        = DS.accent
        uploadBtn.addTarget(self, action: #selector(didTapUpload), for: .touchUpInside)

        resumeCard = FloatingCard(title: "RESUME", placeholder: placeholderResume, height: 120, accessory: uploadBtn)
        jobCard    = FloatingCard(title: "JOB DESCRIPTION", placeholder: placeholderJob, height: 110)

        resumeCard.textView.delegate = self
        jobCard.textView.delegate    = self
        resumeCard.translatesAutoresizingMaskIntoConstraints = false
        jobCard.translatesAutoresizingMaskIntoConstraints    = false

        contentView.addSubview(resumeCard)
        contentView.addSubview(jobCard)

        NSLayoutConstraint.activate([
            resumeCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            resumeCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resumeCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            jobCard.topAnchor.constraint(equalTo: resumeCard.bottomAnchor, constant: 14),
            jobCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            jobCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }

    private func buildAnalyticsSection() {
        let scoreCard = UIView()
        scoreCard.backgroundColor    = DS.surface
        scoreCard.layer.cornerRadius = 16
        scoreCard.layer.borderWidth  = 1
        scoreCard.layer.borderColor  = DS.border.cgColor
        scoreCard.translatesAutoresizingMaskIntoConstraints = false

        scoreRing.translatesAutoresizingMaskIntoConstraints = false
        scoreCard.addSubview(scoreRing)

        flagsCard.backgroundColor    = DS.surface
        flagsCard.layer.cornerRadius = 16
        flagsCard.layer.borderWidth  = 1
        flagsCard.layer.borderColor  = DS.border.cgColor
        flagsCard.translatesAutoresizingMaskIntoConstraints = false

        flagsTitle.text      = "ANALYSIS"
        flagsTitle.font      = DS.font(11, .bold)
        flagsTitle.textColor = DS.textSecond
        flagsTitle.translatesAutoresizingMaskIntoConstraints = false

        flagsTextView.backgroundColor    = .clear
        flagsTextView.font               = DS.font(12)
        flagsTextView.textColor          = DS.textSecond
        flagsTextView.isEditable         = false
        flagsTextView.isScrollEnabled    = false
        flagsTextView.text               = "Run an Elite Audit to see red flags and missing keywords."
        flagsTextView.tintColor          = DS.accent
        flagsTextView.translatesAutoresizingMaskIntoConstraints = false

        flagsCard.addSubview(flagsTitle)
        flagsCard.addSubview(flagsTextView)

        contentView.addSubview(scoreCard)
        contentView.addSubview(flagsCard)

        NSLayoutConstraint.activate([
            scoreCard.topAnchor.constraint(equalTo: jobCard.bottomAnchor, constant: 20),
            scoreCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            scoreCard.widthAnchor.constraint(equalToConstant: 130),
            scoreCard.heightAnchor.constraint(equalToConstant: 130),
            scoreRing.centerXAnchor.constraint(equalTo: scoreCard.centerXAnchor),
            scoreRing.centerYAnchor.constraint(equalTo: scoreCard.centerYAnchor),
            scoreRing.widthAnchor.constraint(equalToConstant: 110),
            scoreRing.heightAnchor.constraint(equalToConstant: 110),
            flagsCard.topAnchor.constraint(equalTo: scoreCard.topAnchor),
            flagsCard.leadingAnchor.constraint(equalTo: scoreCard.trailingAnchor, constant: 14),
            flagsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            flagsCard.bottomAnchor.constraint(equalTo: scoreCard.bottomAnchor),
            flagsTitle.topAnchor.constraint(equalTo: flagsCard.topAnchor, constant: 14),
            flagsTitle.leadingAnchor.constraint(equalTo: flagsCard.leadingAnchor, constant: 14),
            flagsTextView.topAnchor.constraint(equalTo: flagsTitle.bottomAnchor, constant: 8),
            flagsTextView.leadingAnchor.constraint(equalTo: flagsCard.leadingAnchor, constant: 10),
            flagsTextView.trailingAnchor.constraint(equalTo: flagsCard.trailingAnchor, constant: -10),
            flagsTextView.bottomAnchor.constraint(lessThanOrEqualTo: flagsCard.bottomAnchor, constant: -10)
        ])
    }

    private func buildActionTabs() {
        tabBar.backgroundColor    = DS.surface
        tabBar.layer.cornerRadius = 16
        tabBar.layer.borderWidth  = 1
        tabBar.layer.borderColor  = DS.border.cgColor
        tabBar.translatesAutoresizingMaskIntoConstraints = false

        tabIndicator.backgroundColor    = DS.accent.withAlphaComponent(0.2)
        tabIndicator.layer.cornerRadius = 10
        tabIndicator.layer.borderWidth  = 1
        tabIndicator.layer.borderColor  = DS.accent.withAlphaComponent(0.5).cgColor
        tabIndicator.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(tabIndicator)

        let tabs: [(String, String)] = [
            ("wand.and.stars", "TAILOR"),
            ("envelope.fill",  "COVER"),
            ("paperplane.fill","EMAIL"),
            ("bolt.fill",      "AUDIT")
        ]

        let stack = UIStackView()
        stack.axis         = .horizontal
        stack.distribution = .fillEqually
        stack.spacing      = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(stack)

        for (i, tab) in tabs.enumerated() {
            let btn = GlowButton()
            btn.glowColor = DS.accent

            let vStack = UIStackView()
            vStack.axis      = .vertical
            vStack.alignment = .center
            vStack.spacing   = 3
            vStack.isUserInteractionEnabled = false

            let img = UIImageView(image: UIImage(systemName: tab.0))
            img.tintColor   = i == 0 ? DS.accent : DS.textMuted
            img.contentMode = .scaleAspectFit
            img.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([img.widthAnchor.constraint(equalToConstant: 18), img.heightAnchor.constraint(equalToConstant: 18)])

            let lbl         = UILabel()
            lbl.text        = tab.1
            lbl.font        = DS.font(9, .bold)
            lbl.textColor   = i == 0 ? DS.accent : DS.textMuted
            lbl.textAlignment = .center

            vStack.addArrangedSubview(img)
            vStack.addArrangedSubview(lbl)
            vStack.translatesAutoresizingMaskIntoConstraints = false
            btn.addSubview(vStack)
            NSLayoutConstraint.activate([
                vStack.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
                vStack.centerYAnchor.constraint(equalTo: btn.centerYAnchor)
            ])

            btn.tag = i
            btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(btn)
            tabButtons.append(btn)
        }

        contentView.addSubview(tabBar)

        NSLayoutConstraint.activate([
            tabBar.topAnchor.constraint(equalTo: jobCard.bottomAnchor, constant: 170),
            tabBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tabBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tabBar.heightAnchor.constraint(equalToConstant: 64),
            stack.topAnchor.constraint(equalTo: tabBar.topAnchor),
            stack.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor),
        ])

        DispatchQueue.main.async { self.moveIndicator(to: 0, animated: false) }
    }

    private func buildResultCard() {
        resultCard.backgroundColor    = DS.surface
        resultCard.layer.cornerRadius = 16
        resultCard.layer.borderWidth  = 1
        resultCard.layer.borderColor  = DS.border.cgColor
        resultCard.translatesAutoresizingMaskIntoConstraints = false

        resultHeader.backgroundColor = DS.surfaceHigh
        resultHeader.translatesAutoresizingMaskIntoConstraints = false

        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 10000, height: 44),
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 16, height: 16))
        maskLayer.path = path.cgPath
        resultHeader.layer.mask = maskLayer

        resultTitle.text      = "OUTPUT"
        resultTitle.font      = DS.font(11, .bold)
        resultTitle.textColor = DS.textSecond
        resultTitle.translatesAutoresizingMaskIntoConstraints = false

        copyBtn.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        copyBtn.tintColor = DS.textSecond
        copyBtn.addTarget(self, action: #selector(copyResult), for: .touchUpInside)
        copyBtn.translatesAutoresizingMaskIntoConstraints = false

        resultHeader.addSubview(resultTitle)
        resultHeader.addSubview(copyBtn)

        resultTextView.backgroundColor    = .clear
        resultTextView.font               = DS.font(13.5)
        resultTextView.textColor          = DS.textSecond
        resultTextView.isEditable         = false
        resultTextView.isScrollEnabled    = false
        resultTextView.tintColor          = DS.accent
        resultTextView.text               = "Your AI-generated output will appear here after you tap one of the action tabs above."
        resultTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        resultTextView.translatesAutoresizingMaskIntoConstraints = false

        resultCard.addSubview(resultHeader)
        resultCard.addSubview(resultTextView)
        contentView.addSubview(resultCard)

        NSLayoutConstraint.activate([
            resultCard.topAnchor.constraint(equalTo: tabBar.bottomAnchor, constant: 14),
            resultCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            resultCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            resultHeader.topAnchor.constraint(equalTo: resultCard.topAnchor),
            resultHeader.leadingAnchor.constraint(equalTo: resultCard.leadingAnchor),
            resultHeader.trailingAnchor.constraint(equalTo: resultCard.trailingAnchor),
            resultHeader.heightAnchor.constraint(equalToConstant: 44),
            resultTitle.leadingAnchor.constraint(equalTo: resultHeader.leadingAnchor, constant: 16),
            resultTitle.centerYAnchor.constraint(equalTo: resultHeader.centerYAnchor),
            copyBtn.trailingAnchor.constraint(equalTo: resultHeader.trailingAnchor, constant: -12),
            copyBtn.centerYAnchor.constraint(equalTo: resultHeader.centerYAnchor),
            resultTextView.topAnchor.constraint(equalTo: resultHeader.bottomAnchor),
            resultTextView.leadingAnchor.constraint(equalTo: resultCard.leadingAnchor),
            resultTextView.trailingAnchor.constraint(equalTo: resultCard.trailingAnchor),
            resultTextView.bottomAnchor.constraint(equalTo: resultCard.bottomAnchor),
            resultTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 240)
        ])
    }

    private func buildLoader() {
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.alpha = 0
        view.addSubview(loader)
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loader.widthAnchor.constraint(equalToConstant: 120),
            loader.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    private func animateEntrance() {
        let views: [UIView] = [resumeCard, jobCard]
        views.enumerated().forEach { i, v in
            v.alpha     = 0
            v.transform = CGAffineTransform(translationX: 0, y: 30)
            UIView.animate(withDuration: 0.6, delay: 0.15 * Double(i),
                           usingSpringWithDamping: 0.75, initialSpringVelocity: 0.3) {
                v.alpha     = 1
                v.transform = .identity
            }
        }
    }

    @objc private func tabTapped(_ sender: UIButton) {
        let idx = sender.tag
        guard idx != selectedTab else {
            runAction(for: idx)
            return
        }
        selectedTab = idx
        moveIndicator(to: idx, animated: true)
        updateTabColors(selected: idx)
        runAction(for: idx)
    }

    private func moveIndicator(to idx: Int, animated: Bool) {
        let tabWidth = (tabBar.bounds.width) / CGFloat(tabButtons.count)
        let x = tabWidth * CGFloat(idx) + 6
        let w = tabWidth - 12

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                self.tabIndicator.frame = CGRect(x: x, y: 8, width: w, height: 48)
            }
        } else {
            tabIndicator.frame = CGRect(x: x, y: 8, width: w, height: 48)
        }
    }

    private func updateTabColors(selected idx: Int) {
        tabButtons.enumerated().forEach { i, btn in
            let isSelected = i == idx
            btn.subviews.first(where: { $0 is UIStackView })?.subviews.forEach { v in
                if let img = v as? UIImageView { img.tintColor  = isSelected ? DS.accent : DS.textMuted }
                if let lbl = v as? UILabel     { lbl.textColor  = isSelected ? DS.accent : DS.textMuted }
            }
        }
    }

    private func runAction(for idx: Int) {
        switch idx {
        case 0: callAPI(mode: .tailor)
        case 1: callAPI(mode: .coverLetter)
        case 2: callAPI(mode: .coldEmail)
        case 3: callAPI(mode: .review)
        default: break
        }
    }

    // MARK: - API Calls (Groq with Gemini Fallback)
    private func callAPI(mode: ActionMode) {
        view.endEditing(true)

        let resumeText = resumeCard.textView.text ?? ""
        let jobText    = jobCard.textView.text    ?? ""

        let resumeValid = !resumeText.isEmpty && resumeText != placeholderResume
        let jobValid    = !jobText.isEmpty    && jobText    != placeholderJob

        guard resumeValid, jobValid else {
            showAlert(title: "Missing Content",
                      message: "Please add both your resume and the job description before running analysis.")
            return
        }
//        setResultText("Auditing via Groq...", color: DS.textSecond)
        showLoader(true)
        var req = URLRequest(url: GroqConfig.url)
        req.httpMethod = "POST"
        req.addValue("Bearer \(GroqConfig.apiKey)", forHTTPHeaderField: "Authorization")
        req.addValue("application/json",            forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 60

        let body: [String: Any] = [
            "model": GroqConfig.model,
            "temperature": 0.4,
            "messages": [
                ["role": "system", "content": mode.systemPrompt],
                ["role": "user",   "content": "\(mode.userPrompt)\n\n---RESUME---\n\(resumeText)\n\n---JOB DESCRIPTION---\n\(jobText)"]
            ]
        ]

        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                // Check for specific Groq errors (Token limits or Network errors)
                let httpResponse = response as? HTTPURLResponse
                if error != nil || httpResponse?.statusCode == 429 || httpResponse?.statusCode == 503 {
                    print("Groq failed or limit hit. Switching to Gemini fallback...")
                    self.callGemini(mode: mode)
                    return
                }

                guard let data = data else {
                    self.callGemini(mode: mode)
                    return
                }

                guard
                    let json    = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let choices = json["choices"] as? [[String: Any]],
                    let message = choices.first?["message"] as? [String: Any],
                    let text    = message["content"] as? String
                else {
                    self.callGemini(mode: mode)
                    return
                }

                if text.contains("ERROR_INVALID_INPUT") {
                    self.showInvalidInputDialog()
                    self.setResultText("The Job Description provided is invalid.", color: DS.red)
                    return
                }

                if mode == .review {
                    self.parseReview(text)
                } else {
                    self.setResultText(text, color: DS.textPrimary)
                }
                self.animateResultReveal()
            }
        }.resume()
    }

    // MARK: - Gemini Fallback Call
    private func callGemini(mode: ActionMode) {
//        setResultText("Switching to Gemini Fallback...", color: DS.orange)
        
        let resumeText = resumeCard.textView.text ?? ""
        let jobText    = jobCard.textView.text    ?? ""
        
        guard let url = URL(string: "\(GroqConfig.geminiUrl)?key=\(GroqConfig.geminiApiKey)") else { return }
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let cleanUserPrompt = """
        ### TASK:
        \(mode.userPrompt)
        ### MY RESUME DATA:
        ---
        \(resumeText)
        ---
        ### TARGET JOB DESCRIPTION:
        ---
        \(jobText)
        ---
        """
        
        let body: [String: Any] = [
            "system_instruction": [
                "parts": [
                    ["text": mode.systemPrompt]
                ]
            ],
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": cleanUserPrompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.4,
                "topP": 0.8,
                "topK": 40,
                "maxOutputTokens": 2048
            ]
        ]
        
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: req) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    self.setResultText("❌ Both APIs failed: \(error.localizedDescription)", color: DS.red)
                    return
                }
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("DEBUG - Gemini Raw Response: \(responseString)")
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let candidates = json["candidates"] as? [[String: Any]],
                      let content = candidates.first?["content"] as? [String: Any],
                      let parts = content["parts"] as? [[String: Any]],
                      let text = parts.first?["text"] as? String else {
                    self.setResultText("❌ Critical: Gemini fallback failed.", color: DS.red)
                    return
                }
                
                if text.contains("ERROR_INVALID_INPUT") {
                    self.showInvalidInputDialog()
                    self.setResultText("The Job Description provided is invalid.", color: DS.red)
                    return
                }
                
                if mode == .review {
                    self.parseReview(text)
                } else {
                    self.setResultText(text, color: DS.textPrimary)
                }
                self.animateResultReveal()
            }
        }.resume()
    }

    // MARK: - Parse Elite Review
    private func parseReview(_ text: String) {
        if let r = text.range(of: #"(?<=SCORE: )\d+"#, options: .regularExpression) {
            let s = Int(String(text[r])) ?? 0
            scoreRing.score = s
            UIView.animate(withDuration: 0.15) {
                self.scoreRing.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            } completion: { _ in
                UIView.animate(withDuration: 0.25, delay: 0,
                               usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
                    self.scoreRing.transform = .identity
                }
            }
        }

        var sidebar = ""
        if let r = text.range(of: #"(?<=\[RED_FLAGS:\s)[\s\S]*?(?=\])"#, options: .regularExpression) {
            sidebar += "🚩 RED FLAGS\n\(String(text[r]).trimmingCharacters(in: .whitespacesAndNewlines))\n\n"
        }
        if let r = text.range(of: #"(?<=\[KEYWORDS:\s)[\s\S]*?(?=\])"#, options: .regularExpression) {
            sidebar += "🔍 MISSING SKILLS\n\(String(text[r]).trimmingCharacters(in: .whitespacesAndNewlines))"
        }
        flagsTextView.text      = sidebar.isEmpty ? "No critical issues detected." : sidebar
        flagsTextView.textColor = sidebar.isEmpty ? DS.green : DS.red
        
        if let r = text.range(of: #"(?<=\[REVIEW:\s)[\s\S]*?(?=\]|$)"#, options: .regularExpression) {
            setResultText(String(text[r]).trimmingCharacters(in: .whitespacesAndNewlines), color: DS.textPrimary)
        } else {
            setResultText(text, color: DS.textPrimary)
        }
    }

    private func setResultText(_ text: String, color: UIColor) {
        resultTextView.text      = text
        resultTextView.textColor = color
        self.showLoader(false)
    }

    private func animateResultReveal() {
        resultCard.alpha     = 0.6
        resultCard.transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(withDuration: 0.5, delay: 0,
                       usingSpringWithDamping: 0.75, initialSpringVelocity: 0.3) {
            self.resultCard.alpha     = 1
            self.resultCard.transform = .identity
        }
        scrollView.scrollRectToVisible(resultCard.frame, animated: true)
    }

    private func showLoader(_ show: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.loader.alpha = show ? 1 : 0
        }
        show ? loader.startAnimating() : loader.stopAnimating()
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default))
        present(alert, animated: true)
    }

    private func showInvalidInputDialog() {
        let alert = UIAlertController(
            title: "Invalid Job Description",
            message: "The text you entered doesn't look like a real job listing. Please paste a full job description to get an accurate AI analysis.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "I'll fix it", style: .default))
        self.present(alert, animated: true)
        self.scoreRing.score = 0
    }

    @objc private func copyResult() {
        guard let text = resultTextView.text, !text.isEmpty else { return }
        UIPasteboard.general.string = text
        copyBtn.setImage(UIImage(systemName: "checkmark"), for: .normal)
        copyBtn.tintColor = DS.green
        UIView.animate(withDuration: 0.2, delay: 1.5) {
            self.copyBtn.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
            self.copyBtn.tintColor = DS.textSecond
        }
    }

    @objc private func didTapUpload() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        picker.delegate = self
        present(picker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first, let pdf = PDFDocument(url: url) else { return }
        var fullText = ""
        for i in 0..<pdf.pageCount {
            fullText += pdf.page(at: i)?.string ?? ""
        }
        resumeCard.textView.text      = fullText
        resumeCard.textView.textColor = DS.textPrimary
        UIView.animate(withDuration: 0.2) { self.resumeCard.layer.borderColor = DS.green.cgColor }
        UIView.animate(withDuration: 0.4, delay: 0.8) { self.resumeCard.layer.borderColor = DS.border.cgColor }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == resumeCard.textView && textView.textColor == DS.textMuted {
            textView.text      = ""
            textView.textColor = DS.textPrimary
        }
        if textView == jobCard.textView && textView.textColor == DS.textMuted {
            textView.text      = ""
            textView.textColor = DS.textPrimary
        }
        let card = textView == resumeCard.textView ? resumeCard : jobCard
        card?.highlight(true)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == resumeCard.textView && textView.text.isEmpty {
            textView.text      = placeholderResume
            textView.textColor = DS.textMuted
        }
        if textView == jobCard.textView && textView.text.isEmpty {
            textView.text      = placeholderJob
            textView.textColor = DS.textMuted
        }
        let card = textView == resumeCard.textView ? resumeCard : jobCard
        card?.highlight(false)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

