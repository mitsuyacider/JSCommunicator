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
        webConfiguration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        webView = ExtWebView(frame: .zero, configuration: webConfiguration)
        webView.loadWithAddress(address: Settings.serverAddress)

        // NOTE: ローカルファイルを読み込む場合(reference folder)
        let path = Bundle.main.path(forResource: "www/index", ofType: "html")!
        webView.loadWithLocalAddress(address: path)
        
//        // NOTE: インターネット上のファイルを読み込む場合
//        let path = "https://sandbox.gocco.co.jp/webgl/"
//        webView.loadWithAddress(address: path)
        
        self.view.addSubview(webView)
        
        let margin:CGFloat = 20.0
        let screenWidth:CGFloat = self.view.frame.width
        let screenHeight:CGFloat = self.view.frame.height

        let width:CGFloat = (screenWidth / 3.0) - margin
        let height:CGFloat = 30.0
        let y:CGFloat = screenHeight - height - margin
        for i in 1..<4 {
            let title = "pattern-" + String(i)
            let x = CGFloat(i - 1) * width + margin * CGFloat(i - 1) + margin / 2
            let frame:CGRect = CGRect(x: x, y: y, width: width, height: height)
            createDummyButton(title: title, frame: frame, tag: i)
        }
    }
    
    // NOTE: This code comes from following link.
    //       https://i-app-tec.com/ios/button-code.html
    func createDummyButton(title: String, frame: CGRect, tag: Int) {
        // スクリーンの横縦幅
        let button = UIButton()
        button.frame = CGRect(x:frame.minX, y:frame.minY,
                              width:frame.width, height:frame.height)
        button.setTitle(title, for:UIControlState.normal)
        button.titleLabel?.font =  UIFont.systemFont(ofSize: 16)
        button.backgroundColor = UIColor.init(
            red:0.9, green: 0.9, blue: 0.9, alpha: 1)
        button.tag = tag
        button.addTarget(self,
                         action: #selector(ViewController.buttonTapped(sender:)),
                         for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    // MARK: - Data
    override var prefersStatusBarHidden: Bool { return true }
    
    @objc func buttonTapped(sender: UIButton) {
        // NOTE: Javascriptへメッセージを送信する
        let data = ["id": 0, "pattern": sender.tag]
        webView.notify2JS(command: "NativeCommunicator.onSelection", payload: data)
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
