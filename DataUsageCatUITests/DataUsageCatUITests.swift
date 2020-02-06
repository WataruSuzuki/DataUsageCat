//
//  DataUsageCatUITests.swift
//  DataUsageCatUITests
//
//  Created by Wataru Suzuki on 2016/07/03.
//  Copyright © 2016年 Wataru Suzuki. All rights reserved.
//

import XCTest

class DataUsageCatUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        if #available(iOS 9.0, *) {
            XCUIApplication().launch()
        } else {
            // Fallback on earlier versions
        }

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample001() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
//        let permissionAlert = app.alerts["“DataUsageCat” Would Like to Send You Notifications"]
//        if permissionAlert.exists {
//            permissionAlert.scrollViews.otherElements.buttons["Allow"].tap()
//        }
//        
//        app.buttons["remaining"].tap()
//        app.buttons["save of month"].tap()
    }

    private func testExample002(dummyParam: Int) {
        let app = XCUIApplication()
        app.buttons["cat good"].tap()
        
        closeAd(app: app)
        app.tables.cells.containing(.staticText, identifier:"Map app").buttons["More Info"].tap()
        
        closeAd(app: app)
        app.navigationBars["Map app"].buttons["Comment from Cat"].tap()
        
        closeAd(app: app)
        app.navigationBars["Comment from Cat"].buttons["Stop"].tap()
        app.buttons["buttonCurrentMonthValue"].tap()
        
        closeAd(app: app)
        app.toolbars["Toolbar"].buttons["About this month"].tap()
        app.navigationBars["About this month"].buttons["Stop"].tap()
        
        tapJarashi(app: app)
        
        closeAd(app: app)
        app.navigationBars["Settings"].buttons["Done"].tap()
        app.buttons["More Info"].tap()
        
        closeAd(app: app)
        app.navigationBars["About this App"].buttons["Back"].tap()
    }
    
    private func closeAd(app: XCUIApplication) {
        sleep(2)
        let closeAdvertisementButton = app.buttons["Close Advertisement"]
        if closeAdvertisementButton.exists {
            closeAdvertisementButton.tap()
        }
    }
    
    private func tapJarashi(app: XCUIApplication) {
        let jarashi = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .button).element
        jarashi.tap()
    }
}
