//
//  ChronometerWidget.swift
//  industrialchronometer
//
//  Created by ulas özalp on 22.11.2025.
//

import WidgetKit
import SwiftUI
import ActivityKit
import AppIntents

@available(iOS 16.2, *)
struct ChronometerWidget: Widget {
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ChronometerWidgetAttributes.self) { context in
            // MARK: - KİLİT EKRANI
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // GENİŞLETİLMİŞ MOD
                
                // SOL: İkon
                DynamicIslandExpandedRegion(.leading) {
                    Label("Time", systemImage: "timer")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // SAĞ: STOP (Sonlandırma) Butonu
                DynamicIslandExpandedRegion(.trailing) {
                   /* Link(destination: URL(string: "industrialchronometer://stop")!)*/
                    Button(intent: StopTimerIntent()) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                }
                
                // ORTA: Durum Bilgisi
                DynamicIslandExpandedRegion(.center) {
                    
                        Text(context.state.isRunning ? "Running " : "Paused")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                      
                    }
                    
                
                // ALT: Sayaç ve Kontrol Butonları (Lap, Pause/Resume)
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 12) {
                        // Sayaç
                        TimerView(state: context.state, font: .system(size: 40, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                        
                        // Kontrol Butonları
                        HStack(spacing: 20) {
                            // LAP BUTONU (Sadece çalışırken görünür)
                            if context.state.isRunning {
                                Link(destination: URL(string: "industrialchronometer://lap")!) {
                                    Label("Lap", systemImage: "flag.fill")
                                        .font(.caption).bold()
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 20)
                                        .background(Color.gray.opacity(0.3))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                }
                            }
                            
                            // PAUSE / RESUME BUTONU
                            if context.state.isRunning {
                                Link(destination: URL(string: "industrialchronometer://pause")!) {
                                    Label("Pause", systemImage: "pause.fill")
                                        .font(.caption).bold()
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 20)
                                        .background(Color.yellow)
                                        .foregroundColor(.black)
                                        .cornerRadius(12)
                                }
                            } else {
                                Link(destination: URL(string: "industrialchronometer://resume")!) {
                                    Label("Resume", systemImage: "play.fill")
                                        .font(.caption).bold()
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 20)
                                        .background(Color.green)
                                        .foregroundColor(.black)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                
            } compactLeading: {
                // KÜÇÜK MOD (SOL)
                Image(systemName: "timer")
                    .foregroundColor(context.state.isRunning ? .green : .yellow)
            } compactTrailing: {
                // KÜÇÜK MOD (SAĞ)
                Link(destination: URL(string: context.state.isRunning ? "industrialchronometer://pause" : "industrialchronometer://resume")!) {
                    Image(systemName: context.state.isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .foregroundColor(context.state.isRunning ? .yellow : .green)
                }
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(context.state.isRunning ? .green : .yellow)
            }
        }
    }
}

//// TimerView
//struct TimerView: View {
//    let state: ChronometerWidgetAttributes.ContentState
//    let font: Font
//    
//    var body: some View {
//        Text(state.staticTime)
//            .font(font)
//            .foregroundColor(state.isRunning ? .green : .yellow)
//            .monospacedDigit()
//            .contentTransition(.numericText())
//    }
//}
// TimerView (GÜNCELLENMİŞ: Otomatik Sayaç Özelliği)
struct TimerView: View {
    let state: ChronometerWidgetAttributes.ContentState
    let font: Font
    
    var body: some View {
        // Yan yana dizmek için HStack kullanıyoruz
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            // Eğer kronometre ÇALIŞIYORSA -> iOS'in Sistem Sayacını kullan (Akıcı döner)
            if state.isRunning {
                // referenceDate: Başlangıç zamanı
                // countsDown: false (Yukarı say)
                Text(timerInterval: state.referenceDate...Date.distantFuture, countsDown: false)
                    .font(font)
                    .foregroundColor(.green)
                    .monospacedDigit() // Rakamların titremesini engeller
                    .multilineTextAlignment(.center)
                Text("Second") // veya dinamik olması için: Text(state.unit)
                    .font(.system(size: 20, weight: .bold)) // Sayıdan biraz daha küçük font
                    .foregroundColor(.green.opacity(0.7))
            }
            
            // Eğer kronometre DURUYORSA -> Bizim gönderdiğimiz özel formatı (Cmin/Milisaniye) göster
            else {
                Text(state.staticTime)
                    .font(font)
                    .foregroundColor(.yellow)
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
            }
        }
    }
}
// MARK: - Lock Screen UI (Stop + Lap Butonları)
struct LockScreenView: View {
    let context: ActivityViewContext<ChronometerWidgetAttributes>

