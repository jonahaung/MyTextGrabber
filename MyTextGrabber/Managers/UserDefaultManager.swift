//
//  UserDefaultManager.swift
//  Myanmar Text Grabber
//
//  Created by Aung Ko Min on 7/11/20.
//

import Foundation



final class UserDefaultsManager: ObservableObject {
    
    static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults.standard
    
   
    let _languageMode = "languageMode"

    var languageMode: LanguageMode {
        get {
            return LanguageMode(rawValue: defaults.integer(forKey: _languageMode)) ?? .Myanmar
        }
        set {
            updateObject(for: _languageMode, with: newValue.rawValue)
            objectWillChange.send()
        }
    }
}

extension UserDefaultsManager {
    
    func updateObject(for key: String, with data: Any?) {
         defaults.set(data, forKey: key)
         defaults.synchronize()
     }
     
     //removing
     func removeObject(for key: String) {
         defaults.removeObject(forKey: key)
     }
    
     func currentStringObjectState(for key: String) -> String? {
         return defaults.string(forKey: key)
     }
     
     func currentIntObjectState(for key: String) -> Int? {
         return defaults.integer(forKey: key)
     }
     
     func currentBoolObjectState(for key: String) -> Bool {
         return defaults.bool(forKey: key)
     }
     
     func currentDoubleObject(for key: String) -> Double? {
         return defaults.double(forKey: key)
     }
     func currentFloatObject(for key: String) -> Float? {
         return defaults.float(forKey: key)
     }
    
    
}
