//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import Nimbus
import WebKit
import XCTest

class MochaTests: XCTestCase, WKNavigationDelegate {
    struct MochaMessage: Encodable {
        var stringField = "This is a string"
        var intField = 42
    }

    class MochaTestBridge {
        init(webView: WKWebView) {
            self.webView = webView
        }

        let webView: WKWebView
        let expectation = XCTestExpectation(description: "testsCompleted")
        var failures: Int = -1
        func testsCompleted(failures: Int) {
            self.failures = failures
            expectation.fulfill()
        }

        func ready() {}
        func sendMessage(name: String, includeParam: Bool) {
            if includeParam {
                webView.broadcastMessage(name: name, arg: MochaMessage())
            } else {
                webView.broadcastMessage(name: name)
            }
        }

    }

    var webView: WKWebView!

    var loadingExpectation: XCTestExpectation?

    override func setUp() {
        webView = WKWebView()
        webView.navigationDelegate = self
    }

    override func tearDown() {
        webView.navigationDelegate = nil
        webView = nil
    }

    func loadWebViewAndWait() {
        loadingExpectation = expectation(description: "web view loaded")
        if let url = Bundle(for: MochaTests.self).url(forResource: "index", withExtension: "html", subdirectory: "test-www") {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
        wait(for: [loadingExpectation!], timeout: 5)
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        loadingExpectation?.fulfill()
    }

    func testExecuteMochaTests() {
        let testBridge = MochaTestBridge(webView: webView)
        let connection = webView.addConnection(to: testBridge, as: "mochaTestBridge")
        connection.bind(MochaTestBridge.testsCompleted, as: "testsCompleted")
        connection.bind(MochaTestBridge.ready, as: "ready")
        connection.bind(MochaTestBridge.sendMessage, as: "sendMessage")
        let callbackTestExtension = CallbackTestExtension()
        callbackTestExtension.bindToWebView(webView: webView)

        loadWebViewAndWait()

        webView.evaluateJavaScript("mocha.run((failures) => { mochaTestBridge.testsCompleted(failures); }); true;") { _, error in

            if let error = error {
                XCTFail(error.localizedDescription)
            }

        }

        wait(for: [testBridge.expectation], timeout: 30)
        XCTAssertEqual(testBridge.failures, 0)
    }
}

public class CallbackTestExtension {
    func callbackWithSingleParam(completion: @escaping (MochaTests.MochaMessage) -> Swift.Void) {
        let mochaMessage = MochaTests.MochaMessage()
        completion(mochaMessage)
    }
    func callbackWithTwoParams(completion: @escaping (MochaTests.MochaMessage, MochaTests.MochaMessage) -> Swift.Void) {
        var mochaMessage = MochaTests.MochaMessage()
        mochaMessage.intField = 6
        mochaMessage.stringField = "int param is 6"
        completion(MochaTests.MochaMessage(), mochaMessage)
    }
    func callbackWithSinglePrimitiveParam(completion: @escaping (Int) -> Swift.Void) {
        completion(777)
    }
    func callbackWithTwoPrimitiveParams(completion: @escaping (Int, Int) -> Swift.Void) {
        completion(777, 888)
    }
    func callbackWithPrimitiveAndUddtParams(completion: @escaping (Int, MochaTests.MochaMessage) -> Swift.Void) {
        completion(777, MochaTests.MochaMessage())
    }
    func callbackWithPrimitiveAndArrayParams(completion: @escaping (Int, NSArray) -> Swift.Void) {
        let arr: NSArray = ["one", "two", "three"]
        completion(777, arr)
    }
    func callbackWithPrimitiveAndDictionaryParams(completion: @escaping (Int, NSDictionary) -> Swift.Void) {
        let dict: NSDictionary = ["one": 1, "two": 2, "three": 3]
        completion(777, dict)
    }
    func callbackWithArrayAndUddtParams(completion: @escaping (NSArray, MochaTests.MochaMessage) -> Swift.Void) {
        let arr: NSArray = ["one", "two", "three"]
        completion(arr, MochaTests.MochaMessage())
    }
    func callbackWithArrayAndArrayParams(completion: @escaping (NSArray, NSArray) -> Swift.Void) {
        let arr0: NSArray = ["one", "two", "three"]
        let arr1: NSArray = ["four", "five", "six"]
        completion(arr0, arr1)
    }
    func callbackWithArrayAndDictionaryParams(completion: @escaping (NSArray, NSDictionary) -> Swift.Void) {
        let arr: NSArray = ["one", "two", "three"]
        let dict: NSDictionary = ["one": 1, "two": 2, "three": 3]
        completion(arr, dict)
    }
    func callbackWithDictionaryAndUddtParams(completion: @escaping (NSDictionary, MochaTests.MochaMessage) -> Swift.Void) {
        let dict: NSDictionary = ["one": 1, "two": 2, "three": 3]
        completion(dict, MochaTests.MochaMessage())
    }
    func callbackWithDictionaryAndArrayParams(completion: @escaping (NSDictionary, NSArray) -> Swift.Void) {
        let dict: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let arr: NSArray = ["one", "two", "three"]
        completion(dict, arr)
    }
    func callbackWithDictionaryAndDictionaryParams(completion: @escaping (NSDictionary, NSDictionary) -> Swift.Void) {
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let dict1: NSDictionary = ["four": 4, "five": 5, "six": 6]
        completion(dict0, dict1)
    }
}

extension CallbackTestExtension: NimbusExtension {
    public func bindToWebView(webView: WKWebView) {
        let connection = webView.addConnection(to: self, as: "callbackTestExtension")
        connection.bind(CallbackTestExtension.callbackWithSingleParam, as: "callbackWithSingleParam")
        connection.bind(CallbackTestExtension.callbackWithTwoParams, as: "callbackWithTwoParams")
        connection.bind(CallbackTestExtension.callbackWithSinglePrimitiveParam, as: "callbackWithSinglePrimitiveParam")
        connection.bind(CallbackTestExtension.callbackWithTwoPrimitiveParams, as: "callbackWithTwoPrimitiveParams")
        connection.bind(CallbackTestExtension.callbackWithPrimitiveAndUddtParams, as: "callbackWithPrimitiveAndUddtParams")
        connection.bind(CallbackTestExtension.callbackWithPrimitiveAndArrayParams, as: "callbackWithPrimitiveAndArrayParams")
        connection.bind(CallbackTestExtension.callbackWithPrimitiveAndDictionaryParams, as: "callbackWithPrimitiveAndDictionaryParams")
        connection.bind(CallbackTestExtension.callbackWithArrayAndUddtParams, as: "callbackWithArrayAndUddtParams")
        connection.bind(CallbackTestExtension.callbackWithArrayAndArrayParams, as: "callbackWithArrayAndArrayParams")
        connection.bind(CallbackTestExtension.callbackWithArrayAndDictionaryParams, as: "callbackWithArrayAndDictionaryParams")
        connection.bind(CallbackTestExtension.callbackWithDictionaryAndUddtParams, as: "callbackWithDictionaryAndUddtParams")
        connection.bind(CallbackTestExtension.callbackWithDictionaryAndArrayParams, as: "callbackWithDictionaryAndArrayParams")
        connection.bind(CallbackTestExtension.callbackWithDictionaryAndDictionaryParams, as: "callbackWithDictionaryAndDictionaryParams")
    }
}
