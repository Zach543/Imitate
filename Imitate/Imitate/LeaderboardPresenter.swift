//
//  LeaderboardPresenter.swift
//  Imitate
//
//  Created by Zach Kobes on 11/28/17.
//  Copyright © 2017 Zach Kobes. All rights reserved.
//

import Foundation
import Firebase

protocol LeaderboardView {
    func setLeaderboard(userScores: [UserScore])
}

class LeaderboardPresenter {
    
    private var modelLayer = ModelLayer.sharedInstance
    private var view: LeaderboardView?
    private var leaderboardListener: ListenerRegistration?
    
    func setView(view: LeaderboardView) {
        self.view = view
    }
    
    func getLeaderboard(field: String?, descending: Bool?) {
        leaderboardListener = modelLayer.getLeaderboard(field: field, descending: descending, completion: { (userScores, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let userScores = userScores {
                self.view?.setLeaderboard(userScores: userScores)
            }
        })
    }

    func detachView() {
        view = nil
        leaderboardListener?.remove()
    }
}
