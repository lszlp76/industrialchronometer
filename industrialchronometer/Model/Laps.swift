//
//  Laps.swift
//  industrialchronometer
//
//  Created by ulas özalp on 1.02.2022.
//

import Foundation
struct Laps {
    
    var hh ,mm, ss : Int
    
    init(hour : Int, minute :Int, second : Int){
        self.hh = hour
        self.mm = minute
        self.ss = second
    }
    
    func LapToString (laps : Laps) -> String{
        let hh2String = laps.hh < 10 ? "0" + String ( laps.hh) : String ( laps.hh)
       let mm2String = laps.mm < 10 ? "0" + String ( laps.mm) : String ( laps.mm)
        let ss2String = laps.ss < 10 ? "0" + String ( laps.ss) : String ( laps.ss)
        let lapToString = hh2String + ":" + mm2String + ":" + ss2String
        return lapToString
        
    }
}
