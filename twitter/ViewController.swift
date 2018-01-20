//
//  ViewController.swift
//  twitter
//
//  Created by 原田　礼朗 on 2018/01/19.
//  Copyright © 2018年 reo harada. All rights reserved.
//

import UIKit

// tableViewと相談する準備その１
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    // ツイート入力フォーム
    @IBOutlet weak var tweetTextField: UITextField!
    // ツイートデータを表示するtableView
    @IBOutlet weak var tweetTableView: UITableView!
    // ツイートデータ
    var tweetData = [String]()
    // 更新するためのリフレッシュコントロール
    var refreshControl = UIRefreshControl()
    
    // 画面を読み込んだ時どうするぅ？
    override func viewDidLoad() {
        super.viewDidLoad()
        // リフレッシュコントロールの設定
        refreshControl.addTarget(self, action: #selector(ViewController.reloadData), for: .valueChanged)
        // リフレッシュコントロールをtableViewに追加
        tweetTableView.addSubview(refreshControl)
        // データを読み込む
        loadData()
    }
    
    // セクションの数どうするぅ？
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // セクション内の行数どうするぅ？
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetData.count
    }
    
    // 各行のセルの内容どうするぅ？
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tweetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tweetData[indexPath.row]
        return cell
    }
    
    // データを読み込む時どうするぅ？
    func loadData() {
        // データをmBaaSから取得してくれるNCMBQueryを呼んでくる
        let tweetQuery = NCMBQuery(className: "tweet")
        // mBaaSからデータを取得してもらう
        tweetQuery?.findObjectsInBackground({ (values, error) in
            // エラーでないとき
            if error == nil {
                // データをNCMBObjectの配列と保証する
                if let result = values as? [NCMBObject] {
                    // データを１つずつ見る
                    result.forEach({ (val) in
                        // "tweet"のデータを取得する
                        let tweet = val.object(forKey: "tweet") as! String
                        // "tweet"のデータをtweetData配列に追加する
                        self.tweetData.append(tweet)
                        // tweetTableViewを更新する
                        self.tweetTableView.reloadData()
                        // リフレッシュコントロールをストップする
                        self.refreshControl.endRefreshing()
                    })
                }
            }
        })
    }
    
    // mBaaSにデータを追加する
    func postData() {
        // データをmBaaSに登録してくれるNCMBObjectを呼んでくる
        let tweetObj = NCMBObject(className: "tweet")
        // tweetTextFieldに書いてある内容を取得する
        if let tweet = tweetTextField.text {
            // "tweet"にデータをセットする
            tweetObj?.setObject(tweet, forKey: "tweet")
            // "user"にツイートする人の名前をセットする
            tweetObj?.setObject("reo harada", forKey: "user")
            // mBaaSに保存する
            tweetObj?.saveInBackground({ (error) in
                // エラーでないとき
                if error == nil {
                    // tweetTextFieldの内容を空にする
                    self.tweetTextField.text = ""
                    // データを再読込する
                    self.reloadData()
                }
            })
        }
    }
    
    // 再読込された時どうするぅ？
    @objc func reloadData() {
        //　tweetDataの配列を初期化する
        tweetData = [String]()
        // データを読み込む
        loadData()
    }
    
    // 送信ボタン押された時どうするぅ？
    @IBAction func tapSendButton(_ sender: Any) {
        // データを送信する
        postData()
    }
    
}
