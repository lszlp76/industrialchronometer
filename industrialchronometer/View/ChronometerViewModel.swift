//
//  ChronometerViewModel.swift
//  industrialchronometer
//
//  Created by ulas özalp on 22.11.2025.
//
import Foundation
import Combine


// Dosyanın en üstüne struct ekle
struct LapChartItem: Identifiable {
    let id = UUID()
    let lapNumber: Int
    let value: Double // Cycle Time değeri
}

// MARK: - State Enum
enum ChronometerState {
    case stopped
    case running
    case paused
}
@MainActor
class ChronometerViewModel: ObservableObject {
    
    // YENİ DEĞİŞKEN: Son güncelleme zamanını tutacağız
        private var lastWidgetUpdate: Date = Date.distantPast
        var onLiveActivityUpdate: ((Bool, Date, String, String) -> Void)?
  
    var onLiveActivityEnd: (() -> Void)?
    // MARK: - Published Properties (UI Dinler)
    @Published var timeLabelText: String = "00:00:00.00"
    @Published var state: ChronometerState = .stopped
    
    // Precision değerini UserDefaults'tan okuyan yardımcı fonksiyon
        private var precision: Int {
            return UserDefaults.standard.integer(forKey: "PrecisionValue")
        }

        // Formatlama fonksiyonunu dinamik hale getiriyoruz
        private func formatStat(value: Float, unit: String) -> String {
            let convertedValue = value * milisDivisor
            
            // Dinamik format string oluşturma (%.2f, %.3f vb.)
            let formatString = "%.\(precision)f %@"
            return String(format: formatString, convertedValue, unit)
        }
    // Birim Değişimi (Cmin vs Sec)
        @Published var isCminUnit: Bool = false {
            didSet {
                // 1. UI'ı ve İstatistikleri Güncelle
                updateDisplay()
                updateStats()
                recalculateChartData()
                
                // 2. CANLI AKTİVİTEYİ GÜNCELLE (EKSİK OLAN KISIM)
                // Birim değiştiği an Widget'a yeni veriyi (Sec veya Cmin) ve yeni metni gönderiyoruz.
                let isRunning = (state == .running)
                
                // Referans tarihini hesapla (Çalışıyorsa başlangıç noktası, duruyorsa şu an)
                let refDate: Date
                if isRunning, let start = startTime {
                    // Başlangıç zamanı - Duraklama süresi = Gerçek başlangıç referansı
                    refDate = start.addingTimeInterval(-elapsedWhenPaused)
                } else {
                    refDate = Date()
                }
                
                // Widget'a Sinyal Gönder: "Birim değişti, kendini yenile!"
                // Duraklatıldıysa (Sarı) yeni Cmin değerini anında göreceksin.
                onLiveActivityUpdate?(isRunning, refDate, timeLabelText, currentUnitLabel)
            }
        }
    // Grafiği besleyecek veri seti
        @Published var chartData: [LapChartItem] = []
    
    var currentUnitLabel: String { return isCminUnit ? "Cmin" : "Sec" }
    
    // İstatistikler
    @Published var minCycleText: String = ""
    @Published var maxCycleText: String = ""
    @Published var avgCycleText: String = ""
    @Published var cpmText: String = ""
    @Published var cphText: String = ""
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var startTime: Date?
    private var elapsedWhenPaused: TimeInterval = 0
    
    // Veri Modeli
    public var lapsVal = LapsVal()
    
    var milisDivisor: Float { return isCminUnit ? 100.0 : 60.0 }
    
    // Live Activity Callback
    var onTimerUpdate: ((String) -> Void)?
    
    // MARK: - TableView Helpers (EKSİK OLAN KISIM BURASIYDI)
    
    /// TableView satır sayısını döner
    func getLapCount() -> Int {
        return lapsVal.lapCount
    }
    
    /// Belirli bir indexteki lap verisini döner
    func getLap(at index: Int) -> (lap: Laps, cycleTime: Float) {
        // Index kontrolü
        guard index >= 0 && index < lapsVal.laps.count else {
            // Hata durumunda boş bir değer dön (Crash olmaması için)
            return (
                Laps(
                    hour: 0,
                    minute: 0,
                    second: 0,
                    msec: 0,
                    rawTime: 0.0,
                    lapnote: "",
                    lapSay: 0
                ),
                0.0
            )
        }
        return (lapsVal.laps[index], lapsVal.cycleTimes[index])
    }
    
    /// Lap notunu güncellemek için (ViewController'daki alert içinden çağrılır)
    // Bu fonksiyonun class içinde olduğundan emin olun:
    func updateLapNote(at index: Int, note: String) {
        guard index >= 0 && index < lapsVal.laps.count else { return }
        // Struct içindeki veriyi değiştiriyoruz
        lapsVal.laps[index].lapnote = note
    }
    
   
    
