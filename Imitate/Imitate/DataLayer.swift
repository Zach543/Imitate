//
//  DataLayer.swift
//  Imitate
//
//  Created by Zach Kobes on 11/27/17.
//  Copyright © 2017 Zach Kobes. All rights reserved.
//

import Foundation

class DataLayer: NSObject {
    static let sharedInstance = DataLayer()
    
    var token: String? {
        set {
            print("setting token to: \(newValue ?? "")")
            UserDefaults.standard.setValue(newValue, forKey: "com.game.imitate.token")
        }
        get {
            let tok = UserDefaults.standard.string(forKey: "com.game.imitate.token")
            print("token is: \(tok ?? "")")
            return tok
        }
    }

}

extension DataLayer {
    func getToken() -> String? {
        return token
    }
}

