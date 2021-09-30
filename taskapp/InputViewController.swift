//
//  InputViewController.swift
//  taskapp
//
//  Created by matsushitamasaki on 2021/09/27.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    
    let realm = try!Realm()
    
    var task: Task!
    
    @IBOutlet weak var textField1: UITextField!
    
    
    @IBOutlet weak var textView: UITextView!
    

    @IBOutlet weak var datepicker: UIDatePicker!
    
    
    @IBOutlet weak var categorytextField: UITextField!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
          let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
          self.view.addGestureRecognizer(tapGesture)
        textField1.text = task.title
          textView.text = task.contents
          datepicker.date = task.date
        categorytextField.text = task.category
      }

      @objc func dismissKeyboard(){
          // キーボードを閉じる
          view.endEditing(true)
      }
    override func viewWillDisappear(_ animated: Bool) {
            try! realm.write {
                self.task.title = self.textField1.text!
                self.task.contents = self.textView.text
                self.task.date = self.datepicker.date
                self.task.category = self.categorytextField.text!
                self.realm.add(self.task, update: .modified)
            }
            setNotification(task: task)
            super.viewWillDisappear(animated)
        }
    func setNotification(task: Task) {
            let content = UNMutableNotificationContent()
            // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
            if task.title == "" {
                content.title = "(タイトルなし)"
            } else {
                content.title = task.title
            }
            if task.contents == "" {
                content.body = "(内容なし)"
            } else {
                content.body = task.contents
            }
            content.sound = UNNotificationSound.default

            // ローカル通知が発動するtrigger（日付マッチ）を作成
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
            let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)

            // ローカル通知を登録
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error) in
                print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


