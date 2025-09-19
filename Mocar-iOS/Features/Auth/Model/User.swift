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
    
    
    
    // MARK: - 프리뷰/목업용 이니셜라이저
      init(
          id: String? = nil,
          email: String = "example@email.com",
          name: String = "홍길동",
          photoUrl: String = "",
          phone: String = "010-0000-0000",
          rating: Double = 5.0,
          ratingCount: Int = 0,
          createdAt: Date? = nil,
          updatedAt: Date? = nil
      ) {
          self.id = id
          self.email = email
          self.name = name
          self.photoUrl = photoUrl
          self.phone = phone
          self.rating = rating
          self.ratingCount = ratingCount
          self.createdAt = createdAt
          self.updatedAt = updatedAt
      }
}
