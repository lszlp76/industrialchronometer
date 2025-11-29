//
//  AppTheme.swift
//  industrialchronometer
//
//  Created by ulas özalp on 16.11.2025.
//

import UIKit

extension Notification.Name {
    static let themeChanged = Notification.Name("themeChanged")
}

struct AppTheme {
    
    // YENİ RENK PALETİ
    struct Palette {
        // Gece Mavisi (Midnight Blue) - Light Modda Yazı Rengi
        static let nightBlue = UIColor(red: 0.10, green: 0.10, blue: 0.44, alpha: 1.00) // #191970
        
        // Krem Beyazı (Cream White) - Dark Modda Yazı Rengi
        static let creamWhite = UIColor(red: 0.96, green: 0.96, blue: 0.86, alpha: 1.00) // #F5F5DC
        static let borderColor = UIColor(.cyan)
        
        static let parliamentBlue: UIColor = UIColor(named: "Color") ?? UIColor(red: 55/255, green: 145/255, blue: 240/255, alpha: 1.0)
        // Vurgu Rengi (Mavi)
        static let accentBlue = UIColor(red: 56/255, green: 146/255, blue: 241/255, alpha: 1.00)
    }

    struct Color {
        static let accent = Palette.accentBlue
        static let colorBorder = UIColor(named: "Color") ?? UIColor(red: 55/255, green: 145/255, blue: 240/255, alpha: 1.0)//UIColor(red: 0.218, green: 0.572, blue: 0.945, alpha: 1.00)
        static let colorNavbar = UIColor(named: "Color") ?? UIColor(red: 55/255, green: 145/255, blue: 240/255, alpha: 1.0)
        static let disabledBackground = UIColor(red: 0.77, green: 0.87, blue: 0.96, alpha: 1.00)
        static let systemBackground = UIColor.clear // Arka planlar artık resim olduğu için clear
        
        static let tableRowOdd = UIColor(named: "ColorForLapTableView0")
        static let tableRowEven = UIColor(named: "ColorForLapTableView1")
        
        // --- DİNAMİK RENKLER ---
        
        // Ana Metin: Dark Mod -> Krem Beyaz, Light Mod -> Gece Mavisi
        static var mainText: UIColor {
            return AppTheme.currentTheme == .dark ? Palette.creamWhite : Palette.nightBlue
        }
        
        // Diyalog / Alt Metinler
        static var dialogText: UIColor {
            return AppTheme.currentTheme == .dark ? Palette.creamWhite : Palette.nightBlue
        }
        
        // Tablo Hücre Metni
        static var tableCellText: UIColor {
            return AppTheme.currentTheme == .dark ? Palette.creamWhite : Palette.nightBlue
        }
        
        // İkon Rengi (Tint)
        static var iconTint: UIColor {
            return AppTheme.currentTheme == .dark ? Palette.creamWhite : Palette.nightBlue
        }
    }
    
    struct Font {
        static func robotex(size: CGFloat) -> UIFont {
            return UIFont(name: "Roboto-Regular", size: size) ?? .systemFont(ofSize: size)
        }
        static func digitalBold(size: CGFloat) -> UIFont {
            return UIFont(name: "DS-Digital-Bold", size: size) ?? .systemFont(ofSize: size, weight: .bold)
        }
        static func digital(size: CGFloat) -> UIFont {
            return UIFont(name: "DS-Digital", size: size) ?? .systemFont(ofSize: size, weight: .bold)
        }
        // --- YENİ EKLENEN KISIM: TİTREMEYEN SAYAÇ FONTU ---
            // Bu fonksiyon, rakam genişlikleri sabitlenmiş özel bir sistem fontu döndürür.
         static func timerFont(size: CGFloat) -> UIFont {
                // "monospacedDigitSystemFont" rakamların genişliğini eşitler (1 ve 8 aynı yer kaplar)
                return UIFont.monospacedDigitSystemFont(ofSize: size, weight: .bold)
            }
    }
   
    // 1. Tema Seçenekleri (Güncellendi)
        enum ThemeType: Int {
            case dark = 0
            case light = 1
            case system = 2 // YENİ
        }
        
        // 2. Kullanıcının Seçimi (Kaydedilen)
        static var selectedTheme: ThemeType {
            get {
                let saved = UserDefaults.standard.integer(forKey: "SelectedTheme")
                // Varsayılan olarak 'System' (2) olsun
                return ThemeType(rawValue: saved) ?? .system
            }
            set {
                UserDefaults.standard.set(newValue.rawValue, forKey: "SelectedTheme")
                NotificationCenter.default.post(name: .themeChanged, object: nil)
            }
        }
        
        // 3. O Anki Aktif Tema (Hesaplanan)
        // Eğer 'System' seçiliyse, iOS'in o anki moduna bakarak karar verir.
        static var currentTheme: ThemeType {
            if selectedTheme == .system {
                // Sistemin o anki modu ne?
                // (Not: UIWindowScene iOS 13+ gerektirir, projeniz uygun)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    return window.traitCollection.userInterfaceStyle == .dark ? .dark : .light
                }
                return .dark // Fallback
            }
            return selectedTheme
        }
        
        // Arka Plan Resmi (currentTheme'e göre karar verir)
        static var backgroundImage: UIImage? {
            switch currentTheme {
            case .dark: return UIImage(named: "bg_dark")
            case .light: return UIImage(named: "bg_light")
            default: return UIImage(named: "bg_dark")
            }
        }
    }
//
//  ThemedLabel.swift
//  industrialchronometer
//
//  Created by ulas özalp on 24.11.2025.
//

//
//  ThemedLabel.swift
//  industrialchronometer
//
//  Created by ulas özalp on 24.11.2025.
//  Updated for Neon Border Effect
//

import UIKit

@IBDesignable
class ThemedLabel: UILabel {

    // Storyboard'dan açıp kapatabileceğin özellik
    @IBInspectable var isNeon: Bool = false {
        didSet {
            updateColor() // Kodla değiştirilirse anında güncelle
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 1. İlk açılışta rengi ve efekti ayarla
        updateColor()
        
        // 2. Tema değişikliğini dinle
        NotificationCenter.default.addObserver(self, selector: #selector(updateColor), name: .themeChanged, object: nil)
    }
    
    @objc func updateColor() {
        // Renkleri al
        let mainColor = AppTheme.Color.mainText
        
        // Animasyonlu geçiş
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
            // 1. Yazı Rengi
            self.textColor = mainColor
            
            // 2. Neon Efekti (Eğer açıksa)
            if self.isNeon {
                self.layer.borderColor = mainColor.cgColor
                self.layer.borderWidth = 2.0
                self.layer.cornerRadius = 8.0 // Hafif yumuşak köşe
                
                // Glow (Parlama) Efekti - Gölgeyi kullanarak yapıyoruz
                self.layer.shadowColor = mainColor.cgColor
                self.layer.shadowOffset = .zero // Gölge tam ortada olsun (her yöne parlasın)
                self.layer.shadowRadius = 10.0 // Parlama genişliği
                self.layer.shadowOpacity = 0.8 // Parlama şiddeti
                
                // Parlamanın dışarı taşması için maskelemeyi kapat
                self.layer.masksToBounds = false
            } else {
                // Neon kapalıysa efektleri temizle
                self.layer.borderWidth = 0
                self.layer.shadowOpacity = 0
            }
            
        }, completion: nil)
    }
    
    // Interface Builder'da (Storyboard) anlık önizleme için
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateColor()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
