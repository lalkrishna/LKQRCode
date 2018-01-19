//
//  ViewController.swift
//  QRTestApp
//
//  Created by LK on 17/01/18.
//  Copyright © 2018 LK. All rights reserved.
//

import UIKit
import LKQRCode

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        openQRScanner()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    @IBAction func scannerButtonTapped(_ sender: UIButton) {
        openQRScanner()
    }
    
    @IBAction func generateButtonTapped(_ sender: UIButton) {
        
        
        guard let text = textField.text, (text != "") else { imageView.image = nil; view.endEditing(true); return }
        
        var qr: QRCode?
        
        if validateURL(urlString: text) {
            let url: URL?
            if text.hasPrefix("http://") || text.hasPrefix("https://") {
                url = URL(string: text)
            } else {
                url = URL(string: "http://" + text)
            }
            guard let data = url?.absoluteString.data(using: .utf8) else { imageView.image = nil; view.endEditing(true); return }
            qr = QRCode(data)
        } else {
            qr = QRCode(textField.text!)
        }

        guard var qrCode = qr  else { return }
        qrCode.backgroundColor = CIColor(color: UIColor.yellow)
        qrCode.color = CIColor(color: UIColor.red)
        imageView.image = qrCode.image
        view.endEditing(true)
    }
    
    func validateURL (urlString: String) -> Bool {
        let urlRegEx = "(https?://(www.)?)?[-a-zA-Z0-9@:%._+~#=]{2,256}.[a-z]{2,6}b([-a-zA-Z0-9@:%_+.~#?&//=]*)"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        return urlTest.evaluate(with: urlString)
    }
    
//    func verifyUrl (urlString: String?) -> Bool {
//        //Check for nil
//        if let urlString = urlString {
//            // create NSURL instance
//            if let url = NSURL(string: urlString) {
//                // check if your application can open the NSURL instance
//                return UIApplication.sharedApplication().canOpenURL(url)
//            }
//        }
//        return false
//    }
    
    @IBAction func generateContactQR(_ sender: UIButton) {
        let vcard = "BEGIN:VCARD\nVERSION:2.1\nFN:Lal Krishna\nN:Krishna;Lal\nTITLE:Developer\nTEL;CELL:000000000\nTEL;WORK;VOICE:0000000000\nTEL;HOME;VOICE:1234567893\nEMAIL;HOME;INTERNET:lalkrishna@live.com\nEMAIL;WORK;INTERNET:lalkrishna@live.com\nURL:https://github.com/lalkrishna\nADR:;;India;India;;000000;India\nORG:companyname\nEND:VCARD\n"
        guard var qr = QRCode(vcard) else { return }
        qr.backgroundColor = CIColor(color: UIColor.red)
        imageView.image = qr.image
    }
    
    @IBAction func generateWifiQR(_ sender: UIButton) {
        guard var qr = QRCode(WiFi(encription: .wpa, networkName: "NetworkName", password: "password", hidden: false)) else { return }
        qr.backgroundColor = CIColor(color: UIColor.yellow)
        qr.color = CIColor(color: UIColor.purple)
        imageView.image = qr.image
    }
    
    func openQRScanner() {
        
        let scanner = LKScanner()
        scanner.setDefaultHole()
        scanner.delegate = self

        let closeButton = UIButton.init(frame: CGRect(x: 0, y: 20, width: 50, height: 50))
        closeButton.setTitle("x", for: .normal)
        closeButton.addTarget(self, action:#selector(handleRegister(sender:)), for: .touchUpInside)
        closeButton.backgroundColor = UIColor.red
        scanner.topView = closeButton
        
        self.present(scanner, animated: true, completion: nil)
    }
    
    @objc func handleRegister(sender: UIButton){
        if self.presentedViewController is LKScanner {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension ViewController: LKScanDelegate {
    
    func scanner(_ scanner: LKScanner, scannedText: String) {
        print("Scanned Text: \(scannedText)")
        scanner.pause()
        scanner.dismiss(animated: true, completion: nil)
    }
    
    func scannerDidFail(_ scanner: LKScanner, error: ScanError) {
        print("Error Occured: \(error.localizedDescription)")
    }
    
}

