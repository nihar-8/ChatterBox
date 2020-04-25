//  SelectMembersViewController.swift
//  ChatterBox
//  Created by Deepak on 25/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit
import Firebase

class SelectMembersViewController: UIViewController
{
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    //MARK: Variables
    var users = NSMutableArray()
    var name = ""
    var data: Data?
    var selectedIndices = [Int]()
    //MARK:- ViewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if isConnectedToNetwork()
        {
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
    //MARK:- Back
    @IBAction func back(_ sender: Any)
    {
        self.selectedIndices.removeAll()
        self.navigationController?.popViewController(animated: true)
    }
    //MARK:- CreateGroup
    @IBAction func createGroup(_ sender: Any)
    {
        if self.selectedIndices.count == 0
        {
            createAlert(title: "Alert", message: "Please select atleast 1 member and try again.", vc: self)
        }
        else if isConnectedToNetwork()
        {
            showProgress()
            let groupRef = Constants.refs.groups.childByAutoId()
            if let data = self.data
            {
                let imgRef = Constants.refs.GroupStorage.child(groupRef.key!)
                _ = imgRef.putData(data, metadata: nil)
                { metadata, error in
                    guard metadata != nil
                    else
                    {
                        return
                    }
                    imgRef.downloadURL
                    { (url, error) in
                        guard let downloadUrl = url
                        else
                        {
                            return
                        }
                        var members = [String]()
                        for i in 0 ..< self.selectedIndices.count
                        {
                            let c_user = self.users[self.selectedIndices[i]] as! [String: String]
                            members.append(c_user["uid"]!)
                        }
                        members.append(UserDefaults.standard.string(forKey: "uid")!)
                        var ref = Constants.refs.users.child(UserDefaults.standard.string(forKey: "uid")!).child("myGroups").child(groupRef.key!)
                        ref.setValue(members)
                        let det = ["name": self.name, "members": members, "admin": UserDefaults.standard.string(forKey: "uid")!, "admin_name": UserDefaults.standard.string(forKey: "name")!, "imgUrl": downloadUrl.absoluteString] as [String : Any]
                        groupRef.setValue(det)
                        for i in 0 ..< self.selectedIndices.count
                        {
                            let c_user = self.users[self.selectedIndices[i]] as! [String: String]
                            ref = Constants.refs.users.child(c_user["uid"]!).child("myGroups").child(groupRef.key!)
                            ref.setValue(members)
                        }
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupsViewController") as! GroupsViewController
                        dismissProgress()
                        createAlertWithPush(title: "Alert", message: "Group created successfully.", vc: self, push: vc)
                    }
                }
            }
            else
            {
                var members = [String]()
                for i in 0 ..< self.selectedIndices.count
                {
                    let c_user = self.users[self.selectedIndices[i]] as! [String: String]
                    members.append(c_user["uid"]!)
                }
                members.append(UserDefaults.standard.string(forKey: "uid")!)
                var ref = Constants.refs.users.child(UserDefaults.standard.string(forKey: "uid")!).child("myGroups").child(groupRef.key!)
                ref.setValue(members)
                let det = ["name": self.name, "members": members, "admin": UserDefaults.standard.string(forKey: "uid")!, "imgUrl": ""] as [String : Any]
                groupRef.setValue(det)
                for i in 0 ..< self.selectedIndices.count
                {
                    let c_user = self.users[self.selectedIndices[i]] as! [String: String]
                    ref = Constants.refs.users.child(c_user["uid"]!).child("myGroups").child(groupRef.key!)
                    ref.setValue(members)
                }
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupsViewController") as! GroupsViewController
                dismissProgress()
                createAlertWithPush(title: "Alert", message: "Group created successfully.", vc: self, push: vc)
            }
        }
    }
}
//MARK:- TableviewDelegate/Datasource
extension SelectMembersViewController: UITableViewDelegate, UITableViewDataSource
{
    //TODO: NumberOfRows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return users.count
    }
    //TODO: CellForRow
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell") as! MemberCell
        let c_user = users[indexPath.row] as! [String:String]
        cell.username.text = c_user["name"]
        cell.email.text = c_user["email"]
        if c_user["imgUrl"] == ""
        {
            cell.profilePic.image = UIImage(named: "defaultUser")
        }
        else
        {
            let ref = Constants.refs.UserStorage.child(c_user["uid"]!)
            ref.getData(maxSize: 1 * 1024 * 1024)
            { data, error in
                if error != nil
                {
                    cell.profilePic.image = UIImage(named: "defaultUser")
                }
                else
                {
                    cell.profilePic.image = UIImage(data: data!)
                }
            }
        }
        if self.selectedIndices.contains(indexPath.row)
        {
            cell.tick.isHidden = false
        }
        else
        {
            cell.tick.isHidden = true
        }
        return cell
    }
    //TODO: DidSelectRow
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if self.selectedIndices.contains(indexPath.row)
        {
            self.selectedIndices.remove(at: (self.selectedIndices.firstIndex(of: indexPath.row)!))
        }
        else
        {
            self.selectedIndices.append(indexPath.row)
        }
        self.tableView.reloadData()
    }
}
