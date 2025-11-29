//
//  NeonGlassButton.swift
//  industrialchronometer
//
//  Created by ulas özalp on 24.11.2025.
//

//
//  NeonGlassButton.swift
//  industrialchronometer
//
//  Created by ulas özalp on 24.11.2025.
//

import UIKit

@IBDesignable
class NeonGlassButton: UIButton {
    
    // MARK: - Properties
    
    // Neon Rengi (Storyboard'dan değiştirilebilir)
    @IBInspectable var glowColor: UIColor = AppTheme.Palette.parliamentBlue{
        didSet { updateEffects() }
    }
    
    // MARK: - Components
    
    // 1. Cam Efekti (GlassButton'dan alındı)
    private let blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        view.isUserInteractionEnabled = false
        view.clipsToBounds = true
        return view
    }()
    
    // 2. Dış Parlama Katmanı (NeonButton'dan alındı)
    private let outerGlowLayer = CALayer()
    
    // 3. Kenarlık Katmanı
    private let borderLayer = CAShapeLayer()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .clear
        layer.masksToBounds = false // Parlamanın dışarı taşması için şart
        
        // A. Dış Parlamayı en alta ekle
        layer.addSublayer(outerGlowLayer)
        
        // B. Cam Efektini ekle
        addSubview(blurView)
        
        // C. Kenarlık Katmanını en üste ekle
        layer.addSublayer(borderLayer)
        
        // D. Yazı Ayarları
        setTitleColor(.white, for: .normal)
        titleLabel?.font = AppTheme.Font.robotex(size: 22) // Senin fontun
        
        // Başlangıç Ayarları
        configureLayers()
        updateEffects()
    }
    
    private func configureLayers() {
        // Dış Parlama Ayarları
        outerGlowLayer.shadowOffset = .zero
        outerGlowLayer.shadowOpacity = 0.8
        outerGlowLayer.shadowRadius = 15
        
        // Kenarlık Ayarları
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 2.0
        borderLayer.shadowOffset = .zero
        borderLayer.shadowOpacity = 1.0
        borderLayer.shadowRadius = 4
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Yuvarlak köşeler
        let cornerRadius: CGFloat = 12
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        
        // 1. Cam Efekti Çerçevesi
        blurView.frame = bounds
        blurView.layer.cornerRadius = cornerRadius
        
        // 2. Parlama Çerçevesi
        outerGlowLayer.frame = bounds
        outerGlowLayer.shadowPath = path
        
        // 3. Kenarlık Çerçevesi
        borderLayer.frame = bounds
        borderLayer.path = path
        
        // Camın arkaya atılması (Yazının arkasında kalsın)
        sendSubviewToBack(blurView)
    }
    
    // MARK: - Updates
    
    private func updateEffects() {
        // Rengi tüm katmanlara dağıt
        outerGlowLayer.shadowColor = glowColor.cgColor
        borderLayer.strokeColor = glowColor.withAlphaComponent(0.6).cgColor
        borderLayer.shadowColor = glowColor.cgColor
        
        // Yazıya da hafif gölge ver
        setTitleColor(glowColor, for: .highlighted)
        titleLabel?.layer.shadowColor = UIColor(.white) as! CGColor
        titleLabel?.layer.shadowOffset = .zero
        titleLabel?.layer.shadowRadius = 5
        titleLabel?.layer.shadowOpacity = 0.5
    }
    
    // MARK: - Animation
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                // Basılınca küçül
                let scale: CGFloat = self.isHighlighted ? 0.95 : 1.0
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
                
                // Basılınca cam matlaşsın, parlama azalsın
                self.blurView.alpha = self.isHighlighted ? 0.6 : 1.0
                self.outerGlowLayer.shadowOpacity = self.isHighlighted ? 0.4 : 0.8
            }
        }
    }
}
