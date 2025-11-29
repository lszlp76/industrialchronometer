//
//  ChronometerIntents..swift
//  industrialchronometer
//
//  Created by ulas özalp on 24.11.2025.
//

import Foundation
import ActivityKit
import AppIntents
import SwiftUI

// iOS 16.2+ ve Widget Target'ı için
@available(iOS 16.1, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct StopTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop Timer"
    
    // İŞTE ARADIĞIN SİHİRLİ KOD BURADA:
    static var openAppWhenRun: Bool = false
    
    public init() { }
    
    func perform() async throws -> some IntentResult {
        // Aktif olan aktiviteyi bul ve öldür
        for activity in Activity<ChronometerWidgetAttributes>.activities {
            await activity.end(dismissalPolicy: .immediate)
        }
        return .result()
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct LapTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Lap Timer"
    
    // Lap alınca da uygulama açılmasın istiyorsan burayı da false yap
    static var openAppWhenRun: Bool = false
    
    public init() { }
    
    func perform() async throws -> some IntentResult {
        // NOT: Burası biraz daha komplekstir.
        // Live Activity sandbox içinde çalıştığı için ana ViewModel'e doğrudan erişemez.
        // Basitçe sadece arayüzü güncelleyeceksen content update yapabilirsin.
        // Ancak gerçek veriyi kaydetmek için ana app ile veri paylaşımı (AppGroup) gerekir.
        
        // Şimdilik sadece butona basıldığını göstermek için boş dönüyoruz:
        return .result()
    }
}
