//
//  ContactTaskTests.swift
//  ContactTaskTests
//
//  Created by Bharath on 18/04/19.
//  Copyright © 2019 Bharath. All rights reserved.
//

import XCTest

@testable import ContactTask

class ContactTaskTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    func testValidEmail() {
        let testSuccess = "bharathkandra@gmail.com"
        XCTAssertTrue(testSuccess.isValidEmail())
    }
    
    func testValidFailure() {
        let testFailure = "bharath"
        XCTAssertTrue(testFailure.isValidEmail())
    }
    

}
