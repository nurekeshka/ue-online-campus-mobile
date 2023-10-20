//
//  AuthorizationTestCase.swift
//  UETests
//
//  Created by Нурбек Болат on 04.10.2023.
//

import XCTest
@testable import UE

final class AuthorizationTestCase: XCTestCase {
    private let username: String = ""
    private let password: String = ""
    
    func testSessionCreation() async throws {
        var authorization = OnlineCampus.Authorization(username: username, password: password)
        let session: OnlineCampus.Authorization.Session = try await authorization.createSession()
        XCTAssertNotNil(session)
    }
    
    func testAuthCredentialsCheckingTrue() async throws {
        var authorization = OnlineCampus.Authorization(username: username, password: password)
        let result: Bool = try await authorization.isCorrect()
        XCTAssertTrue(result)
    }
    
    func testAuthSessionActivityTrue() async throws {
        var authorization = OnlineCampus.Authorization(username: username, password: password)
        let session: OnlineCampus.Authorization.Session = try await authorization.createSession()
        let result = try await session.isActive()
        XCTAssertTrue(result)
    }
    
    func testAuthSessionActivityFalse() async throws {
        let result = try await OnlineCampus.Authorization.Session(id: "123412341234").isActive()
        XCTAssertFalse(result)
    }
    
    func testAuthCredentialsCheckingFalse() async throws {
        var authorization = OnlineCampus.Authorization(username: "", password: "")
        let result: Bool = try await authorization.isCorrect()
        XCTAssertFalse(result)
    }
}
