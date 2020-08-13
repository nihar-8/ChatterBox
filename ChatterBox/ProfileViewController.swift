//  ProfileViewController.swift
//  ChatterBox
//  Created by Deepak on 25/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit
import Firebase

class ProfileViewController: UIViewController
{
    //MARK:- Outlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmNewPassword: UITextField!
    @IBOutlet weak var password: UITextField!
    //MARK:- Variables
    var user = [String:String]()
    var imagePicker = UIImagePickerController()
    //MARK:- ViewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        myIndex = 3
        showProgress()
        let query = Constants.refs.users
        _ = query.observeSingleEvent(of: .value, with:
        { (snapshot) in
            for child in snapshot.children
            {
                let snap = child as! DataSnapshot
                if snap.key == UserDefaults.standard.string(forKey: "uid")!
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
        name.text = user["name"]
        dob.text = user["dob"]
        email.text = user["email"]
        profilePic.image = UIImage(data: UserDefaults.standard.data(forKey: "profilePic")!)!
        dismissProgress()
        let tap = UITapGestureRecognizer(target: self, action: #selector(takePhoto))
        profilePic.addGestureRecognizer(tap)
        profilePic.isUserInteractionEnabled = true
        imagePicker.delegate = self
    }
    //MARK:- MyQr
    @IBAction func myQr(_ sender: Any)
    {
        let alert = UIAlertController(title: "My QR Code", message: "", preferredStyle: .alert)
        let imageView = UIImageView(frame: CGRect(x: 30, y: 52, width: 196, height: 196))
        imageView.contentMode = .scaleAspectFit
        imageView.image = generateQRCode(from: UserDefaults.standard.string(forKey: "uid")!)
        alert.view.addSubview(imageView)
        let height = NSLayoutConstraint(item: alert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        let width = NSLayoutConstraint(item: alert.view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        alert.view.addConstraint(height)
        alert.view.addConstraint(width)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        alert.addColorInTitleAndMessage()
        self.present(alert, animated: true, completion: nil)
    }
    //MARK:- QRGenerator
    func generateQRCode(from string: String) -> UIImage?
    {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator")
        {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform).tinted(using: UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1))
            {
                return UIImage(ciImage: output)
            }
        }
        return nil
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
    //MARK:- SaveChanges
    @IBAction func saveChanges(_ sender: Any)
    {
        if name.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            createAlert(title: "Alert", message: "Please enter a name and try again.", vc: self)
        }
        else
        {
            if isConnectedToNetwork()
            {
                showProgress()
                if profilePic.image == UIImage(named: "defaultUser")
                {
                    let user = Auth.auth().currentUser!
                    let chngeReq = user.createProfileChangeRequest()
                    chngeReq.displayName = self.name.text!
                    chngeReq.commitChanges
                    { (error) in
                        if let err = error
                        {
                            dismissProgress()
                            createAlert(title: "Alert", message: err.localizedDescription, vc: self)
                        }
                        else
                        {
                            let ref = Constants.refs.users.child(UserDefaults.standard.string(forKey: "uid")!).child("name")
                            ref.setValue(self.name.text!)
                            UserDefaults.standard.set(self.name.text!, forKey: "name")
                            let img = self.profilePic.image!.pngData()!
                            UserDefaults.standard.set(img, forKey: "profilePic")
                            dismissProgress()
                            createAlert(title: "Alert", message: "Profile updated successfully.", vc: self)
                        }
                    }
                }
                else
                {
                    let user = Auth.auth().currentUser!
                    let chngeReq = user.createProfileChangeRequest()
                    chngeReq.displayName = self.name.text!
                    chngeReq.commitChanges
                    { (error) in
                        if let err = error
                        {
                            dismissProgress()
                            createAlert(title: "Alert", message: err.localizedDescription, vc: self)
                        }
                        else
                        {
                            let img = self.profilePic.image!
                            let data = img.pngData() as Data?
                            let imgRef = Constants.refs.UserStorage.child(UserDefaults.standard.string(forKey: "uid")!)
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
                                    let imgUrl = downloadURL.absoluteString
                                    let ref = Constants.refs.users.child(UserDefaults.standard.string(forKey: "uid")!)
                                    var ref1 = ref.child("name")
                                    ref1.setValue(self.name.text!)
                                    ref1 = ref.child("imgUrl")
                                    ref1.setValue(imgUrl)
                                    UserDefaults.standard.set(self.name.text!, forKey: "name")
                                    let img = self.profilePic.image!.pngData()!
                                    UserDefaults.standard.set(img, forKey: "profilePic")
                                    dismissProgress()
                                    createAlert(title: "Alert", message: "Profile updated successfully.", vc: self)
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again." , vc: self)
            }
        }
    }
    //MARK:- ChangePassword
    @IBAction func changePassword(_ sender: Any)
    {
        if oldPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" || newPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" || confirmNewPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            createAlert(title: "Alert", message: "Please fill all the required fields and try again.", vc: self)
        }
        else if newPassword.text! != confirmNewPassword.text!
        {
            createAlert(title: "Alert", message: "New passwords do not match.", vc: self)
        }
        else if !isConnectedToNetwork()
        {
            createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again." , vc: self)
        }
        else
        {
            oldPassword.text = ""
            newPassword.text = ""
            confirmNewPassword.text = ""
            showProgress()
            let user = Auth.auth().currentUser
            var credential: AuthCredential
            credential = EmailAuthProvider.credential(withEmail: UserDefaults.standard.string(forKey: "email")!, password: oldPassword.text!)
            user?.reauthenticate(with: credential)
            { result, error in
                if let error = error
                {
                    dismissProgress()
                    createAlert(title: "Alert", message: error.localizedDescription, vc: self)
                }
                else
                {
                    Auth.auth().currentUser?.updatePassword(to: self.newPassword.text!)
                    { (error) in
                        if let err = error
                        {
                            dismissProgress()
                            createAlert(title: "Alert", message: err.localizedDescription, vc: self)
                        }
                        else
                        {
                            dismissProgress()
                            createAlert(title: "Alert", message: "Password changed successfully.", vc: self)
                        }
                    }
                }
            }
        }
    }
    //MARK:- DeleteAccount
    @IBAction func deleteAccount(_ sender: Any)
    {
        if password.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            createAlert(title: "Alert", message: "Please enter your password and try again.", vc: self)
        }
        else if !isConnectedToNetwork()
        {
            createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again." , vc: self)
        }
        else
        {
            showProgress()
            let user = Auth.auth().currentUser
            var credential: AuthCredential
            credential = EmailAuthProvider.credential(withEmail: UserDefaults.standard.string(forKey: "email")!, password: password.text!)
            user?.reauthenticate(with: credential)
            { result, error in
                if let error = error
                {
                    dismissProgress()
                    createAlert(title: "Alert", message: error.localizedDescription, vc: self)
                }
                else
                {
                    Auth.auth().currentUser?.delete(completion:
                    { (error) in
                        if let err = error
                        {
                            dismissProgress()
                            createAlert(title: "Alert", message: err.localizedDescription, vc: self)
                        }
                        else
                        {
                            let query = Constants.refs.users.child(UserDefaults.standard.string(forKey: "uid")!).child("myContacts")
                            _ = query.observeSingleEvent(of: .value, with:
                                { (snapshot) in
                                    for child in snapshot.children
                                    {
                                        let snap = child as! DataSnapshot
                                        let key = snap.key
                                        let value = snap.value as! String
                                        var query1 = Constants.refs.users.child(key).child("myContacts").child(UserDefaults.standard.string(forKey: "uid")!)
                                        query1.removeValue()
                                        query1 = Constants.refs.chats.child(value)
                                        query1.removeValue()
                                    }
                                })
                            let ref = Constants.refs.users.child(UserDefaults.standard.string(forKey: "uid")!)
                            ref.removeValue()
                            let imgRef = Constants.refs.UserStorage.child(UserDefaults.standard.string(forKey: "uid")!)
                            imgRef.delete
                            { (error) in
                            }
                            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                            dismissProgress()
                            resetUserDefaults()
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    })
                }
            }
        }
    }
    //MARK:- SecureTextOldPassword
    @IBAction func oldPaswordSecureText(_ sender: UIButton)
    {
        if oldPassword.isSecureTextEntry
        {
            sender.setImage(UIImage(named: "hide"), for: .normal)
        }
        else
        {
            sender.setImage(UIImage(named: "show"), for: .normal)
        }
        oldPassword.isSecureTextEntry = !oldPassword.isSecureTextEntry
    }
    //TODO: SecureTextNewPassword
    @IBAction func newPaswordSecureText(_ sender: UIButton)
    {
        if newPassword.isSecureTextEntry
        {
            sender.setImage(UIImage(named: "hide"), for: .normal)
        }
        else
        {
            sender.setImage(UIImage(named: "show"), for: .normal)
        }
        newPassword.isSecureTextEntry = !newPassword.isSecureTextEntry
    }
    //TODO: SecureTextConfirmNewPassword
    @IBAction func confirmNewPaswordSecureText(_ sender: UIButton)
    {
        if confirmNewPassword.isSecureTextEntry
        {
            sender.setImage(UIImage(named: "hide"), for: .normal)
        }
        else
        {
            sender.setImage(UIImage(named: "show"), for: .normal)
        }
        confirmNewPassword.isSecureTextEntry = !confirmNewPassword.isSecureTextEntry
    }
    //TODO: SecureTextpassword
    @IBAction func paswordSecureText(_ sender: UIButton)
    {
        if password.isSecureTextEntry
        {
            sender.setImage(UIImage(named: "hide"), for: .normal)
        }
        else
        {
            sender.setImage(UIImage(named: "show"), for: .normal)
        }
        password.isSecureTextEntry = !password.isSecureTextEntry
    }
}
//MARK:- TextfieldDelegate
extension ProfileViewController: UITextFieldDelegate
{
    //TODO: TextfieldShouldReturn
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        if textField == oldPassword
        {
            newPassword.becomeFirstResponder()
        }
        else if textField == newPassword
        {
            confirmNewPassword.becomeFirstResponder()
        }
        return true
    }
}
//MARK:- UIImagePickerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
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