    // MARK: - Actions
        
    func startTimer() {
            if state == .running { return }
            
            // 1. Durumu güncelle
            state = .running
            startTime = Date()
            
            // 2. GECİKME ÇÖZÜMÜ: Timer'ın ilk 'tık'ını beklemeden,
            // şu anki durumu hemen ekrana basıyoruz.
            updateDisplay()
            
            // 3. Timer'ı Başlat (Hassas Mod)
            // main thread yerine .common modunda çalıştırıyoruz ki scroll yaparken durmasın
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
                self?.tick()
            }
            RunLoop.current.add(timer!, forMode: .common)
            
            // 4. Live Activity Başlat
            let referenceDate = Date().addingTimeInterval(-elapsedWhenPaused)
            onLiveActivityUpdate?(true, referenceDate, timeLabelText, currentUnitLabel)
        }
        
        func pauseTimer() {
            guard state == .running else { return }
            
            // 1. Timer'ı hemen öldür (Arka planda çalışmaya devam etmesin)
            timer?.invalidate()
            timer = nil
            
            // 2. DEĞER ATLAMA ÇÖZÜMÜ:
            // Son geçen süreyi hesapla ve 'elapsedWhenPaused' içine sabitle.
            if let start = startTime {
                let now = Date()
                let sessionTime = now.timeIntervalSince(start)
                elapsedWhenPaused += sessionTime
            }
            
            // Start zamanını sıfırla (Çünkü artık durduk)
            startTime = nil
            state = .paused
            
            // 3. Ekranı SON KEZ, hesaplanan SABİT değerle güncelle.
            // Böylece ekranda ne görüyorsan, hafızadaki değer de o olur.
            updateDisplay()
            
            // 4. Live Activity'i Durdur
            onLiveActivityUpdate?(false, Date(), timeLabelText, currentUnitLabel)
        }
    func resetTimer() {
            pauseTimer()
            elapsedWhenPaused = 0
            startTime = nil
            lapsVal.reset()
            chartData.removeAll()
            timeLabelText = "00:00:00.00"
            resetStatsText()
            state = .stopped
            
            // Widget'ı Öldür
            onLiveActivityEnd?()
        }
        
        // MARK: - Internal Logic
        
    // MARK: - Internal Logic
        
    // MARK: - Internal Logic
        
        private func tick() {
            // Her 0.01 saniyede bir ekranı güncelle
            updateDisplay()
            
            // Widget güncelleme fren mekanizması (Burayı koruyoruz)
            let now = Date()
            let updateInterval: TimeInterval = isCminUnit ? 0.6 : 1.0
            
            /* Burada lastWidgetUpdate kontrolü vardı, aynen kalsın.
               Sadece timeLabelText zaten updateDisplay() içinde güncellendiği için
               ekstra hesaplama yapmaya gerek yok.
            */
        }
        
        private func updateDisplay() {
            // Eğer çalışıyorsa (Date() - start) + eski_süre
            // Eğer duruyorsa sadece sabitlenen eski_süre (elapsedWhenPaused)
            let totalSeconds = getCurrentTotalSeconds()
            timeLabelText = formatTimeString(seconds: totalSeconds)
        }
        
        private func getCurrentTotalSeconds() -> TimeInterval {
            if state == .running, let start = startTime {
                // Çalışırken: Şu anki zaman farkı + eskiden birikmiş süre
                return Date().timeIntervalSince(start) + elapsedWhenPaused
            } else {
                // Dururken: Sadece birikmiş sabit süre
                return elapsedWhenPaused
            }
        }
    func lap() {
        // Şu anki tam süreyi al (Double hassasiyetinde)
                let totalSeconds = getCurrentTotalSeconds() // Bu zaten TimeInterval (Double) döner
                
                // addLap çağrısını güncelle
                _ = lapsVal.addLap(
                    totalSeconds: totalSeconds,
                    lapNote: "",
                    milis: milisDivisor
                )
        // Yeni veriyi grafiğe ekle
                // lapsVal.cycleTimes son eklenen değeri dakika cinsinden tutar.
                // Bunu seçili birime (Saniye veya Cmin) çevirip grafiğe atıyoruz.
                if let lastCycleMinute = lapsVal.cycleTimes.last {
                    let convertedValue = Double(lastCycleMinute * Float(milisDivisor))
                    let lapNum = lapsVal.lapCount
                    
                    let newItem = LapChartItem(lapNumber: lapNum, value: convertedValue)
                    chartData.append(newItem)
                }
        updateStats()
    }
    
    // MARK: - Internal Logic
    
