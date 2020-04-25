//  CreateGroupViewController.swift
//  ChatterBox
//  Created by Deepak on 25/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit

class CreateGroupViewController: UIViewController
{
    //MARK:- Outlets
    @IBOutlet weak var groupPic: UIImageView!
    @IBOutlet weak var groupName: UITextField!
    //MARK:- Variables
    var imagePicker = UIImagePickerController()
    //MARK:- ViewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        groupPic.image = UIImage(named: "defaultGroup")
        let tap = UITapGestureRecognizer(target: self, action: #selector(takePhoto))
        groupPic.addGestureRecognizer(tap)
        groupPic.isUserInteractionEnabled = true
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
    //MARK:- Next
    @IBAction func next(_ sender: Any)
    {
        if groupName.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            createAlert(title: "Alert", message: "Please enter a name for the group and try again.", vc: self)
        }
        else if isConnectedToNetwork()
        {
            if groupPic.image == UIImage(named: "defaultGroup")
            {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectMembersViewController") as! SelectMembersViewController
                vc.name = groupName.text!
                vc.data = nil
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else
            {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectMembersViewController") as! SelectMembersViewController
                vc.name = groupName.text!
                let img = groupPic.image!
                vc.data = img.pngData()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else
        {
            createAlert(title: "Alert", message: "Please make sure that you have an active internet action and try again.", vc: self)
        }
    }
}
//MARK:- UIImagePickerDelegate
extension CreateGroupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    //TODO: DidFinishPickingMedia
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let myImage = info[.originalImage] as! UIImage
        let img: UIImage = (myImage.resizeWithWidth(width: 200))!
        self.groupPic.image = img
        picker.dismiss(animated: true, completion: nil)
    }
}
//MARK:- TextfieldDelegate
extension CreateGroupViewController: UITextFieldDelegate
{
    //TODO: TextfieldShouldReturn
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
