//
//  ViewController.swift
//  ReadMCC
//
//  Created by 이광우 on 2023/03/08.
//

import UIKit
import CoreTelephony
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController, CLLocationManagerDelegate, CTTelephonyNetworkInfoDelegate {
    
    
    //    var btMgr: BluetoothManager!
    @IBOutlet weak var btnOpenOutWeb: UIButton!
    @IBOutlet weak var btnOpenInAppWeb: UIButton!
    lazy var webView:SmartWebView = SmartWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnOpenOutWeb.titleLabel?.text = "외부 웹브라우저 호출"
        self.btnOpenOutWeb.sizeToFit()
        self.btnOpenInAppWeb.titleLabel?.text = "앱내 웹브라우저 호출"
        self.btnOpenInAppWeb.sizeToFit()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    @IBAction func actionOpenOutWeb(_ sender: Any) {
        if UIApplication.shared.canOpenURL(URL.init(string:"https://cx.raonsecure.co.kr:48080/shinhanPortal/")!){
            UIApplication.shared.open(URL.init(string:"https://cx.raonsecure.co.kr:48080/shinhanPortal/")!)
        }

    }
    @IBAction func actionOpenInAppWeb(_ sender: Any) {

        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let webView = sb.instantiateViewController(withIdentifier: "web") as! SmartWebView
        webView.strTitle = "title"
        webView.urlString = "https://cx.raonsecure.co.kr:48080/shinhanPortal/"
    
        webView.modalPresentationStyle = .fullScreen
        self.present(webView, animated: true, completion: nil)

    }
    
}
