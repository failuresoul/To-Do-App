//
//  FirebaseService.swift
//  TodoFirebaseApp
//
//  Created by Developer on 2026-11-14.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class FirebaseService {
    static let shared = FirebaseService()
    let auth = Auth.auth()
    let db = Firestore.firestore()

    private init() {}
}
