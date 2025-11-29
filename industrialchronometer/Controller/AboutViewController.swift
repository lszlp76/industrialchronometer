//
//  AboutViewController.swift
//  industrialchronometer
//
//  Created by ulas özalp on 3.02.2022.
//  Updated for Precision Slider & Disable Logic
//

import UIKit
import StoreKit

class AboutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var settingIcon = [Section]()
    // ImageView referansı (Dinamik değişim için)
        private var backgroundImageView: UIImageView?
        @IBOutlet weak var tableView: UITableView!
        var chosen: (Int, Int) = (0, 0)
        let userDefaults = UserDefaults.standard
        
        // Timer Durumu: Singleton üzerinden kontrol ediyoruz
        var isTimerRunning: Bool {
            // Eğer timer "Stopped" değilse (Running veya Paused), ayarları kilitlemeliyiz.
            // TimerStartControl.timerStarted değeri true ise timer aktif demektir.
            return TimerStartControl.timerStartControl.timerStarted ?? false
        }
    
  
    override func viewDidLoad() {
            super.viewDidLoad()
        // 1. Arka Plan Kurulumu (Dinamik)
                setupCommonBackground()
        
        
            tableView.delegate = self
            tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.backgroundView?.backgroundColor = .clear
            // 1. Screen Saver Varsayılan Ayarı (Default OFF)
            if userDefaults.object(forKey: "ScreenSaver") == nil {
                userDefaults.set(false, forKey: "ScreenSaver")
                UIApplication.shared.isIdleTimerDisabled = false
            } else {
                // Mevcut ayarı sisteme uygula
                UIApplication.shared.isIdleTimerDisabled = userDefaults.bool(forKey: "ScreenSaver")
            }
            
            // 2. Precision Varsayılan Ayarı (Default 2)
            if userDefaults.object(forKey: "PrecisionValue") == nil {
                userDefaults.set(2, forKey: "PrecisionValue")
            }
            
            configureAboutList()
        // TEMA DEĞİŞİKLİĞİNİ DİNLE (Anlık arka plan değişimi için)
                NotificationCenter.default.addObserver(self, selector: #selector(updateThemeBackground), name: .themeChanged, object: nil)
        }
    // YENİ: Arka Plan Kurulum Fonksiyonu
        private func setupCommonBackground() {
            let bgImage = AppTheme.backgroundImage
            let bgView = UIImageView(frame: UIScreen.main.bounds)
            bgView.image = bgImage
            bgView.contentMode = .scaleAspectFill
            view.insertSubview(bgView, at: 0)
            self.backgroundImageView = bgView
        }
    // YENİ: Tema Güncelleme Tetikleyicisi
        @objc func updateThemeBackground() {
            guard let bgView = self.backgroundImageView else { return }
            UIView.transition(with: bgView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                bgView.image = AppTheme.backgroundImage
            }, completion: nil)
            
            // Tablo yazı renklerini güncellemek için reload
            tableView.reloadData()
        }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // Timer durumu değişmiş olabilir, tabloyu yenileyerek kilitleri güncelle
            tableView.reloadData()
        }
    func configureAboutList() {
            // Ayarlar Menüsü Yapısı
            self.settingIcon.append(Section(title: "Settings", option: [
                // 0: Screen Saver
                SettingIcon(label: "Screen saver activate", icon: UIImage(systemName: "display"), iconBackgroundColor: AppTheme.Color.iconTint, width: 20.0, heigth: 20.0, handler: {}, switchHide: false),
                
                // 1: Second Unit
                SettingIcon(label: "Second", icon: UIImage(systemName: "s.circle.fill"), iconBackgroundColor: AppTheme.Color.iconTint, width: 20.0, heigth: 20.0, handler: {}, switchHide: false),
                
                // 2: Cmin Unit
                SettingIcon(label: "Hundredths of minute", icon: UIImage(named: "cmin"), iconBackgroundColor: AppTheme.Color.iconTint, width: 20.0, heigth: 20.0, handler: {}, switchHide: false),
                // 4: PRECISION (Slider)
                SettingIcon(label: "Precision", icon: UIImage(systemName: "slider.horizontal.3"), iconBackgroundColor: AppTheme.Color.iconTint, width: 20.0, heigth: 20.0, handler: {}, switchHide: true, isSlider: true)
            ]))
          self.settingIcon.append(
                            Section(
                                title: "General",
                                option: [
                                    // YENİ: Theme satırını isSegment: true olarak ayarlıyoruz
                                    SettingIcon(
                                        label: "Theme",
                                        icon: UIImage(systemName: "circle.lefthalf.filled"), // Assets'te 'theme' ikonu olsun
                                        iconBackgroundColor: AppTheme.Color.iconTint,
                                        width: 20.0,
                                        heigth: 20.0,
                                        handler: {},
                                        switchHide: true,
                                        isSegment: true // <--- BU SATIR ÖNEMLİ
                                    ),
                                    SettingIcon(
                                        label: "Policy",
                                        icon: UIImage(systemName: "doc.text.magnifyingglass"),
                                        iconBackgroundColor: AppTheme.Color.iconTint,
                                        width: 20.0,
                                        heigth: 20.0,
                                        handler: {
                                        },
                                        switchHide: true),
                                    SettingIcon(
                                        label: "About",
                                        icon: UIImage(systemName: "info.circle.fill"),
                                        iconBackgroundColor: AppTheme.Color.iconTint,
                                        width: 20.0,
                                        heigth: 20.0,
                                        handler: {
                                        },
                                        switchHide: true),
                                    SettingIcon(
                                        label: "Rate App",
                                        icon: UIImage(systemName: "star.fill"),
                                        iconBackgroundColor: AppTheme.Color.iconTint,
                                        width: 20.0,
                                        heigth: 20.0,
                                        handler: {
                                        },
                                        switchHide: true)
                                ]
                            )
                        )
        }
    // MARK: - TableView Helper Methods
    func numberOfSections(in tableView: UITableView) -> Int { return settingIcon.count }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return settingIcon[section].option.count }
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return settingIcon[section].title }
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 30.0 }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
            guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = AppTheme.Font.robotex(size: 25.0)
            // Başlık rengi de temaya uysun
        header.textLabel?.textColor = AppTheme.Color.mainText
        }
    

    // MARK: - Cell Configuration
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LapListCellTableViewCell
        let item = settingIcon[indexPath.section].option[indexPath.row]
        
        cell.backgroundColor = .clear
        cell.backgroundView?.backgroundColor = .clear
        
        // Genel Ayarlar
        cell.aboutLabel.text = item.label
        cell.aboutLabel.font = AppTheme.Font.robotex(size: 22)
        cell.aboutLabel.textColor = AppTheme.Color.mainText // Temaya uygun renk
        cell.precisionLabel.textColor = AppTheme.Color.mainText
        
        cell.icon.image = item.icon?.withRenderingMode(.alwaysTemplate)
        cell.selectionStyle = .none
        
        if AppTheme.currentTheme == .dark {
                    cell.icon.tintColor = AppTheme.Color.iconTint // Krem Beyazı
                } else {
                    // Light modda ne istersin?
                    // Seçenek A: Hepsi Gece Mavisi olsun (Temiz görünüm)
                    cell.icon.tintColor = AppTheme.Color.iconTint
                    
                    // Seçenek B: Orijinal renklerini (Kırmızı/Mavi) korusun
                    // cell.icon.tintColor = item.iconBackgroundColor
                }
        
        // Kilit Kontrolü
        let shouldDisable = isTimerRunning
        
        // --- GÖRÜNÜRLÜK SIFIRLAMA ---
        cell.toggleSwitch.isHidden = true
        cell.precisionSlider.isHidden = true
        cell.precisionLabel.isHidden = true
        cell.themeSegment.isHidden = true // Varsayılan gizli
        
        // --- 1. SEGMENT (THEME) ---
                if item.isSegment {
                    cell.themeSegment.isHidden = false
                    
                    // Kayıtlı seçimi yükle (Dark/Light/System)
                    cell.themeSegment.selectedSegmentIndex = AppTheme.selectedTheme.rawValue
                    
                    // Değişim Handler'ı
                    cell.onThemeChange = { [weak self] index in
                        // 0: Dark, 1: Light, 2: System
                        if let newTheme = AppTheme.ThemeType(rawValue: index) {
                            AppTheme.selectedTheme = newTheme
                        }
                        
                        // Not: AppTheme içindeki setter zaten Notification yolluyor.
                    }
                }
        // --- 2. SLIDER (PRECISION) ---
        else if item.isSlider {
            cell.precisionSlider.isHidden = false
            cell.precisionLabel.isHidden = false
            
            cell.precisionSlider.minimumValue = 0
            cell.precisionSlider.maximumValue = 3
            
            let currentPrecision = userDefaults.integer(forKey: "PrecisionValue")
            cell.precisionSlider.value = Float(currentPrecision)
            cell.updatePrecisionLabel(for: currentPrecision)
            
            cell.precisionSlider.isEnabled = !isTimerRunning
            cell.precisionSlider.alpha = isTimerRunning ? 0.5 : 1.0
            cell.precisionLabel.alpha = isTimerRunning ? 0.5 : 1.0
            
            cell.onSliderChange = { [weak self] newValue in
                self?.userDefaults.set(newValue, forKey: "PrecisionValue")
                NotificationCenter.default.post(name: NSNotification.Name("PrecisionChanged"), object: nil)
            }
        }
        // --- 3. SWITCH (Diğer Ayarlar) ---
        else if !item.switchHide {
            cell.toggleSwitch.isHidden = false
            cell.toggleSwitch.tag = indexPath.row + 4 * indexPath.section
            
            switch indexPath.row {
            case 0: cell.toggleSwitch.isOn = userDefaults.bool(forKey: "ScreenSaver")
            case 1: cell.toggleSwitch.isOn = userDefaults.bool(forKey: "SecondUnit")
            case 2: cell.toggleSwitch.isOn = userDefaults.bool(forKey: "CminUnit")
            default: break
            }
            
            if indexPath.section == 0 {
                cell.toggleSwitch.isEnabled = !isTimerRunning
            } else {
                cell.toggleSwitch.isEnabled = true
            }
            
            cell.toggleSwitch.addTarget(self, action: #selector(toggleTriggered(_:)), for: .valueChanged)
        }
        
        return cell
    }
    
    @objc func toggleTriggered(_ sender: UISwitch) {
            // Timer çalışırken zaten disable olduğu için buraya girmez, güvenlidir.
            
            if sender.tag == 0 {
                // SCREEN SAVER MANTIĞI
                let isOn = sender.isOn
                userDefaults.set(isOn, forKey: "ScreenSaver")
                // Sistemi güncelle: true ise uyku modu devre dışı (ekran açık kalır)
                UIApplication.shared.isIdleTimerDisabled = isOn
                print("Screen Saver Active: \(isOn)")
            }
            else if sender.tag == 1 { // Second Unit
                // Radio Button Mantığı (Biri açılınca diğeri kapanmalı)
                userDefaults.set(sender.isOn, forKey: "SecondUnit")
                if sender.isOn { userDefaults.set(false, forKey: "CminUnit") }
                NotificationCenter.default.post(name: .timeUnitSelection, object: nil)
            }
            else if sender.tag == 2 { // Cmin Unit
                userDefaults.set(sender.isOn, forKey: "CminUnit")
                if sender.isOn { userDefaults.set(false, forKey: "SecondUnit") }
                NotificationCenter.default.post(name: .timeUnitSelection, object: nil)
            }
            else if sender.tag == 3 {
                userDefaults.set(sender.isOn, forKey: "ActivateOneHunderth")
                NotificationCenter.default.post(name: .activateOneHunderth, object: nil)
            }
            
            // Tabloyu yenile ki diğer switchlerin (radio button) durumu güncellensin
            tableView.reloadData()
        }
    
    // ... (Diğer fonksiyonlar aynen kalabilir) ...
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            chosen = (indexPath.row,indexPath.section)
            if chosen.1 > 0  && chosen.0 < 2 {
                self.performSegue(withIdentifier: "toWebPage", sender: nil)
            } else if chosen.0 == 2  && chosen.1 == 1 {
                 rateApp()
             }
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let destinationVC = segue.destination as? WebViewController {
                destinationVC.chosen = chosen
            }
        }
        
        func rateApp() {
            if #available(iOS 14.0, *) {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            } else {
                SKStoreReviewController.requestReview()
            }
        }
    }
