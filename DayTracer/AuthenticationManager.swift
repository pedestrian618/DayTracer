//
//  AuthenticationManager.swift
//  DayTracer
//
//  Created by murate on 2023/12/03.
//

import Firebase
import FirebaseAuth
import GoogleSignIn

class AuthenticationManager: ObservableObject {
    @Published var isSignedIn = false
    @Published var userName: String?
    @Published var userEmail: String?
    @Published var userProfilePictureURL: URL?

    static let shared = AuthenticationManager()

    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    private init() {
        // 起動時に、Firebase が永続化している既存のサインイン状態を即時反映する。
        // （リスナーの初回コールバックを待たずに正しい状態にしておくことで、
        //  Settings などが「ログイン済みなのに未サインイン表示」になる不整合を防ぐ）
        updateState(for: Auth.auth().currentUser)

        // 以降のサインイン/サインアウトを監視して反映する。
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.updateState(for: user)
        }
    }

    deinit {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    /// Firebase の `User` から公開プロパティを更新する（認証状態の単一の反映点）。
    private func updateState(for user: User?) {
        isSignedIn = user != nil
        userName = user?.displayName
        userEmail = user?.email
        userProfilePictureURL = user?.photoURL
    }

    func googleAuth() {
        guard let clientID: String = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)

        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = windowScene?.windows.first?.rootViewController else { return }

        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard error == nil else {
                print("GIDSignInError: \(error!.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            self?.login(credential: credential)
        }
    }

    func login(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [weak self] _, error in
            if let error = error {
                print("SignInError: \(error.localizedDescription)")
                return
            }
            // 成功時の最新状態は addStateDidChangeListener が反映する。
            self?.isSignedIn = true
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            // リスナーでも反映されるが、UI へ即時反映するためここでも更新する。
            updateState(for: nil)
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
}
