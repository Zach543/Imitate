//
//  LeaderboardViewController.swift
//  Imitate
//
//  Created by Zach Kobes on 7/6/17.
//  Copyright © 2017 Zach Kobes. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController {
    var leaderboardValues = [String : Int]()
    let userDefaults = UserDefaults.standard
    var shownIndexes : [IndexPath] = []
    var filteredKeys = Array<String>()

    @IBOutlet weak var leaderboardTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Your Leaderboard"
        leaderboardTable.delegate = self
        leaderboardTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        leaderboardValues = userDefaults.dictionary(forKey: "Leaderboard") as? [String : Int] ?? [String : Int]()
    }
    
    @IBAction func filterToggled(_ sender: UIButton) {
        filteredKeys = []
        for (k,_) in (Array(leaderboardValues).sorted {$0.1 > $1.1}) {
            filteredKeys.append(k)
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
        cell.date.text = nil
        cell.level.text = nil
        var keys = Array<String>()
        if filteredKeys.isEmpty {
            keys = sortedLeaderboardKeys()
        } else {
            keys = filteredKeys
        }
        cell.date.text = keys[indexPath.row]
        cell.level.text = String(describing: leaderboardValues[keys[indexPath.row]]!)
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
    
    private func sortedLeaderboardKeys() -> Array<String> {
        var keyArray = Array(leaderboardValues.keys)
        var dateArray = Array<Date>()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy h:mma"
        //convert to dates
        for key in keyArray {
            dateArray.append(formatter.date(from: key) ?? Date())
        }
        //sort
        dateArray.sort(by: {$0.compare($1) == .orderedDescending})
        //convert back to strings
        keyArray = []
        for date in dateArray {
            keyArray.append(formatter.string(from: date))
        }
        
        return keyArray
    }
}
