//
//  Laps.swift
//  industrialchronometer
//
//  Created by ulas özalp on 1.02.2022.
//  Refactored on 24.11.2025
//

import Foundation

/// Represents a single lap record.
struct Laps {
    
    // Veri tiplerini Int'ten Double'a çekiyoruz (Float da olur ama Double daha hassastır)
        var hh, mm, ss, msec: Int // Bunlar tam sayı kalabilir (gösterim için)
        var rawTime: Double // YENİ: Ham süreyi (dakika veya saniye cinsinden) saklayalım
        var lapSay: Int
        var lapnote: String = ""
        
        init(hour: Int, minute: Int, second: Int, msec: Int, rawTime: Double, lapnote: String, lapSay: Int) {
            self.hh = hour
            self.mm = minute
            self.ss = second
            self.msec = msec
            self.rawTime = rawTime // Hesaplamalarda bunu kullanacağız
            self.lapnote = lapnote
            self.lapSay = lapSay
        }
    
    // GÜNCELLENEN FONKSİYON
        // Parametre olarak 'isCmin' alıyor.
        func LapToString(isCmin: Bool) -> String {
            if isCmin {
                // Cmin Formülü: (Saniye / 60) * 100
                // rawTime zaten toplam saniyeyi tutuyor.
                let cminValue = (rawTime / 60.0) * 100.0
                let hh2String = String(format: "%02d", self.hh)
                let mm2String = String(format: "%02d", self.mm)
                let ss2String = String(format: "%02d",Int(cminValue))
                let msec2String = String(format: "%02d", self.msec)
                
                // İstersen virgülden sonraki hane sayısını buradan ayarlayabilirsin (%.2f veya %.3f)
                return "\(hh2String):\(mm2String):\(ss2String).\(msec2String)"
            } else {
                // Standart Saat Formatı
                // (Eski kodundaki gibi)
                let hh2String = String(format: "%02d", self.hh)
                let mm2String = String(format: "%02d", self.mm)
                let ss2String = String(format: "%02d", self.ss)
                let msec2String = String(format: "%02d", self.msec)
                
                return "\(hh2String):\(mm2String):\(ss2String).\(msec2String)"
            }
        }// DÜZELTME: CreateCSV fonksiyonu buradan silindi.
    // Bu görev artık LapsVal struct'ına aittir.
}
