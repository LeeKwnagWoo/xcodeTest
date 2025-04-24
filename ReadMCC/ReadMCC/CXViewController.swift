//
//  CXViewController.swift
//  ReadMCC
//
//  Created by 이광우 on 3/20/24.
//

import Foundation
import UIKit
import WebKit

class CXViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        if let url = URL(string: "https://cx.raonsecure.co.kr:48080/shinhanPortal/") {
            webView.load(URLRequest(url: url))
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        print(navigationAction.request.url)
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // 여기서 2번 페이지의 URL을 확인하고, 해당 URL일 경우 새로운 웹뷰로 로드합니다.
        if url.absoluteString.contains("https://cert.cardcert.co.kr") { // 여기서는 예시로 URL에 "2"가 포함되어 있는 경우를 확인합니다.
            let childWebView = WKWebView(frame: self.view.bounds)
            childWebView.load(URLRequest(url: url))
            self.view.addSubview(childWebView)

            // 새로운 웹뷰에 대한 추가적인 설정, 예를 들어 제약 조건 등을 설정할 수 있습니다.

            decisionHandler(.cancel) // 현재 웹뷰에서의 로드를 취소합니다.
        } else {
            decisionHandler(.allow)
        }
    }
}
