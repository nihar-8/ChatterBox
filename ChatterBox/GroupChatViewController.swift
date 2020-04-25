//  GroupChatViewController.swift
//  ChatterBox
//  Created by Deepak on 26/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit

class GroupChatViewController: UIViewController
{
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var chatTitle: UILabel!
    @IBOutlet weak var groupPic: UIImageView!
    @IBOutlet weak var msgHeight: NSLayoutConstraint!
    //MARK:- Variables
    var messages = NSMutableArray()
    var group = [String:String]()
    var image = UIImage(named: "defaultGroup")
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        chatTitle.text = group["name"]
        groupPic.image = image!
        if isConnectedToNetwork()
        {
            let query = Constants.refs.groupChats.child(group["uid"]!)
            _ = query.observe(.childAdded, with:
                { snapshot in
                    if  let data     = snapshot.value as? [String:String],
                        let message  = data["message"],
                        let uid      = data["uid"],
                        let name     = data["name"]
                    {
                        let p: [String: String] = ["uid": uid, "message": message, "name": name]
                        self.messages.add(p)
                        self.tableView.reloadData()
                    }
                })
        }
        else
        {
            createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again.", vc: self)
        }
        
    }
    //MARK:- SendMessage
    @IBAction func send(_ sender: Any)
    {
        if messageField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        {
            if isConnectedToNetwork()
            {
                let ref = Constants.refs.groupChats.child(group["uid"]!)
                let ref1 = ref.childByAutoId()
                let message = ["uid": UserDefaults.standard.string(forKey: "uid")!, "message": messageField.text!, "name": UserDefaults.standard.string(forKey: "name")!]
                ref1.setValue(message)
                messageField.text = ""
            }
            else
            {
                createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again.", vc: self)
            }
        }
    }
    //MARK:- Back
    @IBAction func back(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK:- TableviewDelegate/Datasource
extension GroupChatViewController: UITableViewDelegate, UITableViewDataSource
{
    //TODO: NumberOfRows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return messages.count
    }
    //TODO: CellForRow
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let msg = messages[indexPath.row] as! [String: String]
        if msg["uid"] == UserDefaults.standard.string(forKey: "uid")
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatOutgoingCell") as! GroupChatOutgoingCell
            cell.message.text = msg["message"]!
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatIncomingCell") as! GroupChatIncomingCell
            cell.message.text = msg["message"]!
            cell.name.text = msg["name"]!
            return cell
        }
    }
}
//MARK:- TextviewDelegate
extension GroupChatViewController: UITextViewDelegate
{
    func textViewDidChange(_ textView: UITextView)
    {
        let h = textView.contentSize.height
        if h < 50
        {
            textView.isScrollEnabled = true
            msgHeight.constant = 50
        }
        else if h > 200
        {
            textView.isScrollEnabled = true
            msgHeight.constant = 200
        }
        else
        {
            textView.isScrollEnabled = true
            msgHeight.constant = h
        }
    }
}

