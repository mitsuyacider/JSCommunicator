//  Copyright © 2018年 Mitstuya.WATANABE. All rights reserved.

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var webView: ExtWebView!
    
    @IBOutlet weak var viewContainer: UIView!
    
    // MARK: - Properties (Data)
    
    override func viewDidLayoutSubviews() {}
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NOTE: Javascriptを有効にする設定
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        // NOTE: Javascriptからのcallback名を指定する。
        //       Javascript側は登録したコールバック名を適宜呼び出すことで、Nativeと連携できる。
        wkUController.add(self, name: "helloNative")
        wkUController.add(self, name: "onTapWord")

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = wkUController
        // NOTE: LocalStorageを許可
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        webView = ExtWebView(frame: .zero, configuration: webConfiguration)
        webView.loadWithAddress(address: Settings.serverAddress)

        // NOTE: ローカルファイルを読み込む場合(reference folder)
        let path = Bundle.main.path(forResource: "www/index", ofType: "html")!
        webView.loadWithLocalAddress(address: path)
        
//        // NOTE: インターネット上のファイルを読み込む場合
//        let path = "https://sandbox.gocco.co.jp/webgl/"
//        webView.loadWithAddress(address: path)
        
        self.view.addSubview(webView)
        
        createDummyButton()
    }
    
    // NOTE: This code comes from following link.
    //       https://i-app-tec.com/ios/button-code.html
    func createDummyButton() {
        // スクリーンの横縦幅
        let screenWidth:CGFloat = self.view.frame.width
        let screenHeight:CGFloat = self.view.frame.height
        
        let button = UIButton()
        button.frame = CGRect(x:screenWidth/4, y:screenHeight/2,
                              width:screenWidth/2, height:50)
        button.setTitle("Notify 2 JS!", for:UIControlState.normal)
        button.titleLabel?.font =  UIFont.systemFont(ofSize: 36)
        button.backgroundColor = UIColor.init(
            red:0.9, green: 0.9, blue: 0.9, alpha: 1)
        button.addTarget(self,
                         action: #selector(ViewController.buttonTapped(sender:)),
                         for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    // MARK: - Data
    override var prefersStatusBarHidden: Bool { return true }
    
    @objc func buttonTapped(sender: UIButton) {
        // NOTE: Javascriptへメッセージを送信する
        webView.notify2JS(command: "NativeCommunicator.helloJavascript", payload: ["message":NSUUID().uuidString])
    }
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // NOTE: message.nameはJavascriptからコールされる関数名
        if message.name == "helloNative" {
            let message = message.body as! String
            print("*** message from JavaScript:", message)
        } else if (message.name == "onTapWord") {
            guard let contentBody = message.body as? String,
                let data = contentBody.data(using: String.Encoding.utf8) else { return }
            if let json = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, Any> {
            
                let word = json["word"]
                print("word: ", word as! String)
            }
        }
    }
}
