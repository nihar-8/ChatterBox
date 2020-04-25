//  LoginViewController.swift
//  ChatterBox
//  Created by Deepak on 24/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit
import Firebase

class LoginViewController: UIViewController
{
    //MARK:- Outlets
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    //MARK:- ViewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    //MARK:- LoginButton
    @IBAction func loginButton(_ sender: Any)
    {
        let email1 = email.text!
        let password1 = password.text!
        if email1.trimmingCharacters(in: .whitespacesAndNewlines) == "" || password1.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            createAlert(title: "Alert", message: "Please fill all the details and try again.", vc: self)
        }
        else if !isConnectedToNetwork()
        {
            createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again.", vc: self)
        }
        else
        {
            showProgress()
            Auth.auth().signIn(withEmail: email1, password: password1)
            { (result, error) in
                if error == nil
                {
                    if !(result?.user.isEmailVerified)!
                    {
                        dismissProgress()
                        createAlert(title: "Alert", message: "Please verify your email and try again.", vc: self)
                    }
                    else
                    {
                        UserDefaults.standard.set(result?.user.uid, forKey: "uid")
                        UserDefaults.standard.set(result?.user.email, forKey: "email")
                        UserDefaults.standard.set(result?.user.displayName, forKey: "name")
                        let ref = Constants.refs.UserStorage.child(UserDefaults.standard.string(forKey: "uid")!)
                        ref.getData(maxSize: 1 * 1024 * 1024)
                        { data, error in
                            if error != nil
                            {
                                let imgD = UIImage(named: "defaultUser")!.pngData()!
                                UserDefaults.standard.set(imgD, forKey: "profilePic")
                            }
                            else
                            {
                                UserDefaults.standard.set(data!, forKey: "profilePic")
                            }
                        }
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersViewController") as! UsersViewController
                        dismissProgress()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                else
                {
                    dismissProgress()
                    createAlert(title: "Alert", message: error!.localizedDescription, vc: self)
                }
            }
        }
    }
    //MARK:- SecureText
    @IBAction func secureText(_ sender: UIButton)
    {
        if password.isSecureTextEntry
        {
            sender.setImage(UIImage(named: "show"), for: .normal)
        }
        else
        {
            sender.setImage(UIImage(named: "hide"), for: .normal)
        }
        password.isSecureTextEntry = !password.isSecureTextEntry
    }
    //MARK:- ForgotPassword
    @IBAction func forgotPassword(_ sender: Any)
    {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK:- TextFieldDelegate
extension LoginViewController: UITextFieldDelegate
{
    //TODO: TextfieldShouldReturn
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        if textField == email
        {
            password.becomeFirstResponder()
        }
        return true
    }
}
