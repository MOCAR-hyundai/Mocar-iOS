//
//  User.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?        // uid
    let email: String
    let name: String
    let photoUrl: String
    let phone: String
    let rating: Double
    let ratingCount: Int
    let createdAt: Date?
    let updatedAt: Date?
}
