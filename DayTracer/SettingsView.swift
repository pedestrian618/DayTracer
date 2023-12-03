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
    //@State private var isSignedIn = false // ログイン状態の追跡
    @ObservedObject var authManager = AuthenticationManager.shared
    var body: some View {
        VStack {
            if authManager.isSignedIn {
                // ログイン済みの場合
                Text("ログイン済み: \(authManager.userName ?? "不明なユーザー")")
                Text("メール: \(authManager.userEmail ?? "不明なメールアドレス")")
                if let url = authManager.userProfilePictureURL {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                }
                Button("ログアウト") {
                    authManager.signOut()
                }
            } else {
                // ログインしていない場合
                Button("GoogleアカウントでLogin") {
                    authManager.googleAuth()
                }
            }
        }
    }
//    private func googleAuth() {
//            
//            guard let clientID:String = FirebaseApp.app()?.options.clientID else { return }
//            let config:GIDConfiguration = GIDConfiguration(clientID: clientID)
//            
//            let windowScene:UIWindowScene? = UIApplication.shared.connectedScenes.first as? UIWindowScene
//            let rootViewController:UIViewController? = windowScene?.windows.first!.rootViewController!
//            
//            GIDSignIn.sharedInstance.configuration = config
//            
//            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController!) { result, error in
//                guard error == nil else {
//                    print("GIDSignInError: \(error!.localizedDescription)")
//                    return
//                }
//                
//                guard let user = result?.user,
//                      let idToken = user.idToken?.tokenString
//                else {
//                    return
//                }
//                
//                let credential = GoogleAuthProvider.credential(withIDToken: idToken,accessToken: user.accessToken.tokenString)
//                self.login(credential: credential)
//            }
//        }
//        
//    private func login(credential: AuthCredential) {
//        Auth.auth().signIn(with: credential) { (authResult, error) in
//            if let error = error {
//                print("SignInError: \(error.localizedDescription)")
//                return
//            }
//            // ログイン状態を更新
//            self.isSignedIn = true
//
//        }
//    }
//    
//    private func signOut() {
//            do {
//                try Auth.auth().signOut()
//                isSignedIn = false // ログイン状態を更新
//            } catch let signOutError as NSError {
//                print("Error signing out: \(signOutError)")
//            }
//        }

}
