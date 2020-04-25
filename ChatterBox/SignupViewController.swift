//  SignupViewController.swift
//  ChatterBox
//  Created by Deepak on 24/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit
import Firebase

class SignupViewController: UIViewController
{
    //MARK:- Outlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    //MARK:- Variables
    var imagePicker = UIImagePickerController()
    var datePicker = UIDatePicker()
    //MARK:- ViewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        profilePic.image = UIImage(named: "defaultUser")!
        let tap = UITapGestureRecognizer(target: self, action: #selector(takePhoto))
        profilePic.addGestureRecognizer(tap)
        profilePic.isUserInteractionEnabled = true
        imagePicker.delegate = self
    }
    //MARK:- TakePhoto
    @objc func takePhoto()
    {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        alert.addColorInTitleAndMessage()
        self.present(alert, animated: true, completion: nil)
    }
    //TODO: OpenGallery
    func openGallery()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    //TODO: OpenCamera
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            createAlert(title: "Alert", message: "You don't have a camera.", vc: self)
        }
    }
    //MARK:- Back
    @IBAction func back(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK:- SecureText
    @IBAction func passwordSecureText(_ sender: UIButton)
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
    @IBAction func confirmPasswordSecuretext(_ sender: UIButton)
    {
        if confirmPassword.isSecureTextEntry
        {
            sender.setImage(UIImage(named: "show"), for: .normal)
        }
        else
        {
            sender.setImage(UIImage(named: "hide"), for: .normal)
        }
        confirmPassword.isSecureTextEntry = !confirmPassword.isSecureTextEntry
    }
    //MARK:- CreateAccount
    @IBAction func createAccount(_ sender: Any)
    {
        let fname = firstName.text!
        let lname = lastName.text!
        let email1 = email.text!
        let password1 = password.text!
        let cpassword = confirmPassword.text!
        let dob1 = dob.text!
        if fname.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lname.trimmingCharacters(in: .whitespacesAndNewlines) == "" || email1.trimmingCharacters(in: .whitespacesAndNewlines) == "" || password1.trimmingCharacters(in: .whitespacesAndNewlines) == "" || cpassword.trimmingCharacters(in: .whitespacesAndNewlines) == "" || dob1 == "Select Date"
        {
            createAlert(title: "Alert", message: "Please fill all the details and try again.", vc: self)
        }
        else if password1 != cpassword
        {
            createAlert(title: "Alert", message: "Passwords do not match. Check it and try again.", vc: self)
        }
        else if !isConnectedToNetwork()
        {
            createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again." , vc: self)
        }
        else
        {
            showProgress()
            Auth.auth().createUser(withEmail: email1, password: password1)
            { (result, error) in
                if let err = error
                {
                    dismissProgress()
                    createAlert(title: "Alert", message: err.localizedDescription, vc: self)
                }
                else
                {
                    let chngeReq = result?.user.createProfileChangeRequest()
                    chngeReq?.displayName = self.firstName.text! + " " + self.lastName.text!
                    chngeReq?.commitChanges
                    { (error) in
                        if let err = error
                        {
                            dismissProgress()
                            createAlert(title: "Alert", message: err.localizedDescription, vc: self)
                        }
                        else
                        {
                            var imgUrl = ""
                            result?.user.sendEmailVerification
                            { (error) in
                                if let err = error
                                {
                                    dismissProgress()
                                    createAlert(title: "Alert", message: err.localizedDescription, vc: self)
                                }
                                else
                                {
                                    if self.profilePic.image != UIImage(named: "defaultUser")
                                    {
                                        let img = self.profilePic.image!
                                        let data = img.pngData() as Data?
                                        let imgRef = Constants.refs.UserStorage.child((result?.user.uid)!)
                                        _ = imgRef.putData(data!, metadata: nil)
                                        {
                                            (metadata, error) in
                                            guard metadata != nil
                                            else
                                            {
                                                return
                                            }
                                            imgRef.downloadURL
                                            { (url, error) in
                                                guard let downloadURL = url
                                                else
                                                {
                                                    return
                                                }
                                                imgUrl = downloadURL.absoluteString
                                                let ref = Constants.refs.users.child((result?.user.uid)!)
                                                let msg = ["name": result?.user.displayName, "email": result?.user.email, "imgUrl": imgUrl, "dob": dob1]
                                                ref.setValue(msg)
                                                do
                                                {
                                                    try Auth.auth().signOut()
                                                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                                    dismissProgress()
                                                    createAlertWithPush(title: "Alert" , message: "Verification link has been sent to your email.", vc: self, push: vc)
                                                }
                                                catch let err
                                                {
                                                    dismissProgress()
                                                    createAlert(title: "Alert", message: err.localizedDescription, vc: self)
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        let ref = Constants.refs.users.child((result?.user.uid)!)
                                        let msg = ["name": result?.user.displayName, "email": result?.user.email, "imgUrl": imgUrl, "dob": dob1]
                                        ref.setValue(msg)
                                        do
                                        {
                                            try Auth.auth().signOut()
                                            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                            dismissProgress()
                                            createAlertWithPush(title: "Alert" , message: "Verification link has been sent to your email.", vc: self, push: vc)
                                        }
                                        catch let err
                                        {
                                            dismissProgress()
                                            createAlert(title: "Alert", message: err.localizedDescription, vc: self)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
//MARK:- UIImagePickerDelegate
extension SignupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    //TODO: DidFinishPickingMedia
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let myImage = info[.originalImage] as! UIImage
        let img: UIImage = (myImage.resizeWithWidth(width: 200))!
        self.profilePic.image = img
        picker.dismiss(animated: true, completion: nil)
    }
}
//MARK:- TextfieldDelegate
extension SignupViewController: UITextFieldDelegate
{
    //TODO: TextfieldBeginEditing
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if textField == dob
        {
            textField.resignFirstResponder()
            let dateChooserAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            datePicker.datePickerMode = .date
            var dateComp = DateComponents()
            dateComp.year = -16
            datePicker.maximumDate = Calendar.current.date(byAdding: dateComp, to: Date())
            dateComp.year = -100
            datePicker.minimumDate = Calendar.current.date(byAdding: dateComp, to: Date())
            datePicker.setValue(UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1), forKeyPath: "textColor")
            datePicker.setValue(false, forKey: "highlightsToday")
            dateChooserAlert.view.addSubview(datePicker)
            dateChooserAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler:
            { action in
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM, YYYY"
                self.dob.text = formatter.string(from: self.datePicker.date)
                self.email.becomeFirstResponder()
            }))
            let height: NSLayoutConstraint = NSLayoutConstraint(item: dateChooserAlert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.1, constant: 300)
            dateChooserAlert.view.addConstraint(height)
            dateChooserAlert.addColorInTitleAndMessage()
            self.present(dateChooserAlert, animated: true, completion: nil)
        }
    }
    //TODO: TextfieldShouldReturn
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        if textField == firstName
        {
            lastName.becomeFirstResponder()
        }
        else if textField == lastName
        {
            dob.becomeFirstResponder()
        }
        else if textField == email
        {
            password.becomeFirstResponder()
        }
        else if textField == password
        {
            confirmPassword.becomeFirstResponder()
        }
        return true
    }
}

