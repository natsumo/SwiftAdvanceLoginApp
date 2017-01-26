//
//  StartViewController.swift
//  SwiftAdvanceLoginApp
//
//  Created by Ikeda Natsumo on 2017/01/26.
//  Copyright © 2017年 NIFTY Corporation. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK:- 「ログイン」ボタン押下時の処理
    @IBAction func login(_ sender: UIButton) {
        // 自動ログイン
        self.performSegue(withIdentifier: "toMain", sender: self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
