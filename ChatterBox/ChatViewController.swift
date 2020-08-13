//  ChatViewController.swift
//  ChatterBox
//  Created by Deepak on 24/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit
import Firebase

class ChatViewController: UIViewController
{
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatTitle: UILabel!
    @IBOutlet weak var messgaeField: UITextView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var msgHeight: NSLayoutConstraint!
    @IBOutlet weak var video: UIButton!
    @IBOutlet weak var audio: UIButton!
    //MARK:- Variables
    var messages = NSMutableArray()
    var chatId = ""
    var chatName = ""
    var image = UIImage(named: "dafaultUser")
    var flag = true
    //MARK:- ViewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        chatTitle.text = chatName
        profilePic.image = image!
        video.isHidden = flag
        audio.isHidden = flag
        if isConnectedToNetwork()
        {
            showProgress()
            let query = Constants.refs.chats.child(chatId)
            _ = query.observe(.childAdded, with:
                { snapshot in
                    if  let data     = snapshot.value as? [String:String],
                        let message  = data["message"],
                        let uid      = data["uid"]
                    {
                        let p: [String: String] = ["uid": uid, "message": message]
                        self.messages.add(p)
                        self.tableView.reloadData()
                    }
                })
            dismissProgress()
        }
        else
        {
            createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again.", vc: self)
        }
    }
    //MARK:- SendMessage
    @IBAction func send(_ sender: Any)
    {
        if messgaeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        {
            if isConnectedToNetwork()
            {
                let ref = Constants.refs.chats.child(chatId)
                let ref1 = ref.childByAutoId()
                let message = ["uid": UserDefaults.standard.string(forKey: "uid")!, "message": messgaeField.text!]
                ref1.setValue(message)
                messgaeField.text = ""
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
    //MARK:- AudioCall
    @IBAction func audioCall(_ sender: UIButton)
    {
        createAlert(title: "Alert", message: "Work In Progress. \(chatId)", vc: self)
    }
    //MARK:- VideoCall
    @IBAction func videoCall(_ sender: UIButton)
    {
        createAlert(title: "Alert", message: "Work In Progress. \(chatId)", vc: self)
    }
}
//MARK:- TableviewDelegate/Datasource
extension ChatViewController: UITableViewDelegate, UITableViewDataSource
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatOutgoingCell") as! ChatOutgoingCell
            cell.message.text = msg["message"]!
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatIncomingCell") as! ChatIncomingCell
            cell.message.text = msg["message"]!
            return cell
        }
    }
}
//MARK:- TextviewDelegate
extension ChatViewController: UITextViewDelegate
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
