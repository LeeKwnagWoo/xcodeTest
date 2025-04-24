//
//  SmartWebView.swift
//  SmartCert
//
//  Created by sjju on 2021/04/15.
//  Copyright © 2021 kw.lee. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class  SmartWebView : UIViewController,  WKScriptMessageHandler, WKUIDelegate, URLSessionDelegate{
    
//    var notiView : WKWebView?
    var webView :WKWebView?
    var urlString : String?
    var strTitle : String?
    var isLoadingComplete = false
    
    var _popupCallbackName:String?
    var popupWebView:WKWebView?
    
//    private let hostUrlString = "https://dev.cardcert.co.kr:18080/appcard/test/KB"
    private let hostUrlString = "https://itfl.io/"

    @IBOutlet weak var btnBackView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var backBtnView: UIView!
    
    @IBOutlet weak var bgView: UIView!
    
    private let JAVASCRIPT_INTERFACE_TITLE: String = "f_title" // 네비게이션 타이틀 변경
    private let JAVASCRIPT_INTERFACE_RETURN: String = "f_returnConfirmReg" //
    private let JAVASCRIPT_INTERFACE_RETRY: String = "f_retry"
    private let JAVASCRIPT_INTERFACE_CANCEL: String = "f_cancelConfirmReg"
    private let JAVASCRIPT_INTERFACE_ALERT: String = "f_alert"

    
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        if message.name == "iOSInterface", let messageBody = message.body as? String {
//            if messageBody == "closeInAppBrowser" {
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
//        else if message.name == "message", let messageBody = message.body as? String {
//            if messageBody == "openApp" {
//                print("openapp")
//            }
//            
//        }
//    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let source = message.name
        if source == "raonIosInterface" {
            if message.name == "raonIosInterface", let messageBody = message.body as? String {
                if messageBody == "closeInAppBrowser" {
//                    self.dismiss(animated: true, completion: nil)
                    self.popupWebView?.removeFromSuperview()
                }
            }
            else if message.name == "message", let messageBody = message.body as? String {
                if messageBody == "openApp" {
                    print("openapp")
                }
                
            }
        }

        if source == "WKBridge" {
            guard let body = message.body as? String else {
                return
            }
            guard let data = body.data(using: .utf8) else {
                return
            }
            do {
                if let command = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
                   JSONSerialization.isValidJSONObject(command),
                   let cmd = command["command"] as? String,
                   let paramDict = command["option"] as? [String: Any] {
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: paramDict, options: .prettyPrinted)
                    let paramStr = String(data: jsonData, encoding: .utf8)
                    
                    if let paramStr = paramStr {
                        DispatchQueue.main.async {
                            if cmd == "closePopup" {
                                self.popupWebView?.removeFromSuperview()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    if let popupCallbackName = self._popupCallbackName {
                                        let js = "\(popupCallbackName)(\(paramStr))"
                                        self.webView?.evaluateJavaScript(js, completionHandler: nil)
                                        self._popupCallbackName = ""
                                    }
                                }
                            }
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }

    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBAction func btnActionBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }
    override func viewDidLoad() {
        super.viewDidLoad()

         
//        self.lblTitle.text = self.strTitle
        self.navigationItem.hidesBackButton = false
        if let urlString = self.urlString, !urlString.hasSuffix("html") {
            let closeImg = UIImage(named: "close")?.withRenderingMode(.alwaysOriginal)
            
            let closeBtn = UIBarButtonItem(image: closeImg, style: .done, target: self, action: #selector(self.closmodal))
            
            self.navigationItem.rightBarButtonItem = closeBtn
        }
        self.removeCache()
        
        let contentController: WKUserContentController = WKUserContentController()
        
//        if let urlString = self.urlString, !urlString.hasPrefix("http"), !urlString.hasSuffix("html"){
//            let userScript = WKUserScript(
//                source: "mobileHeader()",
//                injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
//                forMainFrameOnly: true
//            )
//            contentController.addUserScript(userScript)
//            contentController.add(self, name: "iOSInterface")
//            contentController.add(self, name: "window.open")
//            contentController.add(self, name: "window.close")
//        }
        contentController.add(self, name: "raonIosInterface")
        contentController.add(self, name: "window.open")
        contentController.add(self, name: "window.close")

        contentController.add(self, name: JAVASCRIPT_INTERFACE_TITLE)
        contentController.add(self, name: JAVASCRIPT_INTERFACE_RETURN)
        contentController.add(self, name: JAVASCRIPT_INTERFACE_RETRY)
        contentController.add(self, name: JAVASCRIPT_INTERFACE_CANCEL)
        contentController.add(self, name: JAVASCRIPT_INTERFACE_ALERT)
        
        contentController.add(self, name: "completeCertifyID")
        contentController.add(self, name: "message")
        let config: WKWebViewConfiguration = WKWebViewConfiguration()
        
        let preference = WKPreferences()
        preference.javaScriptEnabled = true
        preference.javaScriptCanOpenWindowsAutomatically = true
        
        config.preferences = preference
        config.userContentController = contentController
        self.webView = WKWebView(frame: self.view.bounds, configuration: config)
        
        if let webview = self.webView{
            self.bgView.addSubview(webview)
            self.bgView.sendSubviewToBack(webview)
            
            webview.uiDelegate = self
            webview.navigationDelegate = self
            self.webView?.allowsLinkPreview = false
            webview.translatesAutoresizingMaskIntoConstraints = false
            let attributes : [NSLayoutConstraint.Attribute] = [.top, .bottom, .right, .left]
            NSLayoutConstraint.activate(attributes.map{NSLayoutConstraint(item: webview, attribute: $0, relatedBy: .equal, toItem: webview.superview, attribute: $0, multiplier: 1.0, constant: 0)
                
            })
            
            
        }
        
//        webView?.evaluateJavaScript("window.location.reload(true)", completionHandler: nil)
//        webView?.evaluateJavaScript("window.location.reload(true)", completionHandler: nil)
        self.loadURL()
//        self.showIndicator(withTitle: "", Desc:"")
        self.webView?.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.webView?.isInspectable = true
//        storage.currentTopVC = (self.navigationController?.topViewController)!
    }
    override func didReceiveMemoryWarning() {

    }
    
    func loadURL() {

        if let url = URL(string: self.urlString ?? "https://dev.cardcert.co.kr:18080/appcard/test/KB") {
            let req = NSMutableURLRequest(url: url as URL,
                                              cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
                                              timeoutInterval: 30.0)
            
            self.webView?.load(req as URLRequest)

        }
        
    }

    
    func removeCache() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                
            }
        }
    }
    
    
    func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
    }
    
    @objc func closmodal (){
        self.dismiss(animated: true, completion: nil)
    }
    
    
