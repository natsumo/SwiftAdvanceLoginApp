//
//  LoginConfigViewController.swift
//  SwiftAdvanceLoginApp
//
//  Created by Ikeda Natsumo on 2017/01/26.
//  Copyright © 2017年 NIFTY Corporation. All rights reserved.
//

import UIKit
import NCMB

class LoginConfigViewController: UIViewController, UITextFieldDelegate {
    // mailAddressTextField
    @IBOutlet weak var mailAddressTextField: UITextField!
    // temporaryPassword
    @IBOutlet weak var temporaryPassword: UITextField!
    // informationLabel
    @IBOutlet weak var informationLabel: UILabel!
    // UUID取得
    let uuid = UIDevice.current.identifierForVendor?.uuidString
    
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
    
    // MARK:- 「引き継ぐ」ボタン押下時の処理
    @IBAction func takeOverAccount(_ sender: UIButton) {
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
        
        // MARK:- 引き継ぎ処理が重複していないか確認する
        let query_check = NCMBUser.query()
        query_check?.whereKey("transferId", equalTo: uuid)
        query_check?.findObjectsInBackground({ (object, err_check) in
            if err_check != nil {
                let error_check = err_check as! NSError
                print("アカウントの引き継ぎに失敗しました:\(error_check)_0")
                self.informationLabel.text = "アカウントの引き継ぎに失敗しました:\(error_check.code)_0"

                
            } else if object?.count != 0 {
                print("アカウントの引き継ぎに失敗しました:別引継アカウントあり")
                self.informationLabel.text = "アカウントの引き継ぎに失敗しました:別引継アカウントあり"
                
            } else {
                // MARK:- 引継認証処理(引継先)
                let query = NCMBUser.query()
                query?.whereKey("mailAddress", equalTo: email)
                query?.whereKey("temporaryPass", equalTo: pass)
                query?.whereKey("flag", equalTo: true)
                query?.findObjectsInBackground({ (user0, err) in
                    if err != nil {
                        // 検索失敗時の処理
                        let error = err as! NSError
                        print("アカウントの引き継ぎに失敗しました:\(error)_1")
                        self.informationLabel.text = "アカウントの引き継ぎに失敗しました:\(error.code)_1"
                    } else if user0?.count != 1 {
                        print("アカウントの引き継ぎに失敗しました:該当なし")
                        self.informationLabel.text = "アカウントの引き継ぎに失敗しました:該当なし"
                    } else {
                        // 検索成功時の処理
                        let user =  user0?[0] as! NCMBUser
                        
                        // MARK:- 引継いだアカウントでログイン
                        NCMBUser.logInWithUsername(inBackground: user.userName, password: user.userName, block: { (newUser, err_newUser) in
                            if err_newUser != nil {
                                // ログイン失敗
                                let error_newUser = err_newUser as! NSError
                                print("アカウントの引き継ぎに失敗しました:\(error_newUser)_2")
                                self.informationLabel.text = "アカウントの引き継ぎに失敗しました:\(error_newUser.code)_2"
                            } else {
                                // ログイン成功
                                // MARK:- 新しい端末のUUIDをユーザー情報に追加
                                newUser?.setObject(self.uuid, forKey: "transferId")
                                newUser?.setObject(false, forKey: "flag")
                                newUser?.saveInBackground({ (err_newLogin) in
                                    if err_newLogin != nil {
                                        // 新UUID設定失敗
                                        let error_newLogin = err_newLogin as! NSError
                                        print("アカウントの引き継ぎに失敗しました:\(error_newLogin)_3")
                                        self.informationLabel.text = "アカウントの引き継ぎに失敗しました:\(error_newLogin.code)_3"
                                    } else {
                                        // 新UUID設定成功
                                        print("アカウントの引き継ぎに成功しました")
                                        self.informationLabel.text = "アカウントの引き継ぎに成功しました"
                                    }
                                })
                            }
                            
                        })
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
