//
//  GlassButton.swift
//  industrialchronometer
//
//  Created by ulas özalp on 23.11.2025.
//

import UIKit

class GlassButton: UIButton {
    
    // Arka plandaki "Buzlu Cam" katmanı
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGlass()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGlass()
    }
    
    private func setupGlass() {
        // 1. Butonun Kendisi (Gölge İçin)
        backgroundColor = .clear
        layer.shadowColor = UIColor.blue.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false // Gölgenin dışarı taşmasına izin ver
        
        // 2. Blur Katmanı (Cam Efekti)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false // Dokunmayı engellemesin
        
        // Köşeler ve Kenarlık
        blurView.layer.cornerRadius = 12
        blurView.layer.cornerCurve = .continuous
        blurView.clipsToBounds = true
        
        // İnce Beyaz Kenarlık (Cam Parlaması)
        blurView.layer.borderWidth = 0.5
        blurView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        
        // Blur'u en arkaya ekle
        insertSubview(blurView, at: 0)
        
        // 3. Yazı Ayarları
        setTitleColor(.white, for: .normal)
        setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .disabled)
        titleLabel?.font = AppTheme.Font.digitalBold(size: 20)
    }
    
    // Butona basıldığında hafifçe küçülme efekti
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 1) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
                self.blurView.alpha = self.isHighlighted ? 0.7 : 1.0
            }
        }
    }
}
