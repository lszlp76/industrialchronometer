//
//  ChronometerWidgetAttributes.swift
//  industrialchronometer
//
//  Created by ulas özalp on 16.11.2025.
//

import Foundation

import ActivityKit

struct ChronometerWidgetAttributes: ActivityAttributes {
    
    public struct ContentState: Codable, Hashable {
        // Kronometre çalışıyor mu?
        var isRunning: Bool
        
        // Çalışıyorsa: Hangi zamandan itibaren saymaya başlasın? (Örn: Şu an - Geçen Süre)
        var referenceDate: Date
        
        // Duruyorsa: Ekranda hangi metin yazsın? (Örn: "00:01:45.30")
        var staticTime: String
        var unit: String //"Sec" veya "Cmin" bilgisini tutacak
    }
    
    var studyName: String
}
