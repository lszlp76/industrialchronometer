//
//  LapsVal.swift
//  industrialchronometer
//  bu struct yakalanan laplerin oluşturduğu float dizi
// içindeki işlemler için kullanılır.
// cycltime dizisi lap sınıfı ile alınan diziyi temsil eder.
//  Created by ulas özalp on 1.02.2022.
//
//
//  LapsVal.swift
//  industrialchronometer
//
//  Created by ulas özalp on 1.02.2022.
//

import Foundation

// NOTE: This singleton is a code smell. The ViewController should manage its
// own state. We should look at removing this in a future refactor.
class TimerStartControl {
    static let timerStartControl = TimerStartControl()
    var timerStarted : Bool?
    private init() {}
}

struct LapsVal {
    
    // 1. LapsVal now owns the data
    var laps: [Laps] = []
    var cycleTimes: [Float] = []
    
    /// The number of laps currently recorded.
    var lapCount: Int {
        return laps.count
    }
    
    // MARK: - Core Logic
    
    /// Adds a new lap based on total accumulated seconds
        mutating func addLap(totalSeconds: Double, lapNote: String, milis: Float) -> (lap: Laps, cycleTime: Float) {
            
            // 1. Görsel bileşenleri hesapla (HH:MM:SS.MS)
            // Bu kısım sadece ekranda "00:01:45" yazmak için, matematiksel hesapta kullanılmayacak.
            let hh = Int(totalSeconds / 3600)
            let mm = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
            let ss = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
            let msec = Int((totalSeconds.truncatingRemainder(dividingBy: 1)) * 100)
            
            // 2. Yeni Lap Objesini Oluştur
            let newLap = Laps(hour: hh, minute: mm, second: ss, msec: msec, rawTime: totalSeconds, lapnote: lapNote, lapSay: lapCount + 1)
            
            // 3. Cycle Time Hesabı (Hassas)
            var delta: Double = 0.0
            
            if let previousLap = laps.last {
                // Şimdiki toplam süre - Önceki toplam süre
                delta = totalSeconds - previousLap.rawTime
            } else {
                // İlk tur: Direkt geçen süre
                delta = totalSeconds
            }
            
            // Dakika cinsinden cycle time'ı sakla (Endüstriyel standart)
            // Saniye -> Dakika dönüşümü
            let deltaMinutes = Float(delta / 60.0)
            
            // Verileri kaydet
            laps.append(newLap)
            cycleTimes.append(deltaMinutes)
            
            return (newLap, deltaMinutes)
        }
    
    /// Clears all recorded laps and cycle times.
    mutating func reset() {
        laps.removeAll()
        cycleTimes.removeAll()
    }
    
    // MARK: - Statistics (now as Computed Properties)
    
    // We check for 'isEmpty' to prevent division by zero crashes
    
    var min: Float {
        return cycleTimes.isEmpty ? 0.0 : GetMinimumOfLaps(laps: cycleTimes)
    }
    
    var max: Float {
        return cycleTimes.isEmpty ? 0.0 : GetMaximumOfLaps(laps: cycleTimes)
    }
    
    var mean: Float {
        return cycleTimes.isEmpty ? 0.0 : GetMeanOfLaps(laps: cycleTimes)
    }
    
    var cycPerMinute: Float {
        let mean = self.mean // 'self' is required in a struct property
        return (mean == 0) ? 0.0 : (1.0 / mean)
    }
    
    var cycPerHour: Float {
        let mean = self.mean
        return (mean == 0) ? 0.0 : (60.0 / mean)
    }

    // MARK: - CSV Report Generator
    
    // MARK: - CSV Report Generator (GÜNCELLENMİŞ)
        
        /// Generates a complete CSV report string for the study.
    // MARK: - CSV Report Generator (DÜZELTİLMİŞ)

