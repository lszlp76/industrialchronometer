//
//  LapListCellTableViewCell.swift
//  industrialchronometer
//
//  Created by ulas özalp on 15.02.2022.
//  Updated for Precision Formatting
//

import UIKit

class LapListCellTableViewCell: UITableViewCell {

    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    @IBOutlet weak var themeSegment: UISegmentedControl!
    // YENİ OUTLETLER
    @IBOutlet weak var precisionSlider: UISlider!
   
    @IBOutlet weak var precisionLabel: UILabel!
    
    var onSliderChange: ((Int) -> Void)?
    // YENİ: Tema değişince Controller'a haber verecek closure
        var onThemeChange: ((Int) -> Void)?
    override func awakeFromNib() {
            super.awakeFromNib()
            
            let fontAttribute = [NSAttributedString.Key.font: AppTheme.Font.robotex(size: 14)]
            themeSegment.setTitleTextAttributes(fontAttribute, for: .normal)
            
            // Segmentleri Ayarla
            themeSegment.removeAllSegments() // Eskileri temizle
            themeSegment.insertSegment(withTitle: "Dark", at: 0, animated: false)
            themeSegment.insertSegment(withTitle: "Light", at: 1, animated: false)
            themeSegment.insertSegment(withTitle: "System", at: 2, animated: false) // YENİ
        // 2. Renkleri ve Fontu Ayarla (İlk açılış)
                updateSegmentStyle()
                
                // 3. Tema Değişikliğini Dinle (Anlık değişim için)
                NotificationCenter.default.addObserver(self, selector: #selector(updateSegmentStyle), name: .themeChanged, object: nil)
        }
    // SİSTEM TEMASI DEĞİŞİKLİĞİNİ YAKALA
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            
            // Eğer sistem teması değiştiyse ve biz 'System' modundaysak veya renklerimiz dinamikse:
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                // Segmentin stilini zorla güncelle
                updateSegmentStyle()
            }
        }
    // --- YENİ: SEGMENT AKSİYONU ---
        @IBAction func themeSegmentChanged(_ sender: UISegmentedControl) {
            // Seçilen index'i (0 veya 1) gönder
            onThemeChange?(sender.selectedSegmentIndex)
        }
    // MARK: - Stil Güncelleme (YENİ)
    @objc func updateSegmentStyle() {
            let font = AppTheme.Font.robotex(size: 14)
            
            // Renkleri o anki aktif temaya (AppTheme.currentTheme) göre al
            let mainColor = AppTheme.Color.mainText
          
        icon.tintColor = AppTheme.Color.iconTint
        icon.image = icon.image?.withRenderingMode(.alwaysTemplate)
            // Normal (Seçili Olmayan): Biraz şeffaf
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: mainColor.withAlphaComponent(0.6)
                
            ]
            
            // Seçili Olan: Tam renk
            let selectedAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: mainColor
            ]
            
            themeSegment.setTitleTextAttributes(normalAttributes, for: .normal)
            themeSegment.setTitleTextAttributes(selectedAttributes, for: .selected)
            
            // Çerçeve rengini de güncelle
            themeSegment.layer.borderColor = mainColor.withAlphaComponent(0.2).cgColor
            themeSegment.layer.borderWidth = 1.0
            
            // Değişikliği hemen yansıt
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }
    
    // Slider değişince çalışacak fonksiyon
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let value = Int(round(sender.value))
        sender.value = Float(value) // Slider'ı tam sayıya oturt (Snap effect)
        
        // İstenilen formatta gösterim
        updatePrecisionLabel(for: value)
        
        // Değeri Controller'a bildir
        onSliderChange?(value)
    }
    
    // Yardımcı Fonksiyon: Label Metnini Ayarlar
    func updatePrecisionLabel(for value: Int) {
        switch value {
        case 0: precisionLabel.text = "#"        // 0 Basamak (Tam sayı)
        case 1: precisionLabel.text = "#.#"      // 1 Basamak
        case 2: precisionLabel.text = "#.##"     // 2 Basamak
        case 3: precisionLabel.text = "#.###"    // 3 Basamak
        default: precisionLabel.text = "#.##"
        }
    }
}
