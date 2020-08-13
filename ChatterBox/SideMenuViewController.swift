//  SideMenuViewController.swift
//  ChatterBox
//  Created by Deepak on 24/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit
import Firebase

class SideMenuViewController: UIViewController
{
    //MARK:- Outlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    //MARK:- ViewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        profilePic.image = UIImage(data: UserDefaults.standard.data(forKey: "profilePic")!)!
        userName.text = UserDefaults.standard.string(forKey: "name")!
        setImages()
    }
    //MARK:- SetImages
    func setImages()
    {
        if myIndex == 0
        {
            userImage.isHidden = false
            contactImage.isHidden = true
            groupImage.isHidden = true
            profileImage.isHidden = true
        }
        else if myIndex == 1
        {
            userImage.isHidden = true
            contactImage.isHidden = false
            groupImage.isHidden = true
            profileImage.isHidden = true
        }
        else if myIndex == 2
        {
            userImage.isHidden = true
            contactImage.isHidden = true
            groupImage.isHidden = false
            profileImage.isHidden = true
        }
        else
        {
            userImage.isHidden = true
            contactImage.isHidden = true
            groupImage.isHidden = true
            profileImage.isHidden = false
        }
    }
    //MARK:- Users
    @IBAction func users(_ sender: Any)
    {
        if myIndex != 0
        {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersViewController") as! UsersViewController
            self.navigationController?.pushViewController(vc, animated: true)
            myIndex = 0
            setImages()
        }
    }
    //MARK:- Contacts
    @IBAction func contacts(_ sender: Any)
    {
        if myIndex != 1
        {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
            self.navigationController?.pushViewController(vc, animated: true)
            myIndex = 1
            setImages()
        }
    }
    //MARK:- Groups
    @IBAction func groups(_ sender: Any)
    {
        if myIndex != 2
        {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupsViewController") as! GroupsViewController
            self.navigationController?.pushViewController(vc, animated: true)
            myIndex = 2
            setImages()
        }
    }
    //MARK:- Profile
    @IBAction func profile(_ sender: Any)
    {
        if myIndex != 3
        {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            self.navigationController?.pushViewController(vc, animated: true)
            myIndex = 3
            setImages()
        }
    }
    //MARK:- SignOut
    @IBAction func signOut(_ sender: Any)
    {
        if isConnectedToNetwork()
        {
            showProgress()
            do
            {
                try Auth.auth().signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                let ref1 = Constants.refs.users.child(UserDefaults.standard.string(forKey: "uid")!).child("isActive")
                ref1.setValue(false)
                resetUserDefaults()
                dismissProgress()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            catch let err
            {
                dismissProgress()
                createAlert(title: "Alert", message: err.localizedDescription, vc: self)
            }
        }
        else
        {
            createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again.", vc: self)
        }
    }
}
