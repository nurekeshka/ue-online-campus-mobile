//
//  Timetable.swift
//  UETests
//
//  Created by Нурбек Болат on 16.10.2023.
//

import XCTest
@testable import UE

final class Timetable: XCTestCase {
    private let username: String = ""
    private let password: String = ""
    
    func testFetching() async throws {
        var authorization = OnlineCampus.Authorization(username: username, password: password)
        let session: OnlineCampus.Authorization.Session = try await authorization.createSession()
        
        var timetable = OnlineCampus.Timetable(session: session)
        var data: [Event] = try await timetable.fetch(from: OnlineCampus.Timetable.today())
        XCTAssertNotNil(data)
    }
}
