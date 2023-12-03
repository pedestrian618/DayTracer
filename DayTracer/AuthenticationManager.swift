//
//  AuthenticationManager.swift
//  DayTracer
//
//  Created by murate on 2023/12/03.
//

import Firebase
import GoogleSignIn

class AuthenticationManager: ObservableObject {
    @Published var isSignedIn = false
    @Published var userName: String?
    @Published var userEmail: String?
    @Published var userProfilePictureURL: URL?

    static let shared = AuthenticationManager()

    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    private init() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.isSignedIn = user != nil
            self?.userName = user?.displayName
            self?.userEmail = user?.email
            self?.userProfilePictureURL = user?.photoURL
        }
    }

    deinit {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func googleAuth() {
        guard let clientID:String = FirebaseApp.app()?.options.clientID else { return }
        let config:GIDConfiguration = GIDConfiguration(clientID: clientID)
        
        let windowScene:UIWindowScene? = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootViewController:UIViewController? = windowScene?.windows.first!.rootViewController!
        
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController!) { result, error in
            guard error == nil else {
                print("GIDSignInError: \(error!.localizedDescription)")
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,accessToken: user.accessToken.tokenString)
            self.login(credential: credential)
        }
    }

    func login(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("SignInError: \(error.localizedDescription)")
                return
            }
            self.isSignedIn = true
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            isSignedIn = false
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
}
