//
//  LeaderboardTableViewCell.swift
//  Imitate
//
//  Created by Zach Kobes on 7/8/17.
//  Copyright © 2017 Zach Kobes. All rights reserved.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var level: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        date.alpha = 0
//        level.alpha = 0
    }
    
    func animateLabels() {
        date.alpha = 0
        level.alpha = 0
        UIView.animate(withDuration: 1.0, animations: {
            self.date.alpha = 1
            self.level.alpha = 1
        }, completion: {_ in
            
        })
    }

}
