//
//  AuthorizationView.swift
//  UE
//
//  Created by Нурбек Болат on 08.10.2023.
//

import SwiftUI

struct AuthorizationView: View {
    var body: some View {
        VStack {
            AuthForm()
        }
        .padding(.horizontal)
    }
}

private struct AuthForm: View {
    @State public var username: String = ""
    @State public var password: String = ""
    
    @State public var authenticate: Bool = false
    @State public var showingAlert: Bool = false
    
    var body: some View {
        Text("Sign in")
            .font(.system(size: 26))
            .bold()
        
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(.plain)
            Divider()
            
            SecureField("Password", text: $password)
                .textFieldStyle(.plain)
            Divider()
        }
        .padding()
        
        Button(action: {
            var authorization = OnlineCampus.Authorization(username: username, password: password)
            
            Task {
                if (try await authorization.isCorrect()) {
                    UserDefaults.standard.set(username, forKey: "username")
                    UserDefaults.standard.set(password, forKey: "password")
                    UserDefaults.standard.set(authorization.lastSession, forKey: "session")
                    authenticate = true
                } else {
                    showingAlert = true
                }
            }
        }, label: {
            Text("Login")
                .bold()
                .foregroundStyle(.white)
                .frame(maxWidth: 140, maxHeight: 30)
                .background(
                    RoundedRectangle(cornerRadius: 7.0, style: .continuous)
                        .fill(Color.red)
                )
        }).alert(Text("Could not authenticate"),
                 isPresented: $showingAlert,
                 actions: {Button("OK") { }},
                 message: {Text("Please try to enter auth credentials again.")
        })
    }
}

#Preview {
    AuthorizationView()
}
