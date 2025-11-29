//
//  PageViewController.swift
//  industrialchronometer
//
//  Created by ulas özalp on 3.02.2022.
//  Refactored for MVVM & Navigation
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // ImageView'a sonradan erişmek için değişken yapıyoruz
        private var backgroundImageView: UIImageView?
    
    // MARK: - Sayfa Listesi
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.getChronometerPage(),
                self.getChartPage(),
                self.getFileListPage()]
    }()
    
    // MARK: - Sayfa Oluşturucular
    
    private func getChronometerPage() -> UIViewController {
        let sb = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // 1. Yöntem: ID ile dene
        if let chronoVC = sb.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            return chronoVC
        }
        
        // 2. Yöntem: Initial VC olarak dene
        if let initialVC = sb.instantiateInitialViewController() as? ViewController {
            return initialVC
        }
        
        fatalError("❌ KRİTİK HATA: Main.storyboard içinde 'ViewController' bulunamadı.")
    }
    
    private func getChartPage() -> UIViewController {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let chartVC = sb.instantiateViewController(withIdentifier: "ChartUIViewController") as? ChartUIViewController else {
            return UIViewController()
        }
        // Not: Veri bağlama işini viewDidLoad içinde yapıyoruz.
        return chartVC
    }
    
    private func getFileListPage() -> UIViewController {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        return sb.instantiateViewController(withIdentifier: "FileListViewController")
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
        setupCommonBackground()
        
        // 2. NAVIGATION BAR'I ŞEFFAF YAP (YENİ EKLENEN KISIM)
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground() // Arka planı şeffaf yapar
                appearance.backgroundColor = .clear // Rengi temizler
                appearance.shadowColor = .clear // Altındaki gölge çizgisini kaldırır
                
                // Başlık Rengi (Görünmesi için zıt renk seçin, örn: .white veya temanızdaki bir renk)
        appearance.titleTextAttributes = [.foregroundColor: AppTheme.Color.mainText ?? .label]
                
                // Ayarları uygula
                navigationController?.navigationBar.standardAppearance = appearance
                navigationController?.navigationBar.scrollEdgeAppearance = appearance
                navigationController?.navigationBar.compactAppearance = appearance
                
                // Buton ikonlarının rengini ayarla
                navigationController?.navigationBar.tintColor = UIColor(named: "mainText") ?? .label
        
            dataSource = self
            delegate = self
            
            // İlk açılışta butonları ve başlığı ayarla (Index 0)
            updateNavBar(for: 0)
            
            if let firstVC = orderedViewControllers.first {
                setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
            }
            
            // Veri Bağlantısı
            if let chronoVC = orderedViewControllers[0] as? ViewController,
               let chartVC = orderedViewControllers[1] as? ChartUIViewController {
                chartVC.viewModel = chronoVC.viewModel
            }
        // GÖZLEMCİ EKLE: Tema değişirse 'updateTheme' fonksiyonunu çalıştır
                NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: .themeChanged, object: nil)
        }
    
    // Sistem teması değiştiğinde iOS bu fonksiyonu çağırır
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            
            // Eğer kullanıcı "System" seçeneğini kullanıyorsa güncelleme yap
            if AppTheme.selectedTheme == .system {
                // Sistem modu değişmiş mi kontrol et
                if self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                    // Uygulamaya "Tema değişti" haberi sal
                    NotificationCenter.default.post(name: .themeChanged, object: nil)
                }
            }
        }
   
    // MARK: - Navigation Bar Yönetimi
        
        private func updateNavBar(for index: Int) {
            // 1. Başlığı Güncelle
            switch index {
            case 0: self.title = "Chronometer"
            case 1: self.title = "Cycle Time Chart"
            case 2: self.title = "Saved Observations"
            default: self.title = "Chronometer"
            }
            
            // 2. Butonları Temizle (Eskiler kalmasın)
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
            
            // 3. Butonları Oluştur (Özel Yardımcı Fonksiyon ile)
            if index == 1 {
                // --- GRAFİK SAYFASI (Index 1) ---
                
                // SOL: Geri (Chevron) - Şeffaf
                let backItem = createTransparentItem(
                    iconName: "chevron.left",
                    isSystemIcon: true,
                    target: self,
                    action: #selector(goToMainPage)
                )
                self.navigationItem.leftBarButtonItem = backItem
                
                // SAĞ: Kamera - Şeffaf
                let chartPage = orderedViewControllers[1]
                let cameraItem = createTransparentItem(
                    iconName: "camera.fill",
                    isSystemIcon: true,
                    target: chartPage,
                    action: Selector("saveChartToGallery")
                )
                self.navigationItem.rightBarButtonItem = cameraItem
                
            } else {
                // --- DİĞER SAYFALAR (Index 0 ve 2) ---
                
                // SOL: Menü - Şeffaf
                let menuItem = createTransparentItem(
                    iconName: "menu", // Assets'teki resim adı
                    isSystemIcon: false,
                    target: self,
                    action: #selector(callSettingsMenu)
                )
                self.navigationItem.leftBarButtonItem = menuItem
                
                // SAĞ: Saat - Şeffaf
                let cycleItem = createTransparentItem(
                    iconName: "clock",
                    isSystemIcon: true,
                    target: self,
                    action: #selector(cyclePages)
                )
                self.navigationItem.rightBarButtonItem = cycleItem
            }
        }
        
        // MARK: - Helper: Şeffaf Buton Oluşturucu
        
        /// Arka planı kesinlikle şeffaf olan bir UIBarButtonItem oluşturur.
        private func createTransparentItem(iconName: String, isSystemIcon: Bool, target: Any, action: Selector) -> UIBarButtonItem {
            
            // 1. Tip .custom olmalı (Sistem efektlerini kapatır)
            let btn = NeonGlassButton(type:.custom)
            
            // 2. Resmi Ayarla
            let image = isSystemIcon ? UIImage(systemName: iconName) : UIImage(named: "menu")
            btn.setImage(image, for: .normal)
            
            // 3. Rengi Ayarla (Proje temanıza göre)
            // Eğer resim görünmüyorsa .systemBlue veya .black deneyin
            btn.tintColor = AppTheme.Color.mainText
            
            // 4. Arka Planı ŞEFFAF yap (Sorunu çözen kısım)
            btn.backgroundColor = .clear
            btn.layer.backgroundColor = UIColor.clear.cgColor
            
            // 5. Boyut ve Aksiyon
            btn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            btn.addTarget(target, action: action, for: .touchUpInside)
            
            // 6. Bar Item olarak paketle
            return UIBarButtonItem(customView: btn)
        }
    // MARK: - Actions
        
        @objc func goToMainPage() {
            // Geri tuşuna basınca Index 0'a (Kronometreye) kaydır
            let mainVC = orderedViewControllers[0]
            setViewControllers([mainVC], direction: .reverse, animated: true, completion: nil)
            updateNavBar(for: 0)
        }
        
        
        
        @objc func cyclePages() {
            guard let currentVC = viewControllers?.first,
                  let currentIndex = orderedViewControllers.firstIndex(of: currentVC) else { return }
            
            let nextIndex = (currentIndex + 1) % orderedViewControllers.count
            let nextVC = orderedViewControllers[nextIndex]
            
            setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
            
            // Sayfa değişince Bar'ı güncelle
            updateNavBar(for: nextIndex)
        }
    
    private func setupNavigationButtons() {
            // SOL BUTON: Settings (Hamburger Menu)
            let menuBtn = UIButton(type: .system)
            menuBtn.setImage(UIImage(named: "menu"), for: .normal)
            menuBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44) // Sabit boyut veriyoruz
            menuBtn.addTarget(self, action: #selector(callSettingsMenu), for: .touchUpInside)
            
            let menuBarItem = UIBarButtonItem(customView: menuBtn)
            // Genişliği sabitle (Constraint hatasını önler)
            menuBarItem.width = 44
            self.navigationItem.leftBarButtonItem = menuBarItem
            
            // SAĞ BUTON: Sayfa Değiştir (Clock)
            let cycleBtn = UIButton(type: .system)
            cycleBtn.setImage(UIImage(systemName: "clock"), for: .normal)
            cycleBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            cycleBtn.addTarget(self, action: #selector(cyclePages), for: .touchUpInside)
            
            let cycleBarItem = UIBarButtonItem(customView: cycleBtn)
            cycleBarItem.width = 44
            self.navigationItem.rightBarButtonItem = cycleBarItem
        }
    // MARK: - Setup Common Background (YENİ FONKSİYON)
    private func setupCommonBackground() {
            // AppTheme'den o anki resmi al
            let bgImage = AppTheme.backgroundImage
            
            let bgImageView = UIImageView(image: bgImage)
            bgImageView.contentMode = .scaleAspectFill
            bgImageView.translatesAutoresizingMaskIntoConstraints = false
            self.view.insertSubview(bgImageView, at: 0)
            
            // Referansı sakla (Değiştirebilmek için)
            self.backgroundImageView = bgImageView
            
            NSLayoutConstraint.activate([
                bgImageView.topAnchor.constraint(equalTo: self.view.topAnchor),
                bgImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                bgImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                bgImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
        }
        
        // TEMA GÜNCELLEME FONKSİYONU
        @objc func updateTheme() {
            // Animasyonlu geçiş (Fade effect)
            guard let bgView = self.backgroundImageView else { return }
            
            UIView.transition(with: bgView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                bgView.image = AppTheme.backgroundImage
            }, completion: nil)
            
            // Navbar ikonlarının rengini de güncelle
            updateNavBar(for: 0) // Veya o anki index neyse
        }
        
        // Deinit: Hafıza temizliği
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
            
    // MARK: - Actions
    
    @objc func callSettingsMenu() {
        // Storyboard'daki Segue ID'sinin "toSettingsMenu" olduğundan emin ol [cite: 5]
        self.performSegue(withIdentifier: "toSettingsMenu", sender: nil)
    }
    
    
    
    // MARK: - DataSource & Delegate
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = orderedViewControllers.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        guard previousIndex >= 0 else { return nil }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = orderedViewControllers.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        guard nextIndex < orderedViewControllers.count else { return nil }
        return orderedViewControllers[nextIndex]
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed,
               let visibleVC = pageViewController.viewControllers?.first,
               let index = orderedViewControllers.firstIndex(of: visibleVC) {
                
                // Kullanıcı eliyle kaydırma yaptığında Bar'ı güncelle
                updateNavBar(for: index)
            }
        }
}
