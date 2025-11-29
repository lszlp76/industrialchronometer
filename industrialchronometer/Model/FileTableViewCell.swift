//
//  FileTableViewCell.swift
//  industrialchronometer
//
//  Created by ulas özalp on 24.11.2025.
//

import UIKit

class FileTableViewCell: UITableViewCell {

    // Storyboard'dan bağlanacak elemanlar
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    // Tıklama olaylarını ViewController'a iletmek için "Closure" kullanıyoruz
    var onShareTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    
    override func awakeFromNib() {
            super.awakeFromNib()
            
            // 1. İlk açılışta renkleri ayarla
            updateColors()
            
            // 2. Tema değişikliğini dinle (Sistem veya uygulama içi değişiklik)
            NotificationCenter.default.addObserver(self, selector: #selector(updateColors), name: .themeChanged, object: nil)
            
            // Tıklama efektini kapat
            self.selectionStyle = .none
            
            // Arka planı temizle (Alttaki ana arka plan resmi görünsün)
            self.backgroundColor = .clear
            self.contentView.backgroundColor = .clear
        }
        
        // Deinit: Hücre hafızadan silinirken gözlemciyi kaldır
        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        // RENK GÜNCELLEME FONKSİYONU
        @objc func updateColors() {
            // AppTheme.Color.tableCellText -> Dark modda Krem/Beyaz, Light modda Lacivert/Siyah döner.
            // Bu sayede her zaman zıt kontrast oluşur.
            fileNameLabel.textColor = AppTheme.Color.tableCellText
            
            // Font ayarı (İstersen)
            fileNameLabel.font = AppTheme.Font.robotex(size: 18.0)
            shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
            shareButton.tintColor = .systemBlue
            
            deleteButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
            deleteButton.tintColor = .systemRed
            
            // Buton renkleri
            shareButton.tintColor = AppTheme.Color.iconTint
            deleteButton.tintColor = .systemRed
        }

    @IBAction func shareButtonAction(_ sender: Any) {
        onShareTapped?()
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        onDeleteTapped?()
    }
    // Sistem teması değiştiğinde de tetiklenmesi için
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                updateColors()
            }
        }
  
}
