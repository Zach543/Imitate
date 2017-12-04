//
//  UIViewController+Extension.swift
//  Imitate
//
//  Created by Zach Kobes on 11/22/17.
//  Copyright © 2017 Zach Kobes. All rights reserved.
//

import Foundation
import UIKit
import PopupDialog

extension UIViewController {
    func showPopup(_ viewController: UIViewController) {
        let popup = PopupDialog(viewController: viewController)
        present(popup, animated: true, completion: nil)
    }
    
    func showLoginView(authVC: CustomAuthPickerViewController) {
        let navc = UINavigationController(rootViewController: authVC)
        self.present(navc, animated: true, completion: nil)
    }
    
}
