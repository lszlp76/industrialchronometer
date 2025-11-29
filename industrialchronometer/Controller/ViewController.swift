//
//  ViewController.swift
//  industrialchronometer
//
//  Created by ulas özalp on 31.01.2022.
//  Refactored for MVVM on 22.11.2025
//

import UIKit
import AVFoundation
import MediaPlayer
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import Combine // Veri akışı için eklendi
import ActivityKit // Live Activities için

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    // MARK: - Properties
    
    // ViewModel: Tüm iş mantığı burada
    private var initialVolume: Float = 0.0
        private var isResettingVolume = false // Programatik değişiklik kontrolü
    public let viewModel = ChronometerViewModel()
    private var cancellables = Set<AnyCancellable>()
    // GİZLİ SES KONTROLCÜSÜ (Sınıfın en üstüne ekle)
        let volumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))
    // UI Outlets
    @IBOutlet weak var bannerBoard: UIView!
    @IBOutlet weak var dashBoard: UIStackView!
    @IBOutlet weak var lapListTableView: UITableView!
    
    @IBOutlet weak var totalView: UIStackView!
    @IBOutlet weak var secUnitLabel: UILabel!
    @IBOutlet weak var aveCycTimeLabel: UILabel!
    @IBOutlet weak var maxCycTimeLabel: UILabel!
    @IBOutlet weak var minCycTimeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetTimer: UIButton!
    @IBOutlet weak var observationTimer: UILabel!
    @IBOutlet weak var cycPerMinuteLabel: UILabel!
    @IBOutlet weak var cycPerHourLabel: UILabel!
    
    @IBOutlet weak var lapButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // AdMob & Audio
    var bannerView: GADBannerView!
    private var audioLevel: Float!
    
    // Live Activity Reference (Sadece iOS 16.2+ için hafızada yer kaplar)
    @available(iOS 16.2, *)
    var currentActivity: Activity<ChronometerWidgetAttributes>? {
        get { return _currentActivity as? Activity<ChronometerWidgetAttributes> }
        set { _currentActivity = newValue }
    }
    private var _currentActivity: Any? // Type-erased storage for older iOS support
    
   
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Bu satır, içeriğin Navigation Bar'ın altında kalmasını engeller
            self.edgesForExtendedLayout = []
        
         // 1. Ayarları Yükle
        loadSettings()
        setupAds()
        // 2. UI ve Binding Kurulumu
        configureUI()
        updateThemeColors()
        setupBindings()
        setupNotifications()
        setupLiveActivityBridge()
        
        // 3. Diğer Servisler
       listenVolumeButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Gerekirse UI güncellemeleri
    }
    
    deinit {
            // 1. Bildirim Merkezi Gözlemcilerini Temizle
            NotificationCenter.default.removeObserver(self)
            
            // 2. Ses Tuşu Gözlemcisini Temizle
            // try? kullanarak, eğer gözlemci hiç eklenmediyse uygulamanın çökmesini engelliyoruz.
            try? AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
        }
    
    // MARK: - MVVM Bindings (Bağlantılar)
        
        private func setupBindings() {
            
            
           
                    // 1. ANA ZAMANLAYICI (Zengin Metin Formatı ile)
                    viewModel.$timeLabelText
                        .receive(on: DispatchQueue.main)
                        .sink { [weak self] timeString in
                            self?.updateTimerLabel(text: timeString)
                        }
                        .store(in: &cancellables)
           
            
            // 2. Durum Yönetimi (Start/Pause Buton Yazıları)
            viewModel.$state
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    self?.updateUIForState(state)
                }
                .store(in: &cancellables)
            
            // 3. İstatistikler (Hepsine .map { Optional($0) } eklendi)
            viewModel.$minCycleText
                .map { Optional($0) }
                .assign(to: \.text, on: minCycTimeLabel)
                .store(in: &cancellables)
            
            viewModel.$maxCycleText
                .map { Optional($0) }
                .assign(to: \.text, on: maxCycTimeLabel)
                .store(in: &cancellables)
            
            viewModel.$avgCycleText
                .map { Optional($0) }
                .assign(to: \.text, on: aveCycTimeLabel)
                .store(in: &cancellables)
            
            viewModel.$cpmText
                .map { Optional($0) }
                .assign(to: \.text, on: cycPerMinuteLabel)
                .store(in: &cancellables)
            
            viewModel.$cphText
                .map { Optional($0) }
                .assign(to: \.text, on: cycPerHourLabel)
                .store(in: &cancellables)
            
            // 4. Birim Değişimi (Unit Label)
            viewModel.$isCminUnit
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isCmin in
                    self?.secUnitLabel.text = isCmin ? "Cmin." : "Sec."
                    self?.secUnitLabel.backgroundColor = AppTheme.Color.systemBackground
                }
                .store(in: &cancellables)
            
            
        }
    
   
    
    // MARK: - Actions
    
    @IBAction func startTimer(_ sender: Any) {
        // Timer başladığı an Singleton'ı güncelle
                TimerStartControl.timerStartControl.timerStarted = true
        switch viewModel.state {
        case .stopped, .paused:
            viewModel.startTimer()
        case .running:
            viewModel.pauseTimer()
        }
    }
    
    @IBAction func resetTimer(_ sender: Any) {
        let resetAlert = UIAlertController(title: "Clear All Data", message: "Would you like to reset your study?", preferredStyle: .alert)
        
        // Font Styling
        styleAlert(resetAlert)
        
        let actionReset = UIAlertAction(title: "Reset", style: .default) { [weak self] _ in
            self?.viewModel.resetTimer()
            // SIFIRLANDIĞINDA: Kilitleri kaldır
                        TimerStartControl.timerStartControl.timerStarted = false
            self?.lapListTableView.reloadData()
            
            if #available(iOS 16.2, *) {
                self?.endLiveActivity()
            }
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        resetAlert.addAction(actionReset)
        resetAlert.addAction(actionCancel)
        resetAlert.applyAppTheme()
        present(resetAlert, animated: true)
    }
    
    @IBAction func takeLap(_ sender: Any) {
        viewModel.lap()
        // Tabloyu güncelle (En son eklenen en üstte olacak şekilde logic VM içinde olmalı veya burada ters index)
        lapListTableView.reloadData()
    }
    
    // MARK: - Settings & Notifications
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        viewModel.isCminUnit = defaults.isCminUnit
        // Diğer ayarlar VM içinde veya burada yönetilebilir
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .timeUnitSelection, object: nil, queue: .main) { [weak self] _ in
            self?.viewModel.isCminUnit.toggle()
            
            // Kalıcılık için UserDefaults güncelle (UserDefaultExtension yapısına uygun)
            let isCmin = self?.viewModel.isCminUnit ?? false
            UserDefaults.standard.isCminUnit = isCmin
            UserDefaults.standard.isSecondUnit = !isCmin
            
            self?.lapListTableView.reloadData()
            
        }
        // --- YENİ EKLENEN KISIM: PRECISION DEĞİŞİMİ ---
                // AboutViewController slider'ı değiştirdiğinde bu bildirim gelir
                NotificationCenter.default.addObserver(forName: NSNotification.Name("PrecisionChanged"), object: nil, queue: .main) { [weak self] _ in
                    // Tabloyu yenile ki yeni ondalık formatı görünsün
                    self?.lapListTableView.reloadData()
                    // Ayrıca ana istatistik etiketlerini de güncellemek gerekir
                    // ViewModel'deki updateStats() tetiklenirse iyi olur ama
                    // en azından tabloyu güncellemek yeterlidir.
                }
        
        // TEMA DEĞİŞİKLİĞİ DİNLEYİCİSİ
                NotificationCenter.default.addObserver(forName: .themeChanged, object: nil, queue: .main) { [weak self] _ in
                    self?.updateThemeColors()
                }
        // Screen Saver ve Pause Lap mantıkları buraya eklenebilir
    }
    
    // MARK: - TableView Delegate & DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getLapCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "lapList", for: indexPath) as! LapLineViewControllerTableViewCell
            cell.cellDelegate = self
            cell.index = indexPath
            
            // ViewModel'den veriyi al
            let reverseIndex = (viewModel.getLapCount() - 1) - indexPath.row
            let (lapData, cycleTime) = viewModel.getLap(at: reverseIndex)
            
            // Formatlama ve Gösterim
            let milisMultiplier = viewModel.isCminUnit ? 100.0 : 60.0
            
            // --- DÜZELTME BURADA BAŞLIYOR ---
            // 1. Precision Değerini Oku
            let p = UserDefaults.standard.integer(forKey: "PrecisionValue")
            // Eğer değer hiç atanmamışsa varsayılan 2 olsun
            let precision = UserDefaults.standard.object(forKey: "PrecisionValue") == nil ? 2 : p
            
            // 2. Format Stringini Oluştur (Örn: "%.3f")
            let formatString = "%.\(precision)f"
            
            // 3. Değeri Formatla
            cell.lapValue.text = String(format: formatString, cycleTime * Float(milisMultiplier))
            // --- DÜZELTME BURADA BİTİYOR ---
            
            cell.lapLabel.text = String(lapData.lapSay)
        
        // --- DEĞİŞİKLİK BURADA ---
            // ViewModel'deki 'isCminUnit' değerini fonksiyona paslıyoruz.
            cell.lapCycle.text = lapData.LapToString(isCmin: viewModel.isCminUnit)
             
            // Styling
            cell.lapValue.textColor = AppTheme.Color.mainText
            cell.lapLabel.textColor = AppTheme.Color.mainText
            cell.lapCycle.textColor = AppTheme.Color.mainText
            cell.AddNote.tintColor = AppTheme.Color.mainText
            cell.backgroundColor = (indexPath.row % 2 == 0) ? AppTheme.Color.tableRowOdd : AppTheme.Color.tableRowEven
            
            return cell
        }
    
    // MARK: - File Saving (CSV)
    
    @IBAction func saveToFile(_ sender: Any) {
        // 1. Lap var mı kontrol et
                guard viewModel.getLapCount() > 0 else {
                    showErrorAlert(title: "⚠️ No Laps", message: "You have to catch at least one lap to save.")
                    return
                }
                
                // 2. Dosya Adı Sor
                let fileNameAlert = UIAlertController(title: "Save Data", message: "Enter a file name for your study.", preferredStyle: .alert)
                styleAlert(fileNameAlert) // Senin stil fonksiyonun
                
                fileNameAlert.addTextField { textField in
                    textField.placeholder = "File Name..."
                    // Otomatik tarihli isim önerisi (Opsiyonel ama kullanıcı dostu)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MM-yyyy_HH-mm"
                    textField.text = "Study_\(formatter.string(from: Date()))"
                }
                
                // 3. Kaydet Aksiyonu
                let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                    guard let self = self,
                          let fileName = fileNameAlert.textFields?[0].text, !fileName.isEmpty else { return }
                    
                    // A) CSV String'ini Oluştur (ViewModel üzerinden)
                    // Başlangıç tarihi olarak bugünü veriyoruz
                    let csvData = self.viewModel.generateCSVString(startTime: Date())
                    
                    // B) Dosyayı Kaydet (TransferService kullanarak)
                    TransferService.sharedInstance.saveTo(name: fileName, csvString: csvData)
                    
                    // C) Kullanıcıya Bilgi Ver
                    let successAlert = UIAlertController(title: "Saved!", message: "File '\(fileName).csv' has been saved successfully.", preferredStyle: .alert)
                    self.styleAlert(successAlert)
                    successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    successAlert.applyAppTheme()
                    self.present(successAlert, animated: true)
                }
                
                fileNameAlert.addAction(saveAction)
                fileNameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        fileNameAlert.applyAppTheme()
                present(fileNameAlert, animated: true)
            
    }
    
    // MARK: - Helper Functions
    
    private func styleAlert(_ alert: UIAlertController) {
        alert.setValue(NSAttributedString(string: alert.title ?? "", attributes: [
            .font: AppTheme.Font.digitalBold(size: 25.0),
            .foregroundColor: AppTheme.Color.dialogText as Any
        ]), forKey: "attributedTitle")
        
        alert.setValue(NSAttributedString(string: alert.message ?? "", attributes: [
            .font: AppTheme.Font.digital(size: 22.0),
            .foregroundColor: AppTheme.Color.dialogText as Any
        ]), forKey: "attributedMessage")
    }
    
    private func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        styleAlert(alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.applyAppTheme()
        present(alert, animated: true)
    }
    
    // MARK: - UI Configuration (TAMAMEN YENİLENDİ)
        
        private func configureUI() {
            
          
            // 1. Genel Arka Plan
            view.backgroundColor = .clear
             
            // 2. TableView Ayarları
            lapListTableView.delegate = self
            lapListTableView.dataSource = self
            lapListTableView.backgroundColor = .clear // Arka plan rengi hücrelerden gelsin
            
            // 3. ANA SAYAÇ (En büyük font)
            timeLabel.font = AppTheme.Font.digitalBold(size: 65.0) // Büyük punto
            timeLabel.textColor = AppTheme.Color.mainText // Vurgu rengi (Mavi vb.)
            timeLabel.adjustsFontSizeToFitWidth = true
            
            // 4. BİRİM LABEL (Sec / Cmin)
            secUnitLabel.font = AppTheme.Font.robotex(size: 20.0)
            secUnitLabel.textColor = AppTheme.Color.mainText
            
            // 5. İSTATİSTİK LABEL'LARI (Ortak Stil)
            // Gruplayarak kod tekrarını önlüyoruz
            let statLabels = [
                minCycTimeLabel,
                maxCycTimeLabel,
                aveCycTimeLabel,
                cycPerMinuteLabel,
                cycPerHourLabel,
                observationTimer,
            ]
            
            statLabels.forEach { label in
                label?.font = AppTheme.Font
                    .robotex(size: 22.0) // Okunabilir boyut
                label?.textColor = AppTheme.Color.mainText      // Ana metin rengi
                
                // Border Styling (Kutu Tasarımı)
//                label?.layer.borderWidth = 2
//                label?.layer.cornerRadius = 10
//                label?.layer.borderColor = AppTheme.Color.colorBorder.cgColor
//            
//                label?.clipsToBounds = true
            }
            
           
            
            // 7. BUTONLAR
                    // GlassButton kullandığımız için arka plan rengi veya border atamamıza gerek yok.
                    // Sadece font ayarını yapıyoruz, gerisini GlassButton sınıfı hallediyor.
                    
                    let buttons = [startButton, resetTimer, lapButton, saveButton]
            // İkon boyutu ve kalınlığı
                    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
                    
                    buttons.forEach { button in
                        // Yazıları temizle
                        button?.setTitle("", for: .normal)
                        
                        // Arka planı temizle (GlassButton efekti için)
                        button?.backgroundColor = .clear
                        
                        // İkon yerleşimini ortala
                        button?.contentHorizontalAlignment = .center
                        button?.contentVerticalAlignment = .center
                        
                        // İkon konfigürasyonunu ata
                        button?.setPreferredSymbolConfiguration(symbolConfig, forImageIn: .normal)
                    }
            // SABİT İKONLAR (Duruma göre değişmeyenler)
                    // Reset -> Geri Dönüş Ok
                    resetTimer.setImage(UIImage(systemName: "arrow.counterclockwise"), for: .normal)
                    
                    // Save -> İndir/Kaydet İkonu
                    saveButton.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
                    
                    // Lap -> Bayrak İkonu
                    lapButton.setImage(UIImage(systemName: "flag.fill"), for: .normal)
//                    buttons.forEach { button in
//                        // Sadece fontu AppTheme'den alalım
//                        button?.titleLabel?.font = AppTheme.Font.digitalBold(size: 24.0)
//                        
//                        // Arka plan rengini temizle ki cam efekti görünsün
//                        button?.backgroundColor = .clear
//                    }
        }
    private func updateThemeColors() {
            let color = AppTheme.Color.mainText
            let border = AppTheme.Color.colorBorder.cgColor
            
            // Label Renkleri
            timeLabel.textColor = color
            secUnitLabel.textColor = color
            
            // İstatistikler
            let statLabels = [
                minCycTimeLabel, maxCycTimeLabel, aveCycTimeLabel,
                cycPerMinuteLabel, cycPerHourLabel, observationTimer
            ]
            statLabels.forEach {
                $0?.textColor = color
                $0?.layer.borderColor = border
            }
            
            // BUTON İKON RENKLERİ (Tint Color)
            [startButton, resetTimer, lapButton, saveButton].forEach {
                $0?.tintColor = color // İkonun rengini değiştirir
                // $0?.setTitleColor(...) satırını silebilirsin, artık yazı yok.
            }
            
            // Tabloyu yenile
            lapListTableView.reloadData()
        }
    // MARK: - Timer Formatting Helper
        
    // MARK: - Timer Formatting Helper
        
        private func updateTimerLabel(text: String) {
            // 1. Font Ayarları (YENİ FONTU KULLANIYORUZ)
            // digitalBold yerine 'timerFont' kullanıyoruz.
            let mainFont = AppTheme.Font.timerFont(size: 65.0)
            let decimalFont = AppTheme.Font.timerFont(size: 40.0)
            
            // 2. Metni Noktadan Böl
            let components = text.components(separatedBy: ".")
            
            if components.count == 2 {
                let mainPart = components[0]
                let decimalPart = components[1]
                
                // 3. Attributed String (Kern ekleyerek harf aralıklarını da sabitliyoruz)
                // .kern değeri harfler arası boşluğu ayarlar, titremeyi daha da azaltır.
                let mainAttributes: [NSAttributedString.Key: Any] = [
                    .font: mainFont,
                    .foregroundColor: AppTheme.Color.mainText,
                    .kern: -1.0 // Rakamları hafifçe birbirine yaklaştırır (Opsiyonel)
                ]
                
                let decimalAttributes: [NSAttributedString.Key: Any] = [
                    .font: decimalFont,
                    .foregroundColor: AppTheme.Color.mainText,
                    .kern: -0.5
                ]
                
                let fullString = NSMutableAttributedString(string: mainPart, attributes: mainAttributes)
                let decimalString = NSAttributedString(string: "." + decimalPart, attributes: decimalAttributes)
                
                fullString.append(decimalString)
                
                // 4. Label'a Ata
                timeLabel.attributedText = fullString
                
            } else {
                timeLabel.text = text
                timeLabel.font = mainFont
            }
        }
        
        // MARK: - Update UI State (Ufak bir temizlik)
        
    private func updateUIForState(_ state: ChronometerState) {
            // Opaklık ayarları
            let activeAlpha: CGFloat = 1.0
            let disabledAlpha: CGFloat = 0.5
            
            switch state {
            case .stopped:
                // DURUM: DURDU
                resetTimer.isEnabled = false; resetTimer.alpha = disabledAlpha
                saveButton.isEnabled = false; saveButton.alpha = disabledAlpha
                lapButton.isEnabled = false; lapButton.alpha = disabledAlpha
                
                // İkon: Oynat (Play)
                startButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                
            case .running:
                // DURUM: ÇALIŞIYOR
                resetTimer.isEnabled = false; resetTimer.alpha = disabledAlpha
                saveButton.isEnabled = false; saveButton.alpha = disabledAlpha
                lapButton.isEnabled = true; lapButton.alpha = activeAlpha
                
                // İkon: Duraklat (Pause)
                startButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                
            case .paused:
                // DURUM: DURAKLATILDI
                resetTimer.isEnabled = true; resetTimer.alpha = activeAlpha
                saveButton.isEnabled = true; saveButton.alpha = activeAlpha
                lapButton.isEnabled = false; lapButton.alpha = disabledAlpha
                
                // İkon: Devam Et (Play)
                startButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        }
    private func setupLiveActivityBridge() {
            
            // 1. Güncelleme İsteği Geldiğinde (Start veya Pause anında)
            viewModel.onLiveActivityUpdate = { [weak self] isRunning, refDate, staticText, unit in
                if #available(iOS 16.2, *) {
                    self?.manageLiveActivity(isRunning: isRunning, refDate: refDate, staticText: staticText, unit: unit)
                }
            }
            
            // 2. Bitirme İsteği Geldiğinde (Reset anında)
            viewModel.onLiveActivityEnd = { [weak self] in
                if #available(iOS 16.2, *) {
                    self?.endLiveActivity()
                }
            }
        }
    
    // MARK: - Audio (Volume Key Trigger) - GÜNCELLENMİŞ
        
    func listenVolumeButton() {
            // Görünmez ses kontrolcüsünü ekle
            volumeView.clipsToBounds = true
            volumeView.alpha = 0.01
            view.addSubview(volumeView)
            
            let audioSession = AVAudioSession.sharedInstance()
            do {
                // Arka plan müziğini kesmemesi için ayar
                try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
                try audioSession.setActive(true)
                
                // Gözlemciyi ekle
                audioSession.addObserver(self, forKeyPath: "outputVolume", options: [.new], context: nil)
                
                // BAŞLANGIÇ HACK'İ: Sesi %50'ye çek
                // Böylece Aşağı ve Yukarı tuşları için hareket alanı açılır.
                if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
                                // UI Thread'inde, küçük bir gecikmeyle (sistem hazır olsun diye)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    // Slider'ı manuel olarak 0.5'e çek
                                    slider.setValue(0.5, animated: false)
                                    
                                    // Bizim referans değişkenimizi de 0.5 yap
                                    self.initialVolume = 0.5
                                }
                            }
                
            } catch {
                print("Ses ayarı hatası: \(error)")
            }
        }
        
        // Dinlemeyi durdurmak için (Deinit veya viewDidDisappear içinde çağrılabilir)
        func stopListeningVolumeButton() {
            AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
        }
        
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            
            if keyPath == "outputVolume" {
                // Eğer değişikliği biz yaptıysak (Reset işlemi), yoksay ve çık.
                if isResettingVolume {
                    isResettingVolume = false
                    return
                }
                
                guard let audioSession = object as? AVAudioSession else { return }
                let currentVolume = audioSession.outputVolume
                
                // Çok küçük değişimleri (titreşim vb.) yoksay
                if abs(currentVolume - initialVolume) < 0.001 { return }
                
                // --- TUŞ MANTIĞI ---
                
                if currentVolume > initialVolume {
                    // YUKARI TUŞU -> START / PAUSE
                    // UI tepkisi gecikmesin diye ana thread'de hemen çağır
                    DispatchQueue.main.async {
                        self.startTimer(self)
                    }
                }
                else if currentVolume < initialVolume {
                    // AŞAĞI TUŞU -> LAP
                    if viewModel.state == .running {
                        DispatchQueue.main.async {
                            self.takeLap(self)
                        }
                    }
                }
                
                // --- SES RESETLEME (Sonsuz döngü için) ---
                
                // Bayrağı kaldır: "Birazdan yapacağım değişikliği ben yapıyorum, sakın algılama"
                isResettingVolume = true
                
                // Ses slider'ını bul ve eski yerine (veya %50'ye) çek
                if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
                    // Animasyonsuz (anında) yap ki kullanıcı fark etmesin
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        slider.setValue(0.5, animated: false)
                        self.initialVolume = 0.5 // Referansımızı da güncelle
                    }
                }
            } else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        }
        
        // listenVolumeButton içinde de başlangıcı 0.5 yapmayı unutma:
        /*
           resetVolume(to: 0.5) // Yerine
           initialVolume = 0.5
           slider.setValue(0.5, animated: false)
        */
   
    // MARK: - AdMob Setup
    
    func setupAds() {
        guard #available(iOS 14, *) else { return }
        let viewWidth = view.frame.inset(by: view.safeAreaInsets).width
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        
        ATTrackingManager.requestTrackingAuthorization { [weak self] status in
            guard let self = self else { return }
            self.bannerView = GADBannerView(adSize: adaptiveSize)
            self.addBannerViewToView(self.bannerView)
            self.bannerView.adUnitID = "ca-app-pub-2013051048838339/2472749234"
            self.bannerView.rootViewController = self
            self.bannerView.load(GADRequest())
        }
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        NSLayoutConstraint.activate([
            bannerView.topAnchor
                .constraint(equalTo: bannerBoard.topAnchor,constant: -5),
            bannerView.bottomAnchor.constraint(equalTo: bannerBoard.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bannerView.widthAnchor.constraint(equalTo: bannerBoard.widthAnchor)
        ])
    }
}

