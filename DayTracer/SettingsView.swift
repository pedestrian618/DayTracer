//
//  SettingsView.swift
//  DayTracer
//
//  Created by murate on 2023/12/03.
//


import SwiftUI
import FirebaseCore
import FirebaseAuth
import Firebase
import GoogleSignIn

struct SettingsView: View {
    @ObservedObject var authManager = AuthenticationManager.shared

    var body: some View {
        NavigationView {
            List {
                if authManager.isSignedIn {
                    // User is signed in
                    Section(header: Text("User Info")) {
                        NavigationLink(destination: UserSettingsView()) {
                            HStack {
                                ProfileImageView(url: authManager.userProfilePictureURL)
                                Text(authManager.userName ?? "Unknown")
                            }
                        }
                    }
                } else {
                    // User is not signed in
                    Section(header: Text("User Info")) {
                        NavigationLink(destination: LoginView()) {
                            Text("Unknown")
                        }
                    }
                }
                
                // Other settings sections
                // Add other setting options here
            }
            .navigationTitle("Settings")
        }
    }
}

struct LoginView: View {
    @ObservedObject var authManager = AuthenticationManager.shared

    var body: some View {
        VStack {
            Text("Sign in to continue")
            Button("Sign in with Google") {
                authManager.googleAuth()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(8)
        }.navigationTitle("User Settings")
    }
}

struct UserSettingsView: View {
    @ObservedObject var authManager = AuthenticationManager.shared
    
    var body: some View {
        Form {
            if let email = authManager.userEmail {
                Section(header: Text("Email")) {
                    Text(email)
                }
            }
            
            Section {
                Button("Sign Out") {
                    authManager.signOut()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("User Settings")
    }
}

struct ProfileImageView: View {
    let url: URL?
    
    var body: some View {
        if let url = url {
            AsyncImage(url: url) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
        }
    }
}

