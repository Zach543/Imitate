//
//  StartViewController.swift
//  Imitate
//
//  Created by Zach Kobes on 6/14/17.
//  Copyright © 2017 Zach Kobes. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let ctx: CGContext = UIGraphicsGetCurrentContext()!
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
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }

}