// MARK: - SupportedFeaturesForLapLine Delegate

extension ViewController: SupportedFeaturesForLapLine {
    func onAddLapNotes(index: Int) {
            // Tablo ters sıralı olduğu için gerçek index'i hesaplıyoruz
            let reverseIndex = (viewModel.getLapCount() - 1) - index
            let (lap, _) = viewModel.getLap(at: reverseIndex)
            
            let noteAlert = UIAlertController(title: "Add Note for Lap \(lap.lapSay)", message: "", preferredStyle: .alert)
            // Eğer varsa stil fonksiyonunuzu çağırın: styleAlert(noteAlert)
            
            noteAlert.addTextField { textField in
                textField.text = lap.lapnote // Mevcut notu göster
                textField.placeholder = "Enter note..."
            }
            
            noteAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
                guard let self = self,
                      let note = noteAlert.textFields?[0].text else { return }
                
                // --- DÜZELTME BURADA ---
                // Notu ViewModel üzerinden ana veriye kaydediyoruz
                self.viewModel.updateLapNote(at: reverseIndex, note: note)
                
                // Tabloyu yeniliyoruz ki not ekranda görünsün
                self.lapListTableView.reloadData()
            }))
            
            noteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(noteAlert, animated: true)
        }
    // iPad Support Helper
    @available(iOS 16.2, *) // Eski kodda bu vardı, korundu
    func addActionSheetForiPad(actionSheet: UIAlertController) {
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
    }
}

