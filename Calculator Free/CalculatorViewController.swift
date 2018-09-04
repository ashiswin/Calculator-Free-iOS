//
//  CalculatorViewController.swift
//  Calculator Free
//
//  Created by Isaac Ashwin on 4/9/18.
//  Copyright © 2018 Isaac Ashwin. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var lblMain: UILabel!
    
    var decimalPlaced:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func clearClicked(_ sender: Any) {
        if let text = lblMain.text {
            if text.last == "." {
                decimalPlaced = false
            }
            lblMain.text = String(text.dropLast())
            if (lblMain.text)!.count == 0 {
                lblMain.text = "0"
            }
        }
    }
    
    @IBAction func negateClicked(_ sender: Any) {
        if let text = lblMain.text {
            if text.first != "-" {
                lblMain.text = "-" + text
            }
            else {
                lblMain.text = String(text.dropFirst())
            }
        }
    }
    
    @IBAction func numberClicked(_ sender: Any) {
        if let btn = sender as? UIButton {
            if (btn.titleLabel?.text)! == "."{
                if !decimalPlaced {
                    lblMain.text = lblMain.text! + (btn.titleLabel?.text)!
                    decimalPlaced = true
                }
            }
            else {
                if (lblMain.text)!.first == "0" && (lblMain.text)!.count == 1 {
                    lblMain.text = (btn.titleLabel?.text)!
                }
                else {
                    lblMain.text = lblMain.text! + (btn.titleLabel?.text)!
                }
            }
        }
    }
    
    @IBAction func equalsClicked(_ sender: Any) {
        if (lblMain.text)! == "0.314" {
            performSegue(withIdentifier: "segMessaging", sender: nil)
        }
    }
}
