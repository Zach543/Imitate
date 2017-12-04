//
//  UserScore.swift
//  Imitate
//
//  Created by Zach Kobes on 11/27/17.
//  Copyright © 2017 Zach Kobes. All rights reserved.
//
import Foundation

struct UserScore {
    var name, id: String?
    var date: Date?
    var score: Int
}

extension UserScore: FirestoreModel {
    var documentID: String! {
        return id
    }
    
    init?(modelData: FirestoreModelData) {
        try? self.init(name: modelData.value(forKey: "name"),
                       id: modelData.documentID,
                       date: modelData.value(forKey: "date"),
                       score: modelData.value(forKey: "score"))
    }
}
