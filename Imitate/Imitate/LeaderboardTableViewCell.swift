//
//  LeaderboardTableViewCell.swift
//  Imitate
//
//  Created by Zach Kobes on 7/8/17.
//  Copyright © 2017 Zach Kobes. All rights reserved.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var level: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        name.alpha = 0
//        level.alpha = 0
    }
    
    func animateLabels() {
        name.alpha = 0
        level.alpha = 0
        UIView.animate(withDuration: 1.0, animations: {
            self.name.alpha = 1
            self.level.alpha = 1
        }, completion: {_ in
            
        })
    }

}
