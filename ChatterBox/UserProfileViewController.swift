//  UserProfileViewController.swift
//  ChatterBox
//  Created by Deepak on 29/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit
import Firebase

class UserProfileViewController: UIViewController
{
    //MARK:- Outlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var email: UITextField!
    //MARK:- Variables
    var id = ""
    var user = [String:String]()
    //MARK:- ViewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let query = Constants.refs.users
        _ = query.observeSingleEvent(of: .value, with:
        { (snapshot) in
            showProgress()
            for child in snapshot.children
            {
                let snap = child as! DataSnapshot
                if snap.key == self.id
                {
                    let value = snap.value as! [String : Any]
                    let name = value["name"] as! String
                    let dob = value["dob"] as! String
                    let email = value["email"] as! String
                    let imgUrl = value["imgUrl"] as! String
                    self.user = ["name": name, "dob": dob, "email": email, "imgUrl": imgUrl]
                    self.updateUI()
                    break
                }
            }
        })
    }
    //MARK:- UpdateUI
    func updateUI()
    {
        if user["imgUrl"] == ""
        {
            profilePic.image = UIImage(named: "defaultUser")
        }
        else
        {
            let imgRef = Constants.refs.UserStorage.child(id)
            imgRef.getData(maxSize: 1 * 1024 * 1024)
            { data, error in
                if error != nil
                {
                    self.profilePic.image = UIImage(named: "defaultUser")
                    dismissProgress()
                }
                else
                {
                    self.profilePic.image = UIImage(data: data!)
                    dismissProgress()
                }
            }
        }
        name.text = user["name"]
        dob.text = user["dob"]
        email.text = user["email"]
    }
    //MARK:- SendRequest
    @IBAction func sendRequest(_ sender: Any)
    {
        createAlert(title: "Alert", message: "Work in progress.", vc: self)
    }
    //MARK:- Back
    @IBAction func back(_ sender: Any)
    {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersViewController") as! UsersViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
