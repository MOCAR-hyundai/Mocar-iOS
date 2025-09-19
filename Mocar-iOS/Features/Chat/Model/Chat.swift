//
//  Chat.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import Foundation
import FirebaseFirestore

struct Chat: Codable, Identifiable {
    @DocumentID var id: String?      // chatId
    var buyerId: String
    var sellerId: String
    var listingId: String
    var lastMessage: String?
    var listingTitle: String
    var lastAt: Date
}
