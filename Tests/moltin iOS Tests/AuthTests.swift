//
//  AuthTests.swift
//  moltin
//
//  Created by Craig Tweedy on 22/02/2018.
//

import XCTest

@testable
import moltin

class AuthRequestTests: XCTestCase {
    
    let multiProductJson = """
                {
                  "data":
                    [{
                      "id": "51b56d92-ab99-4802-a2c1-be150848c629",
                      "author": {
                        "name": "Craig"
                      }
                    }],
                    "meta": {
                    }
                }
                """

    let authJson = """
    {
        "access_token": "123asdasd123",
        "expires": 1001010
    }
    """
    
    func testAuthAuthenticatesSuccessfullyAndPassesThrough() {
        let (_, productRequest) = MockFactory.mockedProductRequest(withJSON: self.multiProductJson)
        
        let expectationToFulfill = expectation(description: "ProductRequest calls the method and runs the callback closure")
        
        let _ = productRequest.all { (result) in
            switch result {
            case .success(_):
                XCTAssertTrue(true)
                break
            case .failure(_):
                XCTFail("Could not authenticate")
                break
            }
            
            expectationToFulfill.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testAuthAuthenticatesFailsCorrectly() {
        let (_, productRequest) = MockFactory.mockedProductRequest(withJSON: self.multiProductJson)
        let mockSession = MockURLSession()
        productRequest.auth.http = MoltinHTTP(withSession: mockSession)
        
        let expectationToFulfill = expectation(description: "ProductRequest calls the method and runs the callback closure")
        
        let _ = productRequest.all { (result) in
            switch result {
            case .success(_):
                XCTFail()
                break
            case .failure(let error):
                XCTAssertNotNil(error)
                break
            }
            
            expectationToFulfill.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testAuthTokenRefreshRequired() {
        let auth = MoltinAuth(withConfiguration: MoltinConfig.default(withClientID: "12345"))
        auth.token = nil
        auth.expires = nil
        
        let expectationToFulfill = expectation(description: "Auth calls the method and runs the callback closure")
        
        auth.authenticate { (result) in
            switch result {
            case .success(_):
                XCTFail()
            default: XCTAssertTrue(true)
            }
            
            expectationToFulfill.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testAuthCouldNotConfigure() {
        let auth = MoltinAuth(withConfiguration: MoltinConfig.default(withClientID: "12345"))
        auth.token = nil
        auth.expires = nil
        auth.http = MockedMoltinHTTP(withSession: MockURLSession())
        
        let expectationToFulfill = expectation(description: "Auth calls the method and runs the callback closure")
        
        auth.authenticate { (result) in
            switch result {
            case .success(_):
                XCTFail()
            default: XCTAssertTrue(true)
            }
            
            expectationToFulfill.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testAuthenticationFailed() {
        let auth = MoltinAuth(withConfiguration: MoltinConfig.default(withClientID: "12345"))
        auth.token = nil
        auth.expires = nil
        let session = MockURLSession()
        session.nextError = MoltinError.couldNotAuthenticate
        auth.http = MoltinHTTP(withSession: session)
        
        let expectationToFulfill = expectation(description: "Auth calls the method and runs the callback closure")
        
        auth.authenticate { (result) in
            switch result {
            case .success(_):
                XCTFail()
            default: XCTAssertTrue(true)
            }
            
            expectationToFulfill.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testAuthTokenNoRefreshRequired() {
        let auth = MoltinAuth(withConfiguration: MoltinConfig.default(withClientID: "12345"))
        auth.token = "12345"
        auth.expires = Date().addingTimeInterval(10000)
        
        let expectationToFulfill = expectation(description: "Auth calls the method and runs the callback closure")
        
        auth.authenticate { (result) in
            switch result {
            case .success(let response):
                XCTAssert(response.token == auth.token)
            default: XCTFail()
            }
            
            expectationToFulfill.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
}
