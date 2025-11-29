//
//  UserDefaulSettings.swift
//  industrialchronometer
//
//  Created by ulas özalp on 18.11.2025
//


import Foundation

extension UserDefaults {
    
    /// A private key struct to hold all our app's user default keys.
    private enum AppSettingKeys: String {
        case cminUnit = "CminUnit"
        case secondUnit = "SecondUnit"
        case pauseLap = "PauseLap"
        case screenSaver = "ScreenSaver"
        case activateOneHunderth = "ActivateOneHunderth"
    }
    
    // --- Our New Safe Properties ---
    
    var isCminUnit: Bool {
        get {
            // We use 'bool(forKey:)' which safely returns 'false' if the key doesn't exist.
            return bool(forKey: AppSettingKeys.cminUnit.rawValue)
        }
        set {
            setValue(newValue, forKey: AppSettingKeys.cminUnit.rawValue)
        }
    }
    
    var isSecondUnit: Bool {
        get {
            return bool(forKey: AppSettingKeys.secondUnit.rawValue)
        }
        set {
            setValue(newValue, forKey: AppSettingKeys.secondUnit.rawValue)
        }
    }
    
    var isPauseLapEnabled: Bool {
        get {
            return bool(forKey: AppSettingKeys.pauseLap.rawValue)
        }
        set {
            setValue(newValue, forKey: AppSettingKeys.pauseLap.rawValue)
        }
    }
    
    var isScreenSaverEnabled: Bool {
        get {
            return bool(forKey: AppSettingKeys.screenSaver.rawValue)
        }
        set {
            setValue(newValue, forKey: AppSettingKeys.screenSaver.rawValue)
        }
    }
    
    var isOneHundredthEnabled: Bool {
        get {
            return bool(forKey: AppSettingKeys.activateOneHunderth.rawValue)
        }
        set {
            setValue(newValue, forKey: AppSettingKeys.activateOneHunderth.rawValue)
        }
    }
    
    /*
     Note: Your original code had a 'getValueForSwitch' and 'setValueForSwitch'.
     This new approach is much cleaner. We can now delete those old,
     unused functions from your original code if they exist elsewhere.
    */
}