    var body: some View {
        ZStack {
            // Arka Plan
            Image("futuristik.png")
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            // İçerik
            VStack(alignment: .center) {
                // Üst Bar: Başlık ve Stop Butonu
                HStack {
                    Text(context.attributes.studyName)
                        .font(.headline)
                        .shadow(color: .black, radius: 2)
                    Spacer()
                    
                    // STOP BUTONU
                    /*Link(destination: URL(string: "industrialchronometer://stop")!) */
                    Button(intent: StopTimerIntent()){
                        HStack(spacing: 4) {
                            Text("STOP").font(.caption2).bold()
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                        }
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(20)
                        .shadow(radius: 3)
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal)

                // Sayaç
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    TimerView(state: context.state, font: .system(size: 45, weight: .bold))
                        .shadow(color: .black.opacity(0.8), radius: 3, x: 2, y: 2)
                }
                .padding(.vertical, 5)

                // Alt Bar: Kontrol Butonları
                HStack(spacing: 40) {
                    
                    // LAP BUTONU (Sadece çalışırken)
                    if context.state.isRunning {
                        Link(destination: URL(string: "industrialchronometer://lap")!) {
                            VStack(spacing: 2) {
                                Image(systemName: "flag.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                Text("Lap")
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                        }
                    }
                    
                    // PAUSE / RESUME BUTONU
                    Link(destination: URL(string: context.state.isRunning ? "industrialchronometer://pause" : "industrialchronometer://resume")!) {
                        HStack {
                            Image(systemName: context.state.isRunning ? "pause.fill" : "play.fill")
                            Text(context.state.isRunning ? "PAUSE" : "RESUME")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 30)
                        .background(context.state.isRunning ? Color.yellow : Color.green)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                }
                .padding(.bottom, 15)
            }
            .foregroundColor(.white)
        }
        .background(Color.clear)
    }
}
// MARK: - PREVIEWS
// MARK: - PREVIEWS
#if DEBUG
import SwiftUI
import WidgetKit

// Örnek (Dummy) Veriler
extension ChronometerWidgetAttributes {
    static var previewAttributes: ChronometerWidgetAttributes {
        ChronometerWidgetAttributes(studyName: "Kaizen Study 01")
    }
}

extension ChronometerWidgetAttributes.ContentState {
    // Senaryo 1: Çalışıyor (Running) - Saniye Modu
    static var runningState: ChronometerWidgetAttributes.ContentState {
        ChronometerWidgetAttributes.ContentState(
            isRunning: true,
            referenceDate: Date(),
            staticTime: "00:00:00",
            unit: "Sec"
            // lastLapDisplay satırını SİLDİK
        )
    }
    
    // Senaryo 2: Durdu (Paused) - Cmin Modu
    static var pausedState: ChronometerWidgetAttributes.ContentState {
        ChronometerWidgetAttributes.ContentState(
            isRunning: false,
            referenceDate: Date(),
            staticTime: "45.50", // Cmin formatı
            unit: "Cmin"
            // lastLapDisplay satırını SİLDİK
        )
    }
}

// 1. KİLİT EKRANI ÖNİZLEMESİ
@available(iOS 16.2, *)
#Preview("Lock Screen", as: .content, using: ChronometerWidgetAttributes.previewAttributes) {
    ChronometerWidget()
} contentStates: {
    ChronometerWidgetAttributes.ContentState.runningState
    ChronometerWidgetAttributes.ContentState.pausedState
}

// 2. DYNAMIC ISLAND (GENİŞLETİLMİŞ) ÖNİZLEMESİ
@available(iOS 16.2, *)
#Preview("Island Expanded", as: .dynamicIsland(.expanded), using: ChronometerWidgetAttributes.previewAttributes) {
    ChronometerWidget()
} contentStates: {
    ChronometerWidgetAttributes.ContentState.runningState
    ChronometerWidgetAttributes.ContentState.pausedState
}

// 3. DYNAMIC ISLAND (COMPACT) ÖNİZLEMESİ
@available(iOS 16.2, *)
#Preview("Island Compact", as: .dynamicIsland(.compact), using: ChronometerWidgetAttributes.previewAttributes) {
    ChronometerWidget()
} contentStates: {
    ChronometerWidgetAttributes.ContentState.runningState
}

#endif
