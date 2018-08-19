//  Copyright © 2018年 Mitstuya.WATANABE. All rights reserved.

import UIKit
import WebKit

class ExtWebView: WKWebView, WKUIDelegate {
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        
        self.uiDelegate = self
        
        // NOTE: ネイティブからjavascriptへ連携するためのデリゲート
        self.navigationDelegate = self
        
        // NOTE: iPhoneXで上下のsafe areaにコンテンツが表示されない問題を解決するためのコード
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never;
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     @param: address 接続先URL
     */
    func loadWithAddress(address: String) {
        let myURL = URL(string: address)
        let myRequest = URLRequest(url: myURL!)
        self.load(myRequest)
    }
    
    /*
     Javascriptにデータを送信する
     @param: command Javascriptで呼び出す関数名
     @param: payload Javascriptに渡すデータ
     */
    func notify2JS(command: String, payload : [String:Any]) {
        // create json data
        var jsonStr = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            jsonStr = String(bytes: jsonData, encoding: .utf8)!
        } catch _ {}
        
        // NOTE: Javascritpt側に渡すコマンドを作成する。
        //       (%@)には引数となるデータが入る
        let format = command + "('%@')"
        let jscript = String(format: format, jsonStr)
        self.evaluateJavaScript(jscript, completionHandler: { (object, error) -> Void in})
    }
}

extension ExtWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // NOTE: webviewの表示領域をディスプレイサイズに設定する。
        let displaySize: CGSize = UIScreen.main.bounds.size
        // NOTE: 高さをdisplaysize - 1に設定しないと、コンテンツがフルで表示されない。
        let frame = CGRect.init(x: 0.0, y: 0.0, width: displaySize.width, height: displaySize.height - 1)
        webView.frame = frame
        // NOTE: この設定をしないと、タブバーごとスクロールしてしまう
        webView.scrollView.isScrollEnabled = false
    }
}
