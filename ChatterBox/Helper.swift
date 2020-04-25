//  Helper.swift
//  ChatterBox
//  Created by Deepak on 24/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit
import SVProgressHUD
import SystemConfiguration
import ImageIO
//MARK:- Variables
let appDelegate = UIApplication.shared.delegate as! AppDelegate
var myIndex = 0
//MARK:- Alert
func createAlert(title: String, message: String, vc: UIViewController)
{
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    alert.addColorInTitleAndMessage()
    vc.present(alert, animated: true, completion: nil)
}
//MARK:- AlertWithPush
func createAlertWithPush(title: String, message: String, vc: UIViewController, push: UIViewController)
{
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let pushAction = UIAlertAction(title: "OK", style: .default)
    {
        action -> Void in
        vc.navigationController?.pushViewController(push, animated: true)
    }
    alert.addAction(pushAction)
    alert.addColorInTitleAndMessage()
    vc.present(alert, animated: true, completion: nil)
}
//MARK:- ShowProgress
func showProgress()
{
    SVProgressHUD.show(withStatus: "Loading")
}
//MARK:- DismissProgress
func dismissProgress()
{
    SVProgressHUD.dismiss()
}
//MARK:- AlertControllerExtension
extension UIAlertController
{
    //TODO: AddColorToAlert
    func addColorInTitleAndMessage()
    {
        let attributesTitle = [NSAttributedString.Key.foregroundColor: UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1), NSAttributedString.Key.font: UIFont(name: "Verdana", size: 16)]
        let attributesMessage = [NSAttributedString.Key.foregroundColor: UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1), NSAttributedString.Key.font: UIFont(name: "Verdana", size: 14)]
        let attributedTitleText = NSAttributedString(string: self.title ?? "", attributes: attributesTitle)
        let attributedMessageText = NSAttributedString(string: self.message ?? "", attributes: attributesMessage)
        self.setValue(attributedTitleText, forKey: "attributedTitle")
        self.setValue(attributedMessageText, forKey: "attributedMessage")
        self.view.tintColor = UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1)
    }
}
//MARK:- CheckInternetConnectivity
func isConnectedToNetwork() -> Bool
{
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress)
    {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1)
        {   zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
    if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false
    {
        return false
    }
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    let ret = (isReachable && !needsConnection)
    return ret
}
//MARK:- Functions to customise QR
extension CIImage
{
    var transparent: CIImage?
    {
        return inverted?.blackTransparent
    }
    var inverted: CIImage?
    {
        guard let invertedColorFilter = CIFilter(name: "CIColorInvert")
        else
        {
            return nil
        }
        invertedColorFilter.setValue(self, forKey: "inputImage")
        return invertedColorFilter.outputImage
    }
    var blackTransparent: CIImage?
    {
        guard let blackTransparentFilter = CIFilter(name: "CIMaskToAlpha")
        else
        {
            return nil
        }
        blackTransparentFilter.setValue(self, forKey: "inputImage")
        return blackTransparentFilter.outputImage
    }
    func tinted(using color: UIColor) -> CIImage?
    {
        guard   let transparentQRImage = transparent,
                let filter = CIFilter(name: "CIMultiplyCompositing"),
                let colorFilter = CIFilter(name: "CIConstantColorGenerator")
        else
        {
            return nil
        }
        let ciColor = CIColor(color: color)
        colorFilter.setValue(ciColor, forKey: kCIInputColorKey)
        let colorImage = colorFilter.outputImage
        filter.setValue(colorImage, forKey: kCIInputImageKey)
        filter.setValue(transparentQRImage, forKey: kCIInputBackgroundImageKey)
        return filter.outputImage!
    }
}

//class PushNotificationSender
//{
//    let sKey = "AAAAQeaADRI:APA91bEfwmBsm7R1sqM93IJSd0W1vQuzc5OPMoca1Hoc-PqZkW1LNAvdcU61vrIS3nyHYdA7HqcKhlmeiaqdRAa6YF6Ra29N3gsacGasrHuaxKWxXd5gGCIMxf-pVosMi8WFeKGvD5u4"
//    func sendPushNotification(to token: String, title: String, body: String) {
//        let urlString = "https://fcm.googleapis.com/fcm/send"
//        let url = NSURL(string: urlString)!
//        let paramString: [String : Any] = ["to" : token,
//                                           "notification" : ["title" : title, "body" : body]]
//        let request = NSMutableURLRequest(url: url as URL)
//        request.httpMethod = "POST"
//        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("key=\(sKey)", forHTTPHeaderField: "Authorization")
//        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
//            do {
//                if let jsonData = data {
//                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
//                        NSLog("Received data:\n\(jsonDataDict))")
//                    }
//                }
//            } catch let err as NSError {
//                print(err.debugDescription)
//            }
//        }
//        task.resume()
//    }
//}
