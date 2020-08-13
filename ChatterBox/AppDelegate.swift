//  AppDelegate.swift
//  ChatterBox
//  Created by Deepak on 24/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    //MARK:- DidFinishLaunching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        FirebaseApp.configure()
        if let user = Auth.auth().currentUser
        {
            if let uid = UserDefaults.standard.string(forKey: "uid")
            {
                let ref1 = Constants.refs.users.child(uid).child("isActive")
                ref1.setValue(true)
            }
            else
            {
                UserDefaults.standard.set(user.uid, forKey: "uid")
                UserDefaults.standard.set(user.email, forKey: "email")
                UserDefaults.standard.set(user.displayName, forKey: "name")
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
                let ref1 = Constants.refs.users.child(UserDefaults.standard.string(forKey: "uid")!).child("isActive")
                ref1.setValue(true)
            }
            let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersViewController") as! UsersViewController
            let nav = UINavigationController.init(rootViewController: homeVC)
            nav.isNavigationBarHidden = true
            self.window?.rootViewController = nav
        }
        else
        {
            let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let nav = UINavigationController.init(rootViewController: homeVC)
            nav.isNavigationBarHidden = true
            self.window?.rootViewController = nav
        }
        return true
    }
    //MARK:- SupportedInterfaces
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return .all
    }
    //MARK:- ApplicationWillTerminate
    func applicationWillTerminate(_ application: UIApplication)
    {
        if let uid = UserDefaults.standard.string(forKey: "uid")
        {
            let ref1 = Constants.refs.users.child(uid).child("isActive")
            ref1.setValue(false)
        }
    }
    //MARK:- ApplicationWillResignActive
    func applicationWillResignActive(_ application: UIApplication)
    {
        if let uid = UserDefaults.standard.string(forKey: "uid")
        {
            let ref1 = Constants.refs.users.child(uid).child("isActive")
            ref1.setValue(false)
        }
    }
    //MARK:- ApplicationDidBecomeActive
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        if let uid = UserDefaults.standard.string(forKey: "uid")
        {
            let ref1 = Constants.refs.users.child(uid).child("isActive")
            ref1.setValue(true)
        }
    }
    //MARK:- ApplicationDidEnterBackground
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        if let uid = UserDefaults.standard.string(forKey: "uid")
        {
            let ref1 = Constants.refs.users.child(uid).child("isActive")
            ref1.setValue(false)
        }
    }
    //MARK:- ApplicationWillEnterForeground
    func applicationWillEnterForeground(_ application: UIApplication)
    {
        if let uid = UserDefaults.standard.string(forKey: "uid")
        {
            let ref1 = Constants.refs.users.child(uid).child("isActive")
            ref1.setValue(true)
        }
    }
}
