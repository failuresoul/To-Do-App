//
//  AuthViewModel.swift
//  TodoFirebaseApp
//
//  Created by Developer on 2026-11-14.
//

import Foundation
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: User?

    init() {
        self.currentUser = Auth.auth().currentUser
    }
}
