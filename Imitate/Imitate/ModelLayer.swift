//
//  ModelLayer.swift
//  Imitate
//
//  Created by Zach Kobes on 11/28/17.
//  Copyright © 2017 Zach Kobes. All rights reserved.
//

import Foundation
import Firebase

class ModelLayer {
    static let sharedInstance = ModelLayer()
    var collectionRef: CollectionReference!

    func getLeaderboard(field: String?, descending: Bool?, completion: @escaping ([UserScore]?, Error?) -> Void) -> ListenerRegistration {
        collectionRef = Firestore.firestore().collection("leaderboard")
        if let field = field,
            let descending = descending {
            return collectionRef.order(by: field, descending: descending).addListener(UserScore.self, completion: { (userScores, error) in
                completion(userScores, error)
            })
        } else {
            return collectionRef.addListener(UserScore.self, completion: { (userScores, error) in
                completion(userScores, error)
            })
        }
    }
    
    func saveScore(score: UserScore, completion: @escaping (Error?) -> Void) {
        collectionRef = Firestore.firestore().collection("leaderboard")
        return collectionRef.addDoc(score, complete: { (error) in
            completion(error)
        })
    }
}
