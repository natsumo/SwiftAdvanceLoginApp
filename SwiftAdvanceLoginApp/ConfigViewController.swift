//
//  ConfigViewController.swift
//  SwiftAdvanceLoginApp
//
//  Created by Ikeda Natsumo on 2017/01/26.
//  Copyright © 2017年 NIFTY Corporation. All rights reserved.
//

import UIKit
import NCMB

class ConfigViewController: UIViewController, UITextFieldDelegate {
    // メールアドレス
    @IBOutlet weak var mailAddressTextField: UITextField!
    // 引継用パスワード
    @IBOutlet weak var temporaryPassword: UITextField!
    // informationLabel
    @IBOutlet weak var informationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // セキュリティ入力
        temporaryPassword.isSecureTextEntry = true
        // informationLabelを空に
        informationLabel.text = ""
        // delegate
        mailAddressTextField.delegate = self
        temporaryPassword.delegate = self
        
    }
    
    // MARK:- 「登録ボタン」押下時の処理
    @IBAction func registMailAddress(_ sender: UIButton) {
        // informationLabelを空に
        informationLabel.text = ""
        
        // キーボードを閉じる
        mailAddressTextField.resignFirstResponder()
        temporaryPassword.resignFirstResponder()
        
        // 入力チェック(空白)
        if mailAddressTextField.text!.isEmpty || temporaryPassword.text!.isEmpty {
            self.informationLabel.text = "未入力の項目があります"
            
            return
            
        }
        
        // 入力チェック(メールアドレス)
        let email = mailAddressTextField.text! as String
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let range = email.range(of: emailRegEx, options: .regularExpression, range: nil, locale: nil)//.range(of: emailRegEx)
        let result = range != nil ? true : false
        if !result {
            self.informationLabel.text = "メールアドレスの形式が正しくありません"
            
            return
        }
        
        let pass = temporaryPassword.text! as String
        
        // MARK:- 引継認証処理(引継元)
        let currentUser = NCMBUser.current()
        currentUser?.setObject(email, forKey: "mailAddress")
        currentUser?.setObject(pass, forKey: "temporaryPass")
        currentUser?.saveInBackground({ (err) in
            if err != nil {
                let error = err as! NSError
                // 登録失敗時の処理
                print("登録に失敗しました:\(error)")
                self.informationLabel.text = "登録に失敗しました:\(error.code)_1"
                
            } else {
                // 登録成功時の処理
                // MARK:- 読み込み権限のみ解放とフラグの設定
                let user_acl = NCMBACL()
                user_acl.setPublicReadAccess(true)
                user_acl.setWriteAccess(true, for: currentUser)
                currentUser?.acl = user_acl
                currentUser?.setObject(true, forKey: "flag")
                currentUser?.saveInBackground({ (err_acl) in
                    if err_acl != nil {
                        let error_acl = err_acl as! NSError
                        // ACL設定失敗時の処理
                        print("登録に失敗しました::\(error_acl)")
                        self.informationLabel.text = "登録に失敗しました:\(error_acl.code)_2"
                        
                    } else {
                        // ACL設定成功時の処理
                        print("登録に成功しました")
                        self.informationLabel.text = "登録に成功しました"
                        
                    }
                })
            }
        })
    }
    
    // 背景をタップするとキーボードを隠す
    @IBAction func tapScreen(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // Returnキータップでキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        mailAddressTextField.resignFirstResponder()
        temporaryPassword.resignFirstResponder()
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
