//
//  ContentView.swift
//  UE
//
//  Created by Нурбек Болат on 30.09.2023.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("username") private var username: String = ""
    @AppStorage("password") private var password: String = ""
    @AppStorage("session") private var lastSession: String = ""
    @State private var authenticated: Bool = false
    @State private var processing: Bool = true
    @State private var events: [Event] = []
    
    var body: some View {
        VStack {
            if processing {
                ProgressView()
            } else {
                if (!authenticated) {
                    AuthorizationView()
                } else {
                    TimetableView(events: events)
                }
            }
        }
        .task {
            do {
                let session = OnlineCampus.Authorization.Session(id: lastSession)
                
                if try await session.isActive() {
                    authenticated = true
                } else {
                    var authorization = OnlineCampus.Authorization(
                        username: username, password: password)
                    
                    authenticated = try await authorization.isCorrect()
                    lastSession = authorization.lastSession.id
                }
                
                let timetable = OnlineCampus.Timetable(session: OnlineCampus.Authorization.Session(id: lastSession))
                events = try await timetable.fetch(from: OnlineCampus.Timetable.today())
            } catch {
                print("Some error occured.")
            }
            
            processing = false
        }
    }
}

#Preview {
    ContentView()
}
