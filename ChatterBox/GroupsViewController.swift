//  GroupsViewController.swift
//  ChatterBox
//  Created by Deepak on 25/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit
import Firebase

class GroupsViewController: UIViewController
{
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    //MARK:- Variables
    var groups = NSMutableArray()
    var myGroups = [String]()
    var img = [UIImage]()
    //MARK:- ViewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        myIndex = 2
        if isConnectedToNetwork()
        {
            let query = Constants.refs.users.child(UserDefaults.standard.string(forKey: "uid")!).child("myGroups")
            _ = query.observe(.childAdded, with:
                { snapshot in
                    if !self.myGroups.contains(snapshot.key)
                    {
                        self.myGroups.append(snapshot.key)
                        self.tableView.reloadData()
                    }
    
                })
            let query1 = Constants.refs.groups
            _ = query1.observe(.childAdded, with:
                {  snapshot in
                    if  let data        = snapshot.value as? [String: Any],
                        let admin       = data["admin"] as? String,
                        let admin_name  = data["admin_name"] as? String,
                        let name        = data["name"] as? String,
                        let imgUrl      = data["imgUrl"] as? String
                    {
                        let p: [String: String] = ["uid": snapshot.key, "name": name, "admin": admin, "imgUrl": imgUrl, "admin_name": admin_name]
                        if !self.groups.contains(p)
                        {
                            self.groups.add(p)
                            self.tableView.reloadData()
                        }
                    }
                })
        }
        else
        {
            createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again.", vc: self)
        }
    }
    //MARK:- CreateGroup
    @IBAction func createGroup(_ sender: Any)
    {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateGroupViewController") as! CreateGroupViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK:- TableviewDelegate/Datasource
extension GroupsViewController: UITableViewDelegate, UITableViewDataSource
{
    //TODO: NumberOfRows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return myGroups.count
    }
    //TODO: CellForRow
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell") as! GroupCell
        for i in 0 ..< self.groups.count
        {
            let c_group = self.groups[i] as! [String: String]
            if c_group["uid"] == self.myGroups[indexPath.row]
            {
                cell.groupName.text = c_group["name"]
                cell.admin.text = "Admin : " + c_group["admin_name"]!
                if c_group["imgUrl"] == ""
                {
                    self.img.append(UIImage(named: "defaultGroup")!)
                }
                else
                {
                    let ref = Constants.refs.GroupStorage.child(c_group["uid"]!)
                    ref.getData(maxSize: 1 * 1024 * 1024)
                    { data, error in
                        if error != nil
                        {
                            self.img.append(UIImage(named: "defaultGroup")!)
                        }
                        else
                        {
                            self.img.append(UIImage(data: data!)!)
                        }
                        cell.groupPic.image = self.img[indexPath.row]
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
            for i in 0 ..< self.groups.count
            {
                let c_group = self.groups[i] as! [String: String]
                if c_group["uid"] == self.myGroups[indexPath.row]
                {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupChatViewController") as! GroupChatViewController
                    vc.group = c_group
                    vc.image = self.img[indexPath.row]
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                }
            }
        }
        else
        {
            createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again.", vc: self)
        }
    }
}
