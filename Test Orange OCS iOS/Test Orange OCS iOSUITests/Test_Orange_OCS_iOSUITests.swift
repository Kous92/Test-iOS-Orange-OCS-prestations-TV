//
//  Test_Orange_OCS_iOSUITests.swift
//  Test Orange OCS iOSUITests
//
//  Created by Koussaïla Ben Mamar on 06/09/2021.
//

import XCTest

class Test_Orange_OCS_iOSUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHome() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.otherElements["searchBar"].waitForExistence(timeout: 1.0), "La barre de recherche n'existe pas.")
        // XCTAssertTrue(app.collectionViews["programCollectionView"].exists, "La grille des programmes (CollectionView) n'existe pas.")
    }
    
    func testSearchPrograms() throws {
        let app = XCUIApplication()
        app.launch()
        
        let searchBar = app.otherElements["searchBar"]
        XCTAssertTrue(searchBar.waitForExistence(timeout: 1.0), "La barre de recherche n'existe pas.")
        XCTAssertTrue(searchBar.isHittable)
        
        let collectionView = app.collectionViews["programCollectionView"]
        searchBar.tap()
        searchBar.typeText("Game of Thrones")
        
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5), "La grille des programmes (CollectionView) n'existe pas.")
        let cells = collectionView.cells
        XCTAssertGreaterThanOrEqual(cells.count, 0)
    }
    
    func testProgramDetails() throws {
        let app = XCUIApplication()
        app.launch()
        
        let searchBar = app.otherElements["searchBar"]
        let collectionView = app.collectionViews["programCollectionView"]
        
        searchBar.tap()
        searchBar.typeText("Game of Thrones")
        // app.keyboards.buttons["Search"].tap()
        
        let cells = collectionView.cells
        XCTAssertGreaterThanOrEqual(cells.count, 0)
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5), "La grille des programmes (CollectionView) n'existe pas.")
        
        if cells.count > 0 {
            let promise = expectation(description: "En attente des CollectionViewCells")
            
            // On pointe sur la première cellule
            let program = cells.element(boundBy: 0)
            XCTAssertTrue(program.exists, "La cellule n'existe pas")
            promise.fulfill()
            waitForExpectations(timeout: 10, handler: nil)
            XCTAssertTrue(true, "Validation terminée, les données sont téléchargées et disposées dans les cellules.")
            program.tap()
         
        } else {
            XCTAssert(false, "Pas de cellules disponibles")
        }
        
        // Seconde vue
        // print(app.debugDescription)
        XCTAssert(app.buttons["backButton"].waitForExistence(timeout: 1.0))
        XCTAssert(app.buttons["playButton"].waitForExistence(timeout: 1.0))
        app.buttons["playButton"].tap()
        
        print(app.debugDescription)
    }
    
    /*
    func testSearchPrograms() throws {
        let app = XCUIApplication()
        app.launch()
        
        let searchBar = app.otherElements["searchBar"]
        XCTAssertTrue(searchBar.waitForExistence(timeout: 1.0), "La barre de recherche n'existe pas.")
        XCTAssertTrue(searchBar.isHittable)
        
        searchBar.tap()
        searchBar.typeText("Game of Thrones")
        XCTAssertTrue(app.keyboards.buttons["Search"].waitForExistence(timeout: 2.0))
        app.keyboards.buttons["Search"].tap()
    }
 */

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
