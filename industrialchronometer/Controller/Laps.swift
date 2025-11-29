//
//  Laps.swift
//  industrialchronometer
//
//  Created by ulas özalp on 1.02.2022.
//

import Foundation

struct Laps {
    
    var hh, mm, ss, msec, lapSay: Int
    var lapnote: String
    
    init(hour: Int, minute: Int, second: Int, msec: Int, lapnote: String, lapSay: Int) {
        self.hh = hour
        self.mm = minute
        self.ss = second
        self.msec = msec
        self.lapnote = lapnote
        self.lapSay = lapSay
    }
    
    func LapToString(laps: Laps) -> String {
        
        let hh2String = laps.hh < 10 ? "0" + String(laps.hh) : String(laps.hh)
        let mm2String = laps.mm < 10 ? "0" + String(laps.mm) : String(laps.mm)
        let ss2String = laps.ss < 10 ? "0" + String(laps.ss) : String(laps.ss)
        let msec2String = laps.msec < 10 ? "0" + String(laps.msec) : String(laps.msec)
        
        let lapToString = hh2String + ":" + mm2String + ":" + ss2String + "." + msec2String
        return lapToString
    }
}