    func CreateCSV(startTime: String, timeUnit: String, milis: Float, totalStudyTime: String) -> String {
        // 1. Gelen timeUnit "Cmin" mi kontrol et
        let isCminMode = (timeUnit == "Cmin")
        // Varsayılan değer: 2
        let p = UserDefaults.standard.integer(forKey: "PrecisionValue")
        let precision = (p == 0) ? 2 : p
        
        // YENİ: Format string'i oluştur
        let formatString = "%.\(precision)f"
        
        // YENİ: Bölge ayarını İngilizce (ABD) olarak sabitle.
        // Bu sayede ondalık ayırıcı her zaman NOKTA (.) olur. Excel karmaşası ve 1000 ile çarpılma sorunu biter.
        let usLocale = Locale(identifier: "en_US")
        
        // 2. İstatistikleri formatla
        let totalCycleTime = laps.last.map { $0.LapToString(isCmin: isCminMode) } ?? "00:00:00.00"
        
        // Tüm sayısal formatlamalara 'locale: usLocale' parametresini ekliyoruz:
        let maximumCycleTime = String(format: formatString, locale: usLocale, max * milis)
        let minimumCycleTime = String(format: formatString, locale: usLocale, min * milis)
        let averageCycleTime = String(format: formatString, locale: usLocale, mean * milis)
        let cyclePerMinuteStr = String(
            format: formatString,
            locale: usLocale,
            cycPerMinute
        )
        let cyclePerHourStr = String(
            format: formatString,
            locale: usLocale,
            cycPerHour
        )
        
        // 3. Rapor Başlığını Oluştur
        var csvString = "Time Study Data Report \n"
        csvString.append("Date, \(startTime) \n")
        csvString.append("Time Unit,\(timeUnit) \n")
        csvString.append("Total Observation Time , \(totalStudyTime) \n")
        csvString.append("Total Lap Time , \(totalCycleTime)\n")
        csvString.append("Cycle per Minute , \(cyclePerMinuteStr)\n")
        csvString.append("Cycle per Hour , \(cyclePerHourStr)\n")
        
        csvString.append("Maximum Cycle Time , \(maximumCycleTime)\n")
        csvString.append("Minimum Cycle Time , \(minimumCycleTime)\n")
        csvString.append("Average Cycle Time , \(averageCycleTime)\n\n")
        
        // Sütun Başlıkları
        csvString.append("Lap No , Lap Time , Cycle Time (\(timeUnit)) ,Notes\n")
        
        // 4. Verileri Listele
        for (index, lap) in laps.enumerated() {
            // Cycle Time değerini hesapla
            let cycleTimeValue = cycleTimes[index]
            
            // YENİ: Burada da usLocale kullanıyoruz
            let formattedCycleTime = String(format: formatString, locale: usLocale, cycleTimeValue * milis)
            
            // Not kısmında virgül varsa tırnak içine al (CSV güvenliği)
            let noteContent = lap.lapnote
            let safeNote = noteContent.contains(",") ? "\"\(noteContent)\"" : noteContent
            
            // LapTime string'i zaten Laps.swift içinde formatlanıyor, orası manuel olduğu için bozulmaz.
            csvString.append("\(lap.lapSay),\(lap.LapToString(isCmin: isCminMode)),\(formattedCycleTime),\(safeNote) \n")
        }
        
        return csvString
    }
    // MARK: - Private Stat Helpers
    
    private func GetMinimumOfLaps(laps: [Float]) -> Float {
        return laps.min() ?? 0.0
    }
    
    private func GetMaximumOfLaps(laps: [Float]) -> Float {
        return laps.max() ?? 0.0
    }
    
    private func GetMeanOfLaps(laps: [Float]) -> Float {
        let sum = laps.reduce(0, +)
        return sum / Float(laps.count)
    }
    
    // MARK: - Date Utilities (Misplaced, but kept for now)
    
    func setMomentTime() -> Date {
        return Date() // Simplified: this is just 'Date()'
    }
    
    func getObservationTime(start: Date, end: Date) -> String {
        let calendar = Calendar.current
        let diff = calendar.dateComponents([.hour, .minute, .second], from: start, to: end)
        let formattedStringDateDifference = String(format: "%02ld:%02ld:%02ld", diff.hour!, diff.minute!, diff.second!)
        return formattedStringDateDifference
    }
}
