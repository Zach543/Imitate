//
//  CustomAuthPickerViewController.swift
//  Imitate
//
//  Created by Zach Kobes on 11/22/17.
//  Copyright © 2017 Zach Kobes. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuthUI

class CustomAuthPickerViewController: FUIAuthPickerViewController {

    override init(nibName: String?, bundle: Bundle?, authUI: FUIAuth) {
        super.init(nibName: "FUIAuthPickerViewController", bundle: bundle, authUI: authUI)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor.white
        self.navigationItem.leftBarButtonItems = []
        let loginLabel = UILabel()
        loginLabel.text = "Login to\nStart Playing"
        loginLabel.font = UIFont.systemFont(ofSize: 32, weight: UIFontWeightSemibold)
        loginLabel.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
        loginLabel.textColor = UIColor.black
        loginLabel.numberOfLines = 0
        loginLabel.sizeToFit()
        loginLabel.textAlignment = .center
        let verticalOffset:CGFloat = 100
        let x = (UIScreen.main.bounds.width - loginLabel.frame.width) / 2
        let y = (UIScreen.main.bounds.height - loginLabel.frame.height) / 2 - verticalOffset
        loginLabel.frame = CGRect(x: x, y: y, width: loginLabel.frame.width, height: loginLabel.frame.width)
        view.addSubview(loginLabel)
    }
    
}
