//
//  TodoItem.swift
//  TodoFirebaseApp
//
//  Created by Developer on 2026-11-14.
//

import Foundation
import FirebaseFirestore

struct TodoItem: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var isCompleted: Bool = false
}
