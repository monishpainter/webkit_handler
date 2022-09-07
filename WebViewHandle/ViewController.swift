//
//  ViewController.swift
//  WebViewHandle
//
//  Created by Monish Painter on 29/08/22.
//  Email: monishpainter@yahoo.com
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var webView: WKWebView!
    @IBOutlet weak var webViewContainer: UIView!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //1 REGISTER JAVASCRIPT METHOD HERE
        let contentController = WKUserContentController();
        contentController.add(
            self,
            name: "responceResult"
        )
        
        // 2
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        // 3
        webView = WKWebView(frame: webViewContainer.bounds, configuration: config)
        //webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webViewContainer.addSubview(webView)
        
        webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor, constant: 0).isActive = true
        webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor, constant: 0).isActive = true
        
        
        // 4
        if let url = URL(string: Constants.API_URL) {
            var urlRequest = URLRequest(url: url)
            
            //TODO: Encrypt amount data and pass to api
            let amountVal = "0911" //Pass amount here
            
            guard let cipher = CryptoHelper.encrypt(input:amountVal) else { return  }
            //guard let decrypt = CryptoHelper.decrypt(input: cipher) else { return  }
            
            let para = ["PaymentUniqIdentity": randomString(length: 15), //Transaction Number Temporary We are using random string
                        "Amount": cipher]
            
            let finalBody = try? JSONSerialization.data(withJSONObject: para)
            
            
            //TODO: API KEY Provide by SMC
            let dicHeader: [String: String] = ["Content-Type" : "application/json" ,
                                               "APIKey" : Constants.API_KEY, // API KEY Provide by SMC
                                               "identifire": Bundle.main.bundleIdentifier ?? "", //iOS bundle identifire, Android - Package
                                               "version_code": Bundle.main.releaseVersionNumber ?? "", //iOS bundle identifire, Android - Package
                                               "AccessType" : Constants.ACCESS_POINT
            ]
            
            for (key, value) in dicHeader {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
            
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = finalBody
            
            webView.load(urlRequest)
        }
        
    }
    
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}

//MARK: - WKWebView Delegate methods
extension ViewController:WKScriptMessageHandler {
    func userContentController( _ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "responceResult",
           let dict = message.body as? [String:Any] {
            if let amt = dict["Amount"] as? String{
                print("AMT------ \(CryptoHelper.decrypt(input: amt) ?? "")")
            }
            if let status = dict["Status"] as? String, status.count > 0{
                if status == "Success"{
                    //TODO: handle success response and call other APIs here
                    var messageDisplay = "Payment Success."
                    if let msg = dict["Message"] as? String{
                        messageDisplay = msg
                    }
                    let alert = UIAlertController(title: "Success", message: messageDisplay, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:{ (action) in
                        self.navigationController?.popViewController(animated: true)
                        alert.dismiss(animated: true, completion:nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }else{
                    //TODO: Handle fail response
                    var messageDisplay = "Something went wrong. Please try again later."
                    if let msg = dict["Message"] as? String{
                        messageDisplay = msg
                    }
                    
                    let alert = UIAlertController(title: "Alert", message: messageDisplay, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:{ (action) in
                        self.navigationController?.popViewController(animated: true)
                        alert.dismiss(animated: true, completion:nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
            }else{
                let alert = UIAlertController(title: "Error", message: "Something went wrong. Please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:{ (action) in
                    self.navigationController?.popViewController(animated: true)
                    alert.dismiss(animated: true, completion:nil)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        let exceptions = SecTrustCopyExceptions(serverTrust)
        SecTrustSetExceptions(serverTrust, exceptions)
        completionHandler(.useCredential, URLCredential(trust: serverTrust));
    }
    
}


