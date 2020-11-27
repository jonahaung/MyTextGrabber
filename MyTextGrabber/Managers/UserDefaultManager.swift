//
//  UserDefaultManager.swift
//  Myanmar Text Grabber
//
//  Created by Aung Ko Min on 7/11/20.
//

import Foundation

let userDefaults = UserDefaultsManager()

final class UserDefaultsManager {
    
    private let defaults = UserDefaults.standard
    
    private let _isMyanmar = "isMyanmar"

   
    var isMyanmar: Bool {
        get {
            return defaults.bool(forKey: _isMyanmar)
        }
        set {
            updateObject(for: _isMyanmar, with: newValue)
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
