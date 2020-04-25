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
        if Auth.auth().currentUser != nil
        {
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
}
