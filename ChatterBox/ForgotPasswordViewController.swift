//  ForgotPasswordViewController.swift
//  ChatterBox
//  Created by Deepak on 26/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController
{
    //MARK:- Outlets
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    //MARK:- ViewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    //MARK:- ResetPassword
    @IBAction func resetPassword(_ sender: Any)
    {
        if email.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" || password.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            createAlert(title: "Alert", message: "Please fill all the required fields and try again.", vc: self)
        }
        else if isConnectedToNetwork()
        {
            showProgress()
            Auth.auth().sendPasswordReset(withEmail: email.text!)
            { (error) in
                if let err = error
                {
                    dismissProgress()
                    createAlert(title: "Alert", message: err.localizedDescription, vc: self)
                }
                else
                {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                    dismissProgress()
                    createAlertWithPush(title: "Alert", message: "We have sent you a reset password link to your registered email.", vc: self, push: vc)
                }
            }
        }
        else
        {
            createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again.", vc: self)
        }
    }
    //AMRK:- Back
    @IBAction func back(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ForgotPasswordViewController: UITextFieldDelegate
{
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
