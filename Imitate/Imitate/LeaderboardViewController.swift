//
//  LeaderboardViewController.swift
//  Imitate
//
//  Created by Zach Kobes on 7/6/17.
//  Copyright © 2017 Zach Kobes. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController {
    var leaderboardValues = [UserScore]()
    let presenter = LeaderboardPresenter()
    var finishedLoadingInitialTableCells = false
    var orderded = false

    @IBOutlet weak var leaderboardTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setView(view: self)
        navigationItem.title = "Global Leaderboard"
        leaderboardTable.delegate = self
        leaderboardTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.getLeaderboard(field: nil, descending: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter.detachView()
    }
    
    @IBAction func filterToggled(_ sender: UIButton) {
        if orderded {
            presenter.getLeaderboard(field: "score", descending: false)
            orderded = false
        } else {
            presenter.getLeaderboard(field: "score", descending: true)
            orderded = true
        }
        leaderboardTable.reloadData()
    }
    
}

extension LeaderboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderboardTable.dequeueReusableCell(withIdentifier: "leaderboardCell") as! LeaderboardTableViewCell
        let score = leaderboardValues[indexPath.row]
        cell.name.text = nil
        cell.level.text = nil
        cell.name.text = score.name
        cell.level.text = String(describing: score.score)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var lastInitialDisplayableCell = false
        
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if leaderboardValues.count > 0 && !finishedLoadingInitialTableCells {
            if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows,
                let lastIndexPath = indexPathsForVisibleRows.last, lastIndexPath.row == indexPath.row {
                lastInitialDisplayableCell = true
            }
        }

        if !finishedLoadingInitialTableCells {
            if lastInitialDisplayableCell {
                finishedLoadingInitialTableCells = true
            }
            
            cell.alpha = 0
            let duration: Double = 0.3
            let delay = Double(indexPath.row) * (duration / 2)
            let transform = CATransform3DTranslate(CATransform3DIdentity, cell.frame.width, 0, 0)
            cell.layer.transform = transform
            UIView.animate(withDuration: duration, delay: delay, animations: {
                cell.alpha = 1
                cell.layer.transform = CATransform3DIdentity
            })
        }
    }
}

extension LeaderboardViewController: LeaderboardView {
    func setLeaderboard(userScores: [UserScore]) {
        leaderboardValues = userScores
        leaderboardTable.reloadData()
    }
}
