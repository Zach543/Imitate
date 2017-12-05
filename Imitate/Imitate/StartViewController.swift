//
//  StartViewController.swift
//  Imitate
//
//  Created by Zach Kobes on 6/14/17.
//  Copyright © 2017 Zach Kobes. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI
import Instructions

class StartViewController: UIViewController {

    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var leaderboardButton: UIButton!
    
    var authVC: CustomAuthPickerViewController!
    var authUI: FUIAuth?
    let dataLayer = DataLayer.sharedInstance
    let coachMarksController = CoachMarksController()
    let startHint = "Press start to begin a new game."
    let leaderboardHint = "Click leaderboard to view a global leaderboard."
    let helpHint = "Click this icon to view this tutorial again."
    let nextButtonText = "Ok"
    var showGameTutorial = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCoachMarks()
        setupAuth()
        startAnimations()
    }
    
    private func setupCoachMarks() {
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        let skipView = CoachMarkSkipDefaultView()
        skipView.setTitle("Skip", for: .normal)
        coachMarksController.skipView = skipView
        coachMarksController.overlay.allowTap = true
    }
    
    private func setupAuth() {
        authUI = FUIAuth.defaultAuthUI()
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            FUIFacebookAuth()
        ]
        authUI?.delegate = self
        authUI?.providers = providers
        
        //If no token present the login view
        if dataLayer.getToken() == nil || dataLayer.getToken() == "" {
            logOut()
        }
    }
    
    private func startAnimations() {
        animateBackground()
        animateStartButton()
    }
    
    private func animateStartButton() {
        startButton.layer.cornerRadius = startButton.frame.height / 2
        animateButtonSize(button: startButton)
    }
    
    private func animateButtonSize(button: UIButton) {
        UIView.animate(withDuration: 1, delay: 0.0, options: [.allowUserInteraction], animations: {
            button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: {_ in
            UIView.animate(withDuration: 1, delay: 0.0, options: [.allowUserInteraction], animations: {
                button.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: {_ in
                self.animateButtonSize(button: button)
            })
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        clearTextInButton(button: startButton)
    }
    
    func clearTextInButton(button: UIButton) {
        button.titleLabel?.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor.clear, for: .normal)
        let buttonSize: CGSize = button.bounds.size
        let font: UIFont = button.titleLabel!.font
        let attribs: [String : AnyObject] = [NSFontAttributeName: button.titleLabel!.font]
        let textSize: CGSize = button.titleLabel!.text!.size(attributes: attribs)
        UIGraphicsBeginImageContextWithOptions(buttonSize, false, UIScreen.main.scale)
        guard let ctx: CGContext = UIGraphicsGetCurrentContext() else {
            return
        }
        ctx.setFillColor(UIColor.white.cgColor)
        let center: CGPoint = CGPoint(x: buttonSize.width / 2 - textSize.width / 2, y: buttonSize.height / 2 - textSize.height / 2)
        let path: UIBezierPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height))
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        ctx.setBlendMode(.destinationOut)
        button.titleLabel!.text!.draw(at: center, withAttributes: [NSFontAttributeName: font])
        let viewImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let maskLayer: CALayer = CALayer()
        maskLayer.contents = ((viewImage.cgImage) as AnyObject)
        maskLayer.frame = button.bounds
        button.layer.mask = maskLayer
    }
    
    private func animateBackground() {
        UIView.animate(withDuration: 2, delay: 0.0, options: [.allowUserInteraction], animations: { () -> Void in
            self.view.backgroundColor = self.randomColor()
        }) { (Bool) -> Void in
            UIView.animate(withDuration: 2, delay: 0.0, options: [.allowUserInteraction], animations: { () -> Void in
                self.view.backgroundColor = self.randomColor()
            }, completion: { (Bool) -> Void in
                self.animateBackground()
            })
        }
    }
    
    private func randomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.coachMarksController.stop(immediately: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        let vc: GameViewController = segue.destination as! GameViewController
        vc.showTutorial = self.showGameTutorial
    }
    
    private func logOut() {
        if let authUI = authUI {
            do {
                try authUI.signOut()
                dataLayer.token = nil
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            authVC = CustomAuthPickerViewController(authUI: authUI)
            self.showLoginView(authVC: authVC)
        }
    }
        
    @IBAction func logoutPressed(_ sender: Any) {
        logOut()
    }
    
    @IBAction func helpButtonPressed(_ sender: Any) {
        coachMarksController.start(on: self)
        showGameTutorial = true
    }
    
}

extension StartViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else if let _ = user {
            dataLayer.token = user?.uid
            coachMarksController.start(on: self)
            showGameTutorial = true
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return CustomAuthPickerViewController(authUI: authUI)
    }
    
}

extension StartViewController: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)

        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = self.startHint
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 1:
            coachViews.bodyView.hintLabel.text = self.leaderboardHint
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 2:
            coachViews.bodyView.hintLabel.text = self.helpHint
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        default: break
        }

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch(index) {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: startButton)
        case 1:
            return coachMarksController.helper.makeCoachMark(for: leaderboardButton)
        case 2:
            return coachMarksController.helper.makeCoachMark(for: helpButton)
        default:
            return coachMarksController.helper.makeCoachMark()
        }
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 3
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, constraintsForSkipView skipView: UIView, inParent parentView: UIView) -> [NSLayoutConstraint]? {
        var constraints: [NSLayoutConstraint] = []

        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-100-[skipView]-100-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["skipView": skipView]))

        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[skipView(==44)]-32-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["skipView": skipView]))

        return constraints
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didHide coachMark: CoachMark, at index: Int) {
        if index == 3 {
            performSegue(withIdentifier: "startToGame", sender: self)
        }
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool) {
        showGameTutorial = false
    }
}
