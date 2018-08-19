//  Copyright © 2018年 Mitstuya.WATANABE. All rights reserved.

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var webView: ExtWebView!
    
    @IBOutlet weak var viewContainer: UIView!
    
    // MARK: - Properties (Data)
    
    override func viewDidLayoutSubviews() {
        print(viewContainer)
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        // NOTE: Javascriptからのcallback名を指定する
        wkUController.add(self, name: "glassId")
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = wkUController
        // LocalStorageを許可
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        webView = ExtWebView(frame: .zero, configuration: webConfiguration)
        webView.loadWithAddress(address: Settings.serverAddress)

        self.view.addSubview(webView)
        
        createDummyButton()
    }
    
    func createDummyButton() {
        // スクリーンの横縦幅
        let screenWidth:CGFloat = self.view.frame.width
        let screenHeight:CGFloat = self.view.frame.height
        
        let label = UILabel()
        
        // ボタンのインスタンス生成
        let button = UIButton()
        
        // ボタンの位置とサイズを設定
        button.frame = CGRect(x:screenWidth/4, y:screenHeight/2,
                              width:screenWidth/2, height:50)
        
        // ボタンのタイトルを設定
        button.setTitle("Tap me!", for:UIControlState.normal)
        
        // タイトルの色
        //        button.setTitleColor(UIColor.white, for: .normal)
        
        // ボタンのフォントサイズ
        button.titleLabel?.font =  UIFont.systemFont(ofSize: 36)
        
        // 背景色
        button.backgroundColor = UIColor.init(
            red:0.9, green: 0.9, blue: 0.9, alpha: 1)
        
        // タップされたときのaction
        button.addTarget(self,
                         action: #selector(ViewController.buttonTapped(sender:)),
                         for: .touchUpInside)
        
        // Viewにボタンを追加
        self.view.addSubview(button)
    }
    
    // MARK: - Data
    override var prefersStatusBarHidden: Bool { return true }
    
    @objc func buttonTapped(sender: UIButton) {
        webView.notify2JS(command: "NativeCommunicator.onCheers", payload: ["device_ids":[1, 2, 4]])
    }
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "glassId" {
            let number = message.body as! String
            // NOTE: ペアリング開始
            print("*** glass id:", number)
        }
    }
}
