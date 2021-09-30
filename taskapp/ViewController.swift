//
//  ViewController.swift
//  taskapp
//
//  Created by matsushitamasaki on 2021/09/27.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {

    var searchBar: UISearchBar!

    @IBOutlet weak var tableview: UITableView!
    
    let realm = try! Realm()
   
    var taskArray = try!Realm().objects(Task.self).sorted(byKeyPath: "date",ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableview.delegate = self
        tableview.dataSource = self
        setSearchBar()
    }
    
    func setSearchBar() {
        // NavigationBarにSearchBarをセット
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            //NavigationBarに適したサイズの検索バーを設置
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            //デリゲート
            searchBar.delegate = self
            //プレースホルダー
            searchBar.placeholder = "カテゴリーを検索"
            //検索バーのスタイル
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            //NavigationTitleが置かれる場所に検索バーを設置
            navigationItem.titleView = searchBar
            //NavigationTitleのサイズを検索バーと同じにする
            navigationItem.titleView?.frame = searchBar.frame
        }
    }
    
    //検索バーで入力する時
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        //キャンセルボタンを表示
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    //検索バーのキャンセルがタップされた時
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //キャンセルボタンを非表示
        searchBar.showsCancelButton = false
        //キーボードを閉じる
        searchBar.resignFirstResponder()
        
        searchBar.text = ""
        
        tableview.isHidden = false
        
        taskArray = realm.objects(Task.self)
        
        tableview.reloadData()
    }
 
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tableview.isHidden = false
            guard let searchtext = searchBar.text else { return }
            let result = realm.objects(Task.self).filter("category = '\(searchtext)'" )
            let count = result.count
        if count == 0{
            tableview.isHidden = true
            }else{
            taskArray = result
            }
            tableview.reloadData()
        }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableview.isHidden = false
   //検索する
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
                guard let searchtext = searchBar.text else { return }
                let result = realm.objects(Task.self).filter("category = '\(searchtext)'" )
                let count = result.count
            if count == 0{
                tableview.isHidden = true
            }else{
                taskArray = result
                }
                tableview.reloadData()
            }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
       }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = taskArray[indexPath.row]
        
                cell.textLabel?.text = task.title

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm"

                let dateString:String = formatter.string(from: task.date)
                cell.detailTextLabel?.text = dateString + "    カテゴリー" + task.category
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
            return .delete
        }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                    // 削除するタスクを取得する
                    let task = self.taskArray[indexPath.row]

                    // ローカル通知をキャンセルする
                    let center = UNUserNotificationCenter.current()
                    center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

                    // データベースから削除する
                    try! realm.write {
                        self.realm.delete(task)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }

                    // 未通知のローカル通知一覧をログ出力
                    center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                        for request in requests {
                            print("/---------------")
                            print(request)
                            print("---------------/")
                        }
                    }
                }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController

        if segue.identifier == "cellSegue" {
            let indexPath = self.tableview.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()

            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }

            inputViewController.task = task
        }
    }
    // 入力画面から戻ってきた時に TableView を更新させる
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            tableview.reloadData()
        }
}

