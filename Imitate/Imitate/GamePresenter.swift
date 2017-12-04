//
//  GamePresenter.swift
//  Imitate
//
//  Created by Zach Kobes on 11/28/17.
//  Copyright © 2017 Zach Kobes. All rights reserved.
//

import Foundation
import Firebase

protocol GameView {
    func scoreSaved(error: Error?)
}

class GamePresenter {
    
    private var modelLayer = ModelLayer.sharedInstance
    private var view: GameView?
    
    func setView(view: GameView) {
        self.view = view
    }
    
    func saveScore(score: Int) {
        if let currentUser = Auth.auth().currentUser {
            let userScore = UserScore(name: currentUser.displayName, id: nil, date: Date(), score: score)
            modelLayer.saveScore(score: userScore, completion: { (error) in
                self.view?.scoreSaved(error: error)
            })
        }
    }

    func detachView(view: GameView) {
        self.view = nil
    }

}
