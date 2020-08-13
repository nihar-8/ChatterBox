//  UsersViewController.swift
//  ChatterBox
//  Created by Deepak on 24/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit
import Firebase

class UsersViewController: UIViewController
{
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    //MARK:- Variables
    var users = NSMutableArray()
    var contacts = NSMutableArray()
    var img = [UIImage]()
    var filtered = NSMutableArray()
    var names = NSMutableArray()
    //MARK:- ViewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        myIndex = 0
        if isConnectedToNetwork()
        {
            showProgress()
            let query = Constants.refs.users
            _ = query.observe(.childAdded, with:
                {  snapshot in
                    if  let data        = snapshot.value as? [String: Any],
                        let email       = data["email"] as? String,
                        let name        = data["name"] as? String,
                        let imgUrl      = data["imgUrl"] as? String,
                        snapshot.key    != UserDefaults.standard.string(forKey: "uid")
                    {
                        let p: [String: String] = ["uid": snapshot.key, "name": name, "email": email, "imgUrl": imgUrl]
                        if !self.users.contains(p)
                        {
                            self.users.add(p)
                            self.filtered.add(p)
                            self.names.add(p["name"]!)
                            self.tableView.reloadData()
                        }
                    }
                    dismissProgress()
                })
            let query1 = Constants.refs.users.child(UserDefaults.standard.string(forKey: "uid")!).child("myContacts")
            _ = query1.observe(.childAdded, with:
                { (snapshot) in
                    if let value = snapshot.value as? String
                    {
                        let p: [String: String] = ["uid": snapshot.key, "chat_id": value]
                        if !self.contacts.contains(p)
                        {
                            self.contacts.add(p)
                        }
                    }
                })
        }
        else
        {
            createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again.", vc: self)
        }
    }
    //MARK:- UpdateContacts
    func updateContacts()
    {
        let query = Constants.refs.users.child(UserDefaults.standard.string(forKey: "uid")!).child("myContacts")
            _ = query.observeSingleEvent(of: .value, with:
            { (snapshot) in
                for child in snapshot.children
                {
                    let snap = child as! DataSnapshot
                    let key = snap.key
                    let value = snap.value as! String
                    let p: [String: String] = ["uid": key, "chat_id": value]
                    self.contacts.add(p)
                }
            })
    }
    //MARK:- ScanQr
    @IBAction func scanQR(_ sender: Any)
    {
        let vc = QRScannerViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK:- TableviewDelegate/Datasource
extension UsersViewController: UITableViewDelegate, UITableViewDataSource
{
    //TODO: NumberOfRows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filtered.count
    }
    //TODO: CellForRow
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell
        let c_user = filtered[indexPath.row] as! [String:String]
        cell.name.text = c_user["name"]
        cell.email.text = c_user["email"]
        if c_user["imgUrl"] == ""
        {
            self.img.append(UIImage(named: "defaultUser")!)
        }
        else
        {
            let ref = Constants.refs.UserStorage.child(c_user["uid"]!)
            ref.getData(maxSize: 1 * 1024 * 1024)
            { data, error in
                if error != nil
                {
                    self.img.append(UIImage(named: "defaultUser")!)
                }
                else
                {
                    self.img.append(UIImage(data: data!)!)
                }
                cell.profilePic.image = self.img[indexPath.row]
            }
        }
        return cell
    }
    //TODO: DidSelectRow
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if isConnectedToNetwork()
        {
            let c_user = filtered[indexPath.row] as! [String:String]
            var chatId = ""
            for i in 0 ..< self.contacts.count
            {
                let k = self.contacts[i] as! [String: String]
                if k["uid"] == c_user["uid"]
                {
                    chatId = k["chat_id"]!
                    break
                }
            }
            if chatId == ""
            {
                var ref = Constants.refs.users.child(UserDefaults.standard.string(forKey: "uid")!)
                var myContacts = ref.child("myContacts")
                let ref1 = Constants.refs.chats.childByAutoId()
                var chatRef = myContacts.child(c_user["uid"]!)
                chatRef.setValue(ref1.key!)
                ref = Constants.refs.users.child(c_user["uid"]!)
                myContacts = ref.child("myContacts")
                chatRef = myContacts.child(UserDefaults.standard.string(forKey: "uid")!)
                chatRef.setValue(ref1.key!)
                chatId = ref1.key!
                updateContacts()
            }
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            vc.chatId = chatId
            vc.chatName = c_user["name"]!.components(separatedBy: " ").first!
            vc.image = self.img[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again.", vc: self)
        }
    }
}
//MARK:- TextfieldDelegate
extension UsersViewController: UITextFieldDelegate
{
    //TODO: Search
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let string1 = string
        let string2 = textField.text
        var finalString = ""
        if string.count > 0
        {
            finalString = string2! + string1
        }
        else if string2!.count > 0
        {
            finalString = String(string2!.dropLast())
        }
        filteredArray(searchString: finalString as NSString)
        return true
    }
    func filteredArray(searchString:NSString)
    {
        let predicate = NSPredicate(format: "SELF BEGINSWITH %@",searchString)
        filtered.removeAllObjects()
        let ab = names.filtered(using: predicate)
        for i in 0 ..< ab.count
        {
            for j in 0 ..< users.count
            {
                let c_user = users[j] as! [String:String]
                let c_name = ab[i] as! String
                if c_user["name"] == c_name
                {
                    filtered.add(users[j])
                    break
                }
            }
        }
        if ab.count == 0
        {
            for j in 0 ..< users.count
            {
                filtered.add(users[j])
            }
        }
        self.tableView.reloadData()
    }
}