// MARK: - 아래 , Auth 와 URLSession Delegate 는 Test 해지 페이지를 위한 인증서 우회 코드이다.
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let cred = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, cred)
    }

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        //Trust the certificate even if not valid
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, urlCredential)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        print(#function)
        print(prompt)
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text{
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
    }
    
//    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//        print(#function)
//        notiView = WKWebView(frame: self.view.bounds, configuration: configuration)
//        notiView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        notiView?.navigationDelegate = self
//        notiView?.uiDelegate = self
//        view.addSubview(notiView!)
//
//        
//        
//        notiView?.translatesAutoresizingMaskIntoConstraints = false
//        let attributes : [NSLayoutConstraint.Attribute] = [.top, .bottom, .right, .left]
//        NSLayoutConstraint.activate(attributes.map{NSLayoutConstraint(item: notiView!, attribute: $0, relatedBy: .equal, toItem: webView.superview, attribute: $0, multiplier: 1.0, constant: 0)
//            
//        })
//        return notiView!
//    }
    
    func handlesURLScheme(_ urlScheme: String) -> Bool{
        print(#function)
        return true
    }
    func evaluateJavaScript(_ javaScriptString: String,
                            completionHandler: ((Any?, Error?) -> Void)? = nil){
        print(#function)
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void){
        print(#function)
        
//        if navigationAction.navigationType == .linkActivated {
//            if let url = navigationAction.request.url {
//                let app = UIApplication.shared
//                if navigationAction.targetFrame == nil {
//                    if app.canOpenURL(url) {
//                        app.open(url)
//                        decisionHandler(.cancel)
//                        return
//                    }
//                } else {
//                    UIApplication.shared.open(url, options: [:])
//                    decisionHandler(.cancel)
//                    return
//                }
//                decisionHandler(.allow)
//            }
//        } else {
//            let app = UIApplication.shared
//            print("not linked")
//            
//            if let url = navigationAction.request.url {
//                print("request \(url)")
//                if navigationAction.targetFrame == nil {
//                    if app.canOpenURL(url) {
//                        app.open(url)
//                        decisionHandler(.cancel)
//                        return
//                    }
//                }
//            }
            decisionHandler(.allow)
                
//        }

    }
 
    //confirm 처리
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) { completionHandler(true)

        print(message)
        
        
    }
    
    //alert 처리
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) { completionHandler()
        print(#function)
        print(message)

    }


    
}
extension SmartWebView : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){

        
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        print(#function)
        self.isLoadingComplete = false
        self.webView!.evaluateJavaScript("document.body.style.webkitTouchCallout='none';")
        print(self.webView?.url)
//        let strUrl = webView.url?.absoluteString
//        let rg = (strUrl as! NSString).range(of: "m/c", options: .backwards)
//        if(rg.location != NSNotFound) {
//            let strPartialUrl = (strUrl as! NSString).substring(from:(strUrl as! NSString).range(of: "m/c", options: .backwards).location - 1)
//            print(strPartialUrl)
////            if(strPartialUrl == "/m/cancel/info.php"){
////                if(value != 0){
////                    //초기화 실패
////                }
////            }
//        }
        
        
    }
    
//    - (NSString*)retrievePopupCallback:(NSURL*)url {
//        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
//        NSArray<NSURLQueryItem *> *queryItems = urlComponents.queryItems;
//        for (NSURLQueryItem *queryItem in queryItems) {
//            if ([queryItem.name isEqualToString:@"callback"]) {
//                return queryItem.value;
//            }
//        }
//        return nil;
//    }
    

    func retrievePopupCallback(from url: URL) -> String? {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = urlComponents?.queryItems
        for queryItem in queryItems ?? [] {
            if queryItem.name == "callback" {
                return queryItem.value
            }
        }
        return nil
    }
    func setupPopupWebView(configuration: WKWebViewConfiguration) -> WKWebView {
        var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        frame = self.view.frame
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "WKBridge")
        userContentController.add(self, name: "raonIosInterface")
        configuration.userContentController = userContentController
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        configuration.preferences.javaScriptEnabled = true
        let popupWebView = WKWebView(frame: frame, configuration: configuration)
        popupWebView.uiDelegate = self
        self.view.addSubview(popupWebView)
        
        let safeArea = self.view.safeAreaLayoutGuide
        popupWebView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popupWebView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            popupWebView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            popupWebView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            popupWebView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
        popupWebView.isInspectable = true
        return popupWebView
    }

    
//    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//          
//        // 호춣하는 url에서 callback 함수명 추출, 이콜백명은 팝업웹뷰에서 처리결과값을 받아서 호출한 웹쪽에 전달하기 위해 사용됨.
//          let loadUrl : String = navigationAction.request.url!.absoluteString
//          if (loadUrl.contains("https://")) {
//              if #available(iOS 10.0,*) {
//                  if let aString = URL(string:(navigationAction.request.url?.absoluteString )!) {
//                      UIApplication.shared.open(aString, options:[:], completionHandler: { success in
//                      })
//                  }
//              } else {
//                  if let aString = URL(string:(navigationAction.request.url?.absoluteString )!) {
//                      UIApplication.shared.openURL(aString)
//                  }
//              }
//          } else {
//              print("else")
//          }
//          return nil
//      }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        // 호출하는 URL에서 callback 함수명 추출, 이 callback명은 팝업 웹뷰에서 처리 결과값을 받아서 호출한 웹 쪽에 전달하기 위해 사용됨
        self._popupCallbackName = self.retrievePopupCallback(from: navigationAction.request.url!) ?? ""
        usleep(50)
        
        // 팝업 웹뷰 셋업
        return self.setupPopupWebView(configuration: configuration)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        print(#function)
        
    }
}

