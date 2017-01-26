//
//  MainViewController.swift
//  SwiftAdvanceLoginApp
//
//  Created by Ikeda Natsumo on 2017/01/26.
//  Copyright © 2017年 NIFTY Corporation. All rights reserved.
//

import UIKit
import NCMB

class MainViewController: UIViewController {
    // label
    @IBOutlet weak var greetingMessage: UILabel!
    @IBOutlet weak var lastVisit: UILabel!
    @IBOutlet weak var dayAndTime: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    // UUID取得
    let uuid = UIDevice.current.identifierForVendor?.uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // labelの初期化
        greetingMessage.text = ""
        lastVisit.text = ""
        dayAndTime.text = ""
        informationLabel.text = ""
        
        // MARK:- アカウントの引き継ぎ有無の確認
        let query = NCMBUser.query()
        query?.whereKey("transferId", equalTo: uuid)
        query?.findObjectsInBackground({ (transferUser0, transfer_err) in
            if transfer_err != nil {
                // 検索失敗時の処理
                let transfer_error = transfer_err as! NSError
                print("引継アカウントはありませんでした:\(transfer_error.code)")
            } else {
                // 検索成功時の処理
                if transferUser0?.count != 1 {
                    print("引継アカウントはありませんでした:該当なし")
                    self.autLogin(uuid: self.uuid!)
                    
                } else {
                    print("引継アカウントでログインします")
                    let transferUser = transferUser0?[0] as! NCMBUser
                    let transferUuid = transferUser.userName as String
                    self.autLogin(uuid: transferUuid)
                    
                }
                
            }
        })
        
        
        
    }
    
    // MARK:- 自動ログイン処理
    func autLogin(uuid: String) {
        NCMBUser.logInWithUsername(inBackground: uuid, password: uuid) { (user, login_err) in
            if login_err != nil {
                // ログイン失敗時の処理
                let login_error = login_err as! NSError
                self.informationLabel.text = "ログインに失敗しました:\(login_error.code)"
                print("ログインに失敗しました:\(login_error)")
                
                // MARK:- 初回利用（会員未登録）の場合
                if login_error.code == 401002 { // 401002:ID/Pass認証エラー
                    /* mBaaS会員登録 */
                    let new_user = NCMBUser()
                    
                    new_user.userName = uuid
                    new_user.password = uuid
                    new_user.signUpInBackground({ (signUp_err) in
                        if signUp_err != nil {
                            // 会員登録失敗時の処理
                            let signUp_error = signUp_err as! NSError
                            self.informationLabel.text = "会員登録に失敗しました:\(login_error.code)"
                            print("会員登録に失敗しました:\(signUp_error)")
                        } else {
                            // 会員登録成功時の処理
                            self.informationLabel.text = "会員登録に成功しました"
                            print("会員登録に成功しました。")
                            self.greetingMessage.text = "はじめまして！"
                            
                            // MARK:- データの保存とACLの設定
                            // ACL設定
                            let new_user_acl = NCMBACL()
                            /// read全員
                            new_user_acl.setPublicReadAccess(true)
                            /// write会員のみ
                            new_user_acl.setWriteAccess(true, for: new_user)
                            
                            let lastLoginDate = new_user.updateDate
                            new_user.acl = new_user_acl
                            new_user.setObject(lastLoginDate, forKey: "lastLoginDate")
                            new_user.saveInBackground({ (save_err) in
                                if save_err != nil {
                                    // 保存失敗時の処理
                                    let save_error = save_err as! NSError
                                    print("最終ログイン日時の保存に失敗しました:\(save_error.code)")
                                    
                                } else {
                                    // 保存成功時の処理
                                    print("最終ログイン日時の保存に成功しました")
                                    
                                }
                            })
                            
                        }
                    })
                }
                
            } else {
                // ログイン成功時の処理
                self.informationLabel.text = "ログインに成功しました"
                print("ログインに成功しました")
                
                self.greetingMessage.text = "おかえりなさい"
                self.lastVisit.text = "最終ログイン"
                
                // MARK:- 最終ログイン日時取得
                let lastLoginDate = user?.object(forKey: "lastLoginDate") as! Date
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                let dateStr = formatter.string(from: lastLoginDate)
                self.dayAndTime.text = "\(dateStr)"
                
                // MARK:- ログイン日時の上書き
                let updateDate = user?.updateDate
                user?.setObject(updateDate, forKey: "lastLoginDate")
                user?.saveInBackground({ (save_error) in
                    if save_error != nil {
                        // 保存失敗時の処理
                        let save_err = save_error as! NSError
                        print("最終ログイン日時の保存に失敗しました:\(save_err.code)")
                        
                    } else {
                        // 保存成功時の処理
                        print("最終ログイン日時の保存に成功しました")
                        
                    }
                    
                })
                
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
