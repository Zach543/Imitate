//
//  GameViewController.swift
//  Imitate
//
//  Created by Zach Kobes on 6/14/17.
//  Copyright © 2017 Zach Kobes. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var yourTurnLabel: UIOutlinedLabel!
    
    var patterns = [[UIButton]]()
    let smallLabelTransform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    let largeLabelTransform = CGAffineTransform(scaleX: 1, y: 1)
    
    var userPlaying = false
    var userBtnPresses = [UIButton]()
    let maxPatterns = 100
    var nextIndex = 0
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPatterns()
        prepareLabels()
        navigationItem.title = "Good Luck."
    }
    
    private func loadPatterns() {
        var btnAmount = 2
        for _ in 0...maxPatterns {
            var newBtnPattern = [UIButton]()
            for _ in 1...btnAmount {
                let btnNum = arc4random_uniform(4) + 1
                newBtnPattern += [getBtn(number: Int(btnNum))]
            }
            patterns += [newBtnPattern]
            btnAmount += 1
        }
    }
    
    private func getBtn(number: Int) -> UIButton {
        switch number {
        case 1:
            return btn1
        case 2:
            return btn2
        case 3:
            return btn3
        case 4:
            return btn4
        default:
            return btn1
        }
    }
    
    private func prepareLabels() {
        yourTurnLabel.alpha = 0
        yourTurnLabel.transform = smallLabelTransform
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startGame()
    }
    
    private func startGame() {
        if patterns.indices.contains(nextIndex) {
            animatePattern(pattern: patterns[nextIndex])
        } else {
            self.animateLabel(text: "You've Finished The Game!", innerColor: UIColor.green, complete: {_ in
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    private func animatePattern(pattern: [UIButton]) {
        userPlaying = false
        userBtnPresses = []
        disableBtns()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.animateBtnsInPattern(pattern: pattern, complete: {_ in
                self.animateLabel(text: "Your Turn", innerColor: UIColor.white, complete: {_ in
                    self.enableBtns()
                })
            })
        })
    }
    
    private func animateLabel(text: String, innerColor: UIColor, complete: @escaping (_ result: Bool) -> Void) {
        self.yourTurnLabel.text = text
        self.yourTurnLabel.textColor = innerColor
        UIView.animate(withDuration: 0.5, animations: {
            self.yourTurnLabel.alpha = 1
            self.yourTurnLabel.transform = self.largeLabelTransform
        }, completion: {_ in
            UIView.animate(withDuration: 0.2, delay: 0.8, animations: {
                self.yourTurnLabel.alpha = 0
                self.yourTurnLabel.transform = self.smallLabelTransform
            }, completion: {_ in
                self.userPlaying = true
                complete(true)
            })
        })
    }
    
    private func animateBtnsInPattern(pattern: [UIButton], complete: @escaping (_ result: Bool) -> Void) {
        var newPattern = pattern
        if newPattern.isEmpty {
            complete(true)
        } else {
            animateBackgroundColor(sender: newPattern[0], complete: {_ in
                newPattern.remove(at: 0)
                self.animateBtnsInPattern(pattern: newPattern, complete: complete)
            })
        }
    }
    
    func animateBackgroundColor(sender: UIButton, complete: @escaping (_ result: Bool) -> Void) {
        if sender.backgroundColor == UIColor.black {
            UIView.animate(withDuration: 0.05, animations: {
                sender.backgroundColor = UIColor.white
            }, completion: {_ in
                UIView.animate(withDuration: 0.15, delay: 0.25, animations: {
                    sender.backgroundColor = UIColor.black
                }, completion: {_ in
                    complete(true)
                })
            })
        } else {
            UIView.animate(withDuration: 0.05, animations: {
                sender.backgroundColor = UIColor.black
            }, completion: {_ in
                UIView.animate(withDuration: 0.15, delay: 0.25, animations: {
                    sender.backgroundColor = UIColor.white
                }, completion: {_ in
                    complete(true)
                })
            })
        }
    }
    
    private func validatePress(btnPressed: UIButton) {
        var valid = false
        if userPlaying {
            userBtnPresses += [btnPressed]
            var index = 0
            while index < userBtnPresses.count {
                if userBtnPresses[index] == patterns[nextIndex][index] {
                    valid = true
                } else {
                    valid = false
                }
                index += 1
            }
            
            if userBtnPresses.count == patterns[nextIndex].count && valid {
                nextIndex += 1
                startGame()
            } else if userBtnPresses.count == patterns[nextIndex].count && !valid {
                showError(complete: {_ in
                    self.navigationController?.popViewController(animated: true)
                })
                return
            }
        }
        if !valid {
            showError(complete: {_ in
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    @IBAction func btn1Pressed(_ sender: UIButton) {
        animateBackgroundColor(sender: sender){_ in}
        validatePress(btnPressed: btn1)
    }

    @IBAction func btn2Pressed(_ sender: UIButton) {
        animateBackgroundColor(sender: sender){_ in}
        validatePress(btnPressed: btn2)
    }
    
    @IBAction func btn3Pressed(_ sender: UIButton) {
        animateBackgroundColor(sender: sender){_ in}
        validatePress(btnPressed: btn3)
    }
    
    @IBAction func btn4Pressed(_ sender: UIButton) {
        animateBackgroundColor(sender: sender){_ in}
        validatePress(btnPressed: btn4)
    }
    
    private func showError(complete: @escaping (_ result: Bool) -> Void) {
        self.btn1.alpha = 0
        self.btn2.alpha = 0
        self.btn3.alpha = 0
        self.btn4.alpha = 0
        disableBtns()
        self.animateLabel(text: "Failure!", innerColor: UIColor.white, complete: {_ in})
        UIView.animate(withDuration: 1.5, animations: {
            self.view.backgroundColor = UIColor.red
        }, completion: {_ in
            var leaderboardDict = [String : Int]()
            if let array = self.userDefaults.dictionary(forKey: "Leaderboard") as? [String : Int] {
                leaderboardDict = array
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy h:mma"
            let currentDate = formatter.string(from: Date())
            leaderboardDict[currentDate] = self.nextIndex
            self.userDefaults.set(leaderboardDict, forKey: "Leaderboard")
            complete(true)
        })
    }
    
    private func disableBtns() {
        btn1.isEnabled = false
        btn2.isEnabled = false
        btn3.isEnabled = false
        btn4.isEnabled = false
    }
    
    private func enableBtns() {
        btn1.isEnabled = true
        btn2.isEnabled = true
        btn3.isEnabled = true
        btn4.isEnabled = true
    }
}
