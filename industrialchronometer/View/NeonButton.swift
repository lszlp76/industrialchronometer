//
//  NeonButton.swift
//  IndustrialChronometer
//
//  Created by Ulas Ozalp on 23.11.2025.
//

import UIKit

@IBDesignable
class NeonButton: UIControl{
    // MARK: - Public Properties
    
    // Butonun ana tema rengi (Storyboard'dan ayarlanabilir)
    @IBInspectable var themeColor: UIColor = .cyan {
        didSet { updateColors() }
    }
    
    // Buton üzerindeki metin (Storyboard'dan ayarlanabilir)
    @IBInspectable var title: String = "BUTTON" {
        didSet { titleLabel.text = title }
    }
    
    // MARK: - UI Elements
    
    // Metin etiketi
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold) // Veya özel fontun
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Metne parlaklık (glow) efekti
        label.layer.shadowColor = UIColor.white.cgColor
        label.layer.shadowOffset = .zero
        label.layer.shadowRadius = 8
        label.layer.shadowOpacity = 0.8
        return label
    }()
    
    // MARK: - Layers (Katmanlar)
    
    // 1. En dıştaki neon parlaması (Glow Shadow)
    private let outerGlowLayer = CALayer()
    
    // 2. Ana şekil ve kenarlık (Border & Base Shape)
    private let borderLayer = CAShapeLayer()
    
    // 3. İçteki dikey gradyan dolgusu (Gradient Fill)
    private let gradientFillLayer = CAGradientLayer()
    
    // 4. Üst kısımdaki parlak cam vurgusu (Top Highlight)
    private let topHighlightLayer = CAGradientLayer()
    
    // 5. Ortadaki mercek parlaması (Lens Flare - Görsel gerektirir)
    private let lensFlareLayer = CALayer()
    
    // MARK: - Initialization
    
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
        layer.masksToBounds = false // Gölgelerin dışarı taşması için
        
        // Katmanları sırayla ekle (Alttan üste doğru)
        layer.addSublayer(outerGlowLayer)
        layer.addSublayer(borderLayer)
        borderLayer.addSublayer(gradientFillLayer) // Dolguyu kenarlığın içine maskele
        borderLayer.addSublayer(topHighlightLayer)
        layer.addSublayer(lensFlareLayer)
        
        // Metin etiketini ekle
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Katmanların temel ayarları
        configureLayers()
        
        // Başlangıç renklerini uygula
        updateColors()
    }
    
    private func configureLayers() {
        // 1. Outer Glow (Dış Parlama)
        outerGlowLayer.backgroundColor = UIColor.clear.cgColor
        outerGlowLayer.shadowOffset = .zero
        outerGlowLayer.shadowOpacity = 0.6
        outerGlowLayer.shadowRadius = 15 // Geniş bir yayılım
        
        // 2. Border Layer (Kenarlık)
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 3.0
        borderLayer.shadowColor = UIColor.white.cgColor // Kenarlığın hemen dibindeki ince parlama
        borderLayer.shadowOffset = .zero
        borderLayer.shadowOpacity = 0.9
        borderLayer.shadowRadius = 3
        borderLayer.masksToBounds = true // İçindeki gradyanları şekle göre kes
        
        // 3. Gradient Fill (İç Dolgu)
        gradientFillLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientFillLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        // 4. Top Highlight (Üst Vurgu)
        // Üstten aşağıya doğru incelen beyazımsı bir parlama
        topHighlightLayer.colors = [
            UIColor.white.withAlphaComponent(0.4).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        topHighlightLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        topHighlightLayer.endPoint = CGPoint(x: 0.5, y: 0.4) // Sadece üst kısımda kalsın
        
        // 5. Lens Flare (Mercek Parlaması)
        // Assets klasörüne "lensFlare" adında bir görsel eklemelisiniz.
        if let flareImage = UIImage(named: "lensFlare") {
            lensFlareLayer.contents = flareImage.cgImage
            lensFlareLayer.contentsGravity = .center
            lensFlareLayer.opacity = 0.8 // Biraz şeffaf
            // Görselin rengini tema rengiyle değiştirmek için (Opsiyonel):
            // lensFlareLayer.filters = [CIFilter(name: "CIMultiplyCompositing")!]
            // lensFlareLayer.backgroundColor = themeColor.cgColor
        }
    }
    
    // MARK: - Layout & Drawing
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cornerRadius = bounds.height / 5 // Yüksekliğe göre dinamik köşe yuvarlama
        let roundedPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        
        // Tüm katmanların çerçevelerini ve yollarını güncelle
        
        // 1. Outer Glow
        outerGlowLayer.frame = bounds
        // Gölge için dolu bir yol gerekiyor
        outerGlowLayer.shadowPath = roundedPath
        
        // 2. Border Layer
        borderLayer.frame = bounds
        borderLayer.path = roundedPath
        borderLayer.cornerRadius = cornerRadius
        
        // 3. Gradient Fill
        gradientFillLayer.frame = bounds
        
        // 4. Top Highlight
        topHighlightLayer.frame = bounds
        
        // 5. Lens Flare
        // Ortaya hizala ve biraz daha geniş tut
        let flareHeight = bounds.height * 1.5
        let flareWidth = bounds.width * 1.2
        lensFlareLayer.frame = CGRect(
            x: (bounds.width - flareWidth) / 2,
            y: (bounds.height - flareHeight) / 2,
            width: flareWidth,
            height: flareHeight
        )
    }
    
    // MARK: - Color Updates
    
    private func updateColors() {
        // Ana tema rengini tüm katmanlara uygula
        
        // 1. Dış Parlama Rengi
        outerGlowLayer.shadowColor = themeColor.cgColor
        
        // 2. Kenarlık Rengi
        borderLayer.strokeColor = themeColor.withAlphaComponent(0.8).cgColor
        
        // 3. İç Gradyan Renkleri (Yukarıdan aşağıya: Renkli -> Şeffaf)
        gradientFillLayer.colors = [
            themeColor.withAlphaComponent(0.3).cgColor, // Üst: Hafif renkli
            themeColor.withAlphaComponent(0.05).cgColor // Alt: Neredeyse şeffaf
        ]
        
        // Metin parlama rengini de hafifçe tema rengine çekebiliriz
        titleLabel.layer.shadowColor = themeColor.withAlphaComponent(0.5).cgColor
    }
    
    // MARK: - Touch Handling (Dokunma Efekti)
    
    override var isHighlighted: Bool {
        didSet {
            // Basıldığında hafifçe küçül ve ışıkları kıs
            UIView.animate(withDuration: 0.1) {
                let scale: CGFloat = self.isHighlighted ? 0.97 : 1.0
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
                
                // Parlaklıkları azalt
                self.outerGlowLayer.shadowOpacity = self.isHighlighted ? 0.3 : 0.6
                self.borderLayer.shadowOpacity = self.isHighlighted ? 0.5 : 0.9
                self.lensFlareLayer.opacity = self.isHighlighted ? 0.4 : 0.8
            }
        }
    }
}
