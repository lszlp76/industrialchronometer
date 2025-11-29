//
//  Extension.swift
//  industrialchronometer
//
//  Created by ulas özalp on 29.11.2025.
//



import UIKit

extension UIAlertController {
    
    // Alert'i Temaya Uygun Hale Getir
    func applyAppTheme() {
        
        // 1. Arka Plan Modunu Zorla
        // AppTheme.currentTheme .dark ise arayüzü .dark yap (Koyu gri zemin), yoksa .light (Beyaz zemin)
        self.overrideUserInterfaceStyle = (AppTheme.currentTheme == .dark) ? .dark : .light
        
        let titleColor = AppTheme.Color.mainText
        let messageColor = AppTheme.Color.dialogText
        let accentColor = AppTheme.Color.accent // Butonlar için
        
        // 2. Başlık Rengi ve Fontu
        if let title = self.title {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: titleColor,
                .font: AppTheme.Font.digitalBold(size: 20) // Sizin fontunuz
            ]
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            self.setValue(attributedTitle, forKey: "attributedTitle")
        }
        
        // 3. Mesaj Rengi ve Fontu
        if let message = self.message {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: messageColor,
                .font: AppTheme.Font.robotex(size: 16)
            ]
            let attributedMessage = NSAttributedString(string: message, attributes: attributes)
            self.setValue(attributedMessage, forKey: "attributedMessage")
        }
        
        // 4. Buton (Action) Renkleri
        // Alert'in genel tint rengini değiştirirsek standart butonlar değişir
        self.view.tintColor = accentColor
        
        // Ancak 'Destructive' (Sil) veya özel butonların rengini tek tek ayarlamak için:
        for action in self.actions {
            // Cancel butonu veya Default butonlar için renk ataması
            // KVC (Key-Value Coding) kullanarak rengi zorluyoruz
            if action.style == .destructive {
                action.setValue(UIColor.systemRed, forKey: "titleTextColor")
            } else {
                action.setValue(titleColor, forKey: "titleTextColor")
            }
        }
    }
}
