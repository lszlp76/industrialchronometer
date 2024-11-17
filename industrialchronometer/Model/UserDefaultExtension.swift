//
//  UserDefaultExtension.swift
//  industrialchronometer
//
//  Created by ulas özalp on 26.02.2022.
//

import Foundation
extension UserDefaults {
    /*
     USer defaults ta anahtar nokta set etme işlemini doğrudan değil bir değişkene atayarak yap
     aksi durumda o değeri tutmuyor. let olarak değil var olarak yazdırman lazım
     */
    func setValueForSwitch(value : Bool?, keyName: String){
        if value != nil{
            switch keyName  {
            case "CminUnit":
                var CminUnit = UserDefaults.standard.set(value,forKey: keyName)
            case "SecondUnit":
                var SecondUnit = UserDefaults.standard.set(value,forKey: keyName)
            case "ScreenSaver" :
                var ScreenSaver = UserDefaults.standard.set(value, forKey: keyName)
            case "PauseLap" :
                var PauseLap = UserDefaults.standard.set(value, forKey: keyName)
            case "ActivateOneHunderth":
                var ActivateOneHunderth = UserDefaults.standard.set(value, forKey: keyName)
            
            default:
                return 
            }
            
            
          }
        else {
           UserDefaults.standard.removeObject(forKey: keyName)
             }
    }
    
    func getValueForSwitch(keyName: String) -> Bool? {
        return UserDefaults.standard.bool(forKey: keyName)
    }
}
