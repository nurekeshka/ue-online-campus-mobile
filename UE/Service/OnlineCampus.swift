//
//  OnlineCampus.swift
//  UE
//
//  Created by Нурбек Болат on 08.10.2023.
//

import SwiftSoup
import Foundation

public struct OnlineCampus {
    public struct Timetable {
        public let link: URL = URL(string: "https://onlinecampus.ue-germany.de/scripts/mgrqispi.dll")!
        public let session: OnlineCampus.Authorization.Session
        
        enum ParsingError: Error {
            case tableFindingError(String)
            case tableParsingError(String)
            case linksParsingError(String)
        }
        
        public init(session: OnlineCampus.Authorization.Session) {
            self.session = session
        }
        
        public func fetch(from date: String) async throws -> [Event] {
            let params = [
                "wk": date, "Aktualisieren": "Refresh", "APPNAME": "CampusNet",
                "PRGNAME": "SCHEDULER", "ARGUMENTS": "sessionno,menuno,wk,given_alpha,given_number",
                "sessionno": self.session.id, "given_number": "1"
            ]
            
            let (data, _) = try await Requests.get(url: link, params: params)
            return try OnlineCampus.Timetable.parse(from: String(data: data, encoding: .utf8)!)
        }
        
        public static func parse(from html: String) throws -> [Event] {
            let document: Document = try SwiftSoup.parse(html)
            
            guard let elements: Elements = try? document.getElementsByTag("table") else {
                throw ParsingError.tableFindingError("Table elements could not be found.") }
            
            guard let table: Element = elements.first() else {
                throw ParsingError.tableParsingError("Table element was not found.")
            }
            
            var events: [Event] = []
            
            for trow in try table.getElementsByTag("tr") {
                for tdata in try trow.getAllElements() {
                    if tdata.hasAttr("rowspan") {
                        let span: [Substring] = try tdata.getElementsByTag("span").text().split(separator: "\n")
                        let time: String = String(span[0])
                        let room: String = String(span[1])
                        let day: String = String(try tdata.attr("abbr").split(separator: " ")[0])
                        
                        guard let link: Element = try? tdata.getElementsByTag("a").first() else {
                            throw ParsingError.linksParsingError("Link element was not found.")
                        }
                        
                        let name: String = try link.attr("title")
                        events.append(Event(room: room, name: name, day: day, time: time))
                    }
                }
            }
            
            return [Event(room: "Room 1", name: "Cinema", day: "Friday", time: "00:00")]
        }
        
        public static func today() -> String {
            let date = Date()
            return "\(date.formatted(.dateTime.day()))/\(date.formatted(.dateTime.month(.twoDigits)))/\(date.formatted(.dateTime.year()))"
        }
    }
    
    public struct Authorization {
        public struct Session {
            public let id: String
            public let link: URL = URL(string: "https://onlinecampus.ue-germany.de/scripts/mgrqispi.dll")!
            
            public init(id: String) {
                self.id = id
            }
            
            public func isActive() async throws -> Bool {
                let (data, _) = try await Requests.get(url: link, params: [
                    "APPNAME": "CampusNet", "PRGNAME": "MLSSTART",
                    "ARGUMENTS": "-N\(self.id)"
                ])
                
                let document: Document = try SwiftSoup.parse(String(data: data, encoding: .utf8)!)
                let elements: Elements = try document.getElementsByTag("h1")
                return try elements.text().starts(with: "Welcome")
            }
        }
        
        private let username: String
        private let password: String
        
        public let link: URL = URL(string: "https://onlinecampus.ue-germany.de/scripts/mgrqispi.dll")!
        public var lastSession: Session = Session(id: "")
        
        public init(username: String, password: String) {
            self.username = username
            self.password = password
        }
        
        public mutating func isCorrect() async throws -> Bool {
            let session = try await self.createSession()
            return session.id != ""
        }
        
        public mutating func createSession() async throws -> Session {
            let data = [
                "APPNAME": "CampusNet", "PRGNAME": "LOGINCHECK",
                "ARGUMENTS": "clino,usrname,pass", "clino": "000000000000002",
                "usrname": username, "pass": password
            ]
            
            let (_, response) = try await Requests.postMultipart(url: link, data: data)
            let sessionId: String = Authorization.getSessionId(
                from: response.getHeader(forKey: "REFRESH") ?? "")
            
            self.lastSession = Session(id: sessionId)
            return self.lastSession
        }
        
        static public func getSessionId(from header: String) -> String {
            if (header == "") {
                return ""
            }
            
            let urlString: Substring = header.split(separator: ";")[1]
            let urlArguments: Substring = urlString.split(separator: "&")[2].split(separator: "=")[1]
            let sessionId: Substring = urlArguments.split(separator: ",")[0].dropFirst(2)
            
            return String(sessionId)
        }
    }
}

public struct Requests {
    public static func get(url: URL, params: Dictionary<String, String>) async throws -> (Data, URLResponse) {
        let query: [URLQueryItem] = params.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url.appending(queryItems: query))
        return (data, response)
    }
    
    public static func postMultipart(url: URL, data: Dictionary<String, String>,
        timeout: Double = 30.0) async throws -> (Data, URLResponse) {

        var request: URLRequest = URLRequest(url: url, timeoutInterval: timeout)
        let multipart: Multipart = Multipart(from: data)
        
        request.httpMethod = "POST"
        request.setValue(multipart.contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = multipart.data
        
        let (data, response) = try await URLSession.shared.data(for: request)
        return (data, response)
    }
}

public struct Multipart {
    public var contentType: String
    public var boundary: String
    public var data: Data
    public var closed: Bool = false
    
    public init(from dictionary: Dictionary<String, String>) {
        self.boundary = Multipart.generateBoundary()
        self.contentType = "multipart/form-data; boundary=\(boundary)"
        
        self.data = Data()
        
        for (key, value) in dictionary {
            self.append(key: key, value: value)
        }
        
        self.close()
    }
    
    private mutating func append(key: String, value: String) {
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
        data.append(value.data(using: .utf8)!)
        data.append("\r\n".data(using: .utf8)!)
    }
    
    private mutating func close() {
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        self.closed = true
    }
    
    private static func generateBoundary() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
}

extension URLResponse {
    func getHeader(forKey key: String) -> String? {
        (self as? HTTPURLResponse)?.allHeaderFields[key] as? String
    }
}
