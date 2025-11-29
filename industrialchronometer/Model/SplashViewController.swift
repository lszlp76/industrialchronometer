//
//  SplashViewController.swift
//  industrialchronometer
//
//  Created by ulas özalp on 22.11.2025.
//

import UIKit

class SplashViewController: UIViewController {

    // MARK: - Outlets
    // Storyboard'dan bu resimleri bağlamayı unutma!
    @IBOutlet weak var fgImage1: UIImageView! // Öndeki Logo
    @IBOutlet weak var fgImage2: UIImageView! // Öndeki yazı
    @IBOutlet weak var bgImage3: UIImageView! // Arkadaki Background Resmi
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black // Endüstriyel siyah zemin
        
        setupInitialState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Ekran göründükten çok kısa bir süre sonra animasyonu başlat
        startCinematicAnimation()
    }
    
    // MARK: - Animation Logic
    
    private func setupInitialState() {
        // 1. ve 2. Resimler (Öndekiler):
        // Başlangıçta normal boyutlarında (Scale 1.0) ve görünürler.
        // Ekranın "içinde" duruyorlar.
        fgImage1.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        fgImage1.alpha = 0.3
        
        fgImage2.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        fgImage2.alpha = 0.3
        
        // 3. Resim (Background):
        // Başlangıçta "dışarıda" olmalı. Bunu simüle etmek için onu çok büyük başlatıyoruz (Zoom In yapılmış gibi).
        // Ve görünmez başlatıyoruz ki animasyonla "içeri" girsin.
        bgImage3.transform = CGAffineTransform(scaleX: 3.0, y: 3.0) // Çok büyük (ekran dışı)
        bgImage3.alpha = 0.1
    }
    
    private func startCinematicAnimation() {
        // Animasyon Süresi: 2.0 Saniye
        UIView.animate(withDuration: 2.0,
                       delay: 0.2,
                       options: [.curveEaseInOut], // Yumuşak hızlanma ve yavaşlama
                       animations: {
            
            // --- A) İÇERİDEN DIŞARIYA ÇIKMA EFEKTİ ---
            // Resim 1 ve 2'yi kullanıcıya doğru fırlatıyoruz (Büyütüp yok ediyoruz)
            
            // Resim 1: 5 kat büyüsün, hafif dönsün ve şeffaflaşsın
            let scaleTrans1 = CGAffineTransform(scaleX: 1.0, y: 1.0)
        //    let rotateTrans1 = CGAffineTransform(rotationAngle: CGFloat.pi) // 45 derece döndür
            self.fgImage1.transform = scaleTrans1//.concatenating(rotateTrans1)
            self.fgImage1.alpha = 1.0
            
            // Resim 2: 5 kat büyüsün, ters yöne dönsün ve şeffaflaşsın
            let scaleTrans2 = CGAffineTransform(scaleX: 1.0, y: 1.0) // Biraz daha hızlı büyüsün
            //let rotateTrans2 = CGAffineTransform(rotationAngle: -CGFloat.pi / 4) // Ters yöne döndür
            self.fgImage2.transform = scaleTrans2//concatenating(rotateTrans2)
            self.fgImage2.alpha = 1.0
            
            // --- B) DIŞARIDAN İÇERİYE GİRME EFEKTİ ---
            // Background resmi çok büyüktü, şimdi normal boyutuna iniyor ve belirginleşiyor
            
            self.bgImage3.transform = .identity // Normal boyutuna (1.0) dön
            self.bgImage3.alpha = 1.0 // Görünür ol
            
        }) { _ in
            // Animasyon bittiğinde ana uygulamaya geç
            self.navigateToMainApp()
        }
    }
    
    private func navigateToMainApp() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        // Navigation Controller ID'sinin "MainNavigationController" olduğundan emin ol
        if let mainNav = sb.instantiateViewController(withIdentifier: "MainNavigationController") as? UINavigationController {
            
            mainNav.modalTransitionStyle = .crossDissolve
            mainNav.modalPresentationStyle = .fullScreen
            
            if let windowScene = view.window?.windowScene,
               let delegate = view.window?.windowScene?.delegate as? SceneDelegate,
               let window = delegate.window {
                window.rootViewController = mainNav
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
            } else {
                self.present(mainNav, animated: true)
            }
        } else {
            print("HATA: 'MainNavigationController' bulunamadı.")
        }
    }
}
