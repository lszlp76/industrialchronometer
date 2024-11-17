//
//  Laps.swift
//  industrialchronometer
//
//  Created by ulas özalp on 1.02.2022.
//

import Foundation
struct Laps {
    
    var hh ,mm, ss , msec, lapSay: Int
    var lapnote :String = ""
    var csvString : String = ""
    
    init(hour : Int, minute :Int, second : Int , msec : Int,lapnote:String,lapSay:Int){
        self.hh = hour
        self.mm = minute
        self.ss = second
        self.msec = msec
        self.lapnote = lapnote
        self.lapSay = lapSay
        
        
        
    }
    
    
    func LapToString (laps : Laps) -> String{
        
        let hh2String = laps.hh < 10 ? "0" + String ( laps.hh) : String ( laps.hh)
        let mm2String = laps.mm < 10 ? "0" + String ( laps.mm) : String ( laps.mm)
        let ss2String = laps.ss < 10 ? "0" + String ( laps.ss) : String ( laps.ss)
        let msec2String = laps.msec < 10 ? "0" + String (laps.msec) : String (laps.msec)
        let lapToString = hh2String + ":" + mm2String + ":" + ss2String + "." + msec2String
        return lapToString
        
    }
    mutating func CreateCSV(startTime : Date, timeUnit: String, lapsVal: [Float], lapToString : [Laps], milis : Float, maximumCycleTime : String, minimumCycleTime: String, averageCycleTime : String,totalStudyTime: String,totalCycleTime: String ,cyclePerMinute : String, cyclePerHour : String) -> String {
        var lapNumber = 0
        /*
         to prepare CSV file data and title
         */
        self.csvString = "Time Study Data Report \n"
        self.csvString = self.csvString.appending("Date, \(startTime) \n" )
        self.csvString = self.csvString.appending("Time Unit,\(timeUnit) \n")
        self.csvString = self.csvString.appending("Total Observation Time , \(totalStudyTime) \n")
        self.csvString = self.csvString.appending("Total Lap Time , \(totalCycleTime)\n")
        self.csvString = self.csvString.appending("Cycle per Minute , \(cyclePerMinute)\n")
        self.csvString = self.csvString.appending("Cycle per Hour , \(cyclePerHour)\n")
        
        
        self.csvString = self.csvString.appending("Maximum Cycle Time , \(maximumCycleTime)\n")
        self.csvString = self.csvString.appending("Minimum Cycle Time , \(minimumCycleTime)\n")
        self.csvString = self.csvString.appending("Average Cycle Time , \(averageCycleTime)\n\n")
        self.csvString = self.csvString.appending("Lap No , Lap Time , Cycle Time as \(timeUnit) ,Notes\n")
        
        /*
         this part for writing lap data in csv table
         */
        for lapValue in lapsVal
        {
            
            self.csvString = self.csvString.appending("\(lapNumber+1),\(LapToString(laps: lapToString[lapNumber])),\(String(format:"%.2f",lapValue * Float(milis))),\(lapToString[lapNumber].lapnote) \n")
            
            lapNumber += 1
        }
        
        return (csvString)
    }
    
}
