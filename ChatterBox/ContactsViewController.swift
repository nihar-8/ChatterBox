//  ContactsViewController.swift
//  ChatterBox
//  Created by Deepak on 24/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit

class ContactsViewController: UIViewController
{
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    //MARK:- Variables
    var contacts = NSMutableArray()
    var users = NSMutableArray()
    var img = [UIImage]()
    var names = [String]()
    //MARK:- ViewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        myIndex = 1
        if isConnectedToNetwork()
        {
            let query = Constants.refs.users.child(UserDefaults.standard.string(forKey: "uid")!).child("myContacts")
            _ = query.observe(.childAdded, with:
                { snapshot in
                    if let chatId  = snapshot.value as? String
                    {
                        let p: [String:String] = ["uid": snapshot.key, "chat_id": chatId]
                        if !self.contacts.contains(p)
                        {
                            self.contacts.add(p)
                            self.tableView.reloadData()
                        }
                    }
                })
            let query1 = Constants.refs.users
            _ = query1.observe(.childAdded, with:
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
                        }
                        
                    }
                })
        }
        else
        {
            createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again.", vc: self)
        }
    }
}
//MARK:- TableviewDelegate/Datasource
extension ContactsViewController: UITableViewDataSource, UITableViewDelegate
{
    //TODO: NumberOfRows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return contacts.count
    }
    //TODO: CellForRow
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
        let c_contact = contacts[indexPath.row] as! [String: String]
        for i in 0 ..< users.count
        {
            let c_user = users[i] as! [String:String]
            if c_user["uid"] == c_contact["uid"]
            {
                cell.name.text = c_user["name"]
                names.append(c_user["name"]!)
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
                break
            }
        }
        return cell
    }
    //TODO: DidSelectRow
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if isConnectedToNetwork()
        {
            let c_contact = contacts[indexPath.row] as! [String: String]
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            vc.chatId = c_contact["chat_id"]!
            vc.chatName = self.names[indexPath.row].components(separatedBy: " ").first!
            vc.image = self.img[indexPath.row]
            vc.flag = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again.", vc: self)
        }
    }
}