//    private func tick() {
//        updateDisplay()
//        onTimerUpdate?(timeLabelText)
//    }
    
    
    
    private func secondsToComponents(seconds: TimeInterval) -> (Int, Int, Int, Int) {
        if isCminUnit {
            let totalMinutes = seconds / 60.0
            let h = Int(totalMinutes / 60)
            let m = Int(totalMinutes) % 60
            let centiminutes = (totalMinutes.truncatingRemainder(dividingBy: 1)) * 100
            let s = Int(centiminutes)
            let ms = Int((centiminutes.truncatingRemainder(dividingBy: 1)) * 100)
            return (h, m, s, ms)
        } else {
            let h = Int(seconds) / 3600
            let m = (Int(seconds) % 3600) / 60
            let s = (Int(seconds) % 60)
            let ms = Int((seconds.truncatingRemainder(dividingBy: 1)) * 100)
            return (h, m, s, ms)
        }
    }
    // MARK: - CSV Export
        
        func generateCSVString(startTime: Date) -> String {
            // Şu anki zamanı bitiş/toplam süre hesaplaması için alabiliriz
            let totalStudyTime = formatTimeString(seconds: getCurrentTotalSeconds())
            
            // LapsVal içindeki CreateCSV fonksiyonunu çağır
            return lapsVal.CreateCSV(
                startTime: "\(startTime)", // String formatında tarih
                timeUnit: currentUnitLabel,
                milis: milisDivisor,
                totalStudyTime: totalStudyTime
            )
        }
    private func formatTimeString(seconds: TimeInterval) -> String {
        let (h, m, s, ms) = secondsToComponents(seconds: seconds)
        return String(format: "%02d:%02d:%02d.%02d", h, m, s, ms)
    }
    
    private func updateStats() {
        let unit = ""//currentUnitLabel yerine "" yaz, 3basamaklı olunca sığmayacak
        let formatString = "%.\(precision)f %@"
        minCycleText = formatStat(value: lapsVal.min, unit: unit)
        maxCycleText = formatStat(value: lapsVal.max, unit: unit)
        avgCycleText = formatStat(value: lapsVal.mean, unit: unit)
        cpmText = String(format: formatString, lapsVal.cycPerMinute,"")
        cphText = String(format: formatString, lapsVal.cycPerHour,"")
    }
    
//    private func formatStat(value: Float, unit: String) -> String {
//        let convertedValue = value * milisDivisor
//        return String(format: "%.2f %@", convertedValue, unit)
//    }
    
    private func resetStatsText() {
        minCycleText = ""; maxCycleText = ""; avgCycleText = ""; cpmText = ""; cphText = ""
    }
    // Yardımcı fonksiyon
        private func recalculateChartData() {
            chartData = []
            for (index, cycleMinute) in lapsVal.cycleTimes.enumerated() {
                let convertedValue = Double(cycleMinute * Float(milisDivisor))
                chartData.append(LapChartItem(lapNumber: index + 1, value: convertedValue))
            }
        }
}
// Grafik için veri noktası modeli
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let lapNumber: Int
    let value: Double
}

// Grafik için hesaplama modeli
struct ChartViewModel {
    let dataPoints: [ChartDataPoint]
    let unit: String
    
    // Y Ekseni (Dikey) üst sınırı (Max değerin %10 fazlası)
    var maxY: Double {
        let maxVal = dataPoints.map { $0.value }.max() ?? 0
        return maxVal == 0 ? 10 : maxVal * 1.1
    }
    
    // Y Ekseni alt sınırı
    var minY: Double { dataPoints.map { $0.value }.min() ?? 0 }
    
    // Ortalama değer
    var avgY: Double {
        guard !dataPoints.isEmpty else { return 0 }
        return dataPoints.map { $0.value }.reduce(0, +) / Double(dataPoints.count)
    }
    
    // Değeri 0 ile 1 arasına sıkıştır (Ekrana çizmek için)
    func normalizedValue(_ value: Double) -> Double {
        guard maxY > 0 else { return 0 }
        return value / maxY
    }
    
}

// MARK: - ViewModel Extension
// Bu fonksiyonu ChronometerViewModel sınıfının içine de ekleyebilirsin,
// ama class dışından extension olarak eklemek daha temizdir.
extension ChronometerViewModel {
    
    // Bu bir FONKSİYON olmalı (var değil, func)
    func getChartViewModel() -> ChartViewModel {
        let points = lapsVal.cycleTimes.enumerated().map { (index, value) in
            // Seçili birime göre (Cmin/Sec) değeri çarpıyoruz
            // milisDivisor private olduğu için burada erişemiyorsan,
            // ChronometerViewModel içindeki milisDivisor'ı 'internal' veya 'public' yapmalısın.
            // Veya direkt logic'i buraya koy:
            let multiplier: Float = isCminUnit ? 100.0 : 60.0
            return ChartDataPoint(lapNumber: index + 1, value: Double(value * multiplier))
        }
        
        return ChartViewModel(dataPoints: points, unit: currentUnitLabel)
    }
}