// MARK: - Live Activity Methods (iOS 16.2+)

@available(iOS 16.2, *)
extension ViewController {
    
   
    func manageLiveActivity(isRunning: Bool, refDate: Date, staticText: String, unit: String) {
            
            let state = ChronometerWidgetAttributes.ContentState(
                isRunning: isRunning,
                referenceDate: refDate,
                staticTime: staticText,
                unit: unit // <--- YENİ: Birimi buraya ekledik
            )
            
            if currentActivity == nil {
                guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
                let attributes = ChronometerWidgetAttributes(studyName: "Industrial Chronometer")
                
                do {
                    currentActivity = try Activity.request(attributes: attributes, contentState: state, pushType: nil)
                } catch { print(error) }
                
            } else {
                Task {
                    await currentActivity?.update(using: state, alertConfiguration: nil)
                }
            }
        }
        
        func endLiveActivity() {
            guard let activity = currentActivity else { return }
            Task {
                await activity.end(nil, dismissalPolicy: .immediate)
                self.currentActivity = nil
            }
        }
    }
extension ViewController {
    // Deep Link Yöneticisi
    func handleDeepLink(url: URL) {
        print("🔗 Gelen Komut: \(url.absoluteString)")
        
        switch url.host {
        case "pause":
            if viewModel.state == .running {
                viewModel.pauseTimer()
            }
            
        case "resume":
            if viewModel.state == .paused || viewModel.state == .stopped {
                viewModel.startTimer()
            }
            
        case "stop":
            // Reset butonunun yaptığı işi yap
            // Alert göstermeden direkt resetlemek istersen:
            viewModel.resetTimer()
            lapListTableView.reloadData()
            if #available(iOS 16.2, *) {
                endLiveActivity()
            }
            
        case "lap":
            if viewModel.state == .running {
                viewModel.lap()
                lapListTableView.reloadData()
            }
            
        default:
            break
        }
    }
}
