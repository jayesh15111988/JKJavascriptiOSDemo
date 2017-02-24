//
//  ViewController.swift
//  JKJavascriptToiOSDemo
//
//  Created by Jayesh Kawli on 2/23/17.
//  Copyright © 2017 Jayesh Kawli. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.loadHTMLString(self.htmlStringFromFile(with: "sampleHTMLCode"), baseURL: nil)
    }

    private func htmlStringFromFile(with name: String) -> String {
        let path = Bundle.main.path(forResource: name, ofType: "html")
        if let result = try? String(contentsOfFile: path!, encoding: String.Encoding.utf8) {
            return result
        }
        return ""
    }

    @IBAction func sendDataToJavaScriptButtonPressed(_ sender: Any) {
        let firstName = self.firstNameField.text
        let lastName = self.lastNameField.text

        let inputPayload = ["firstName": firstName, "lastName": lastName]
        let serializedData = try! JSONSerialization.data(withJSONObject: inputPayload, options: [])
        let encodedData = String(data: serializedData, encoding: String.Encoding.utf8)

        let _ = webView.stringByEvaluatingJavaScript(from: "customMessageWithDictionary('\(encodedData!)')")
    }

}

extension ViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let _ = request.url?.scheme
        let _ = request.url?.host
        let jsonString = request.url?.fragment?.removingPercentEncoding
        let jsonDictionary = convertToDictionary(text: jsonString)

        if let jsonDictionary = jsonDictionary, let firstName = jsonDictionary["firstName"] as? String, let lastName = jsonDictionary["lastName"] as? String {
            firstNameField.text = firstName
            lastNameField.text = lastName
        }

        return true
    }

    // Ref: http://stackoverflow.com/a/30480777
    func convertToDictionary(text: String?) -> [String: Any]? {

        guard let text = text else {
            return [:]
        }
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

