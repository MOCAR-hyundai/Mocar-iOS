//
//  Message.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import SwiftUI
import FirebaseFirestore

struct Message: Codable, Identifiable {
    @DocumentID var id: String?      // msgId
    var senderId: String
    var text: String?
    var imageUrl: String?
    var createdAt: Date
    var readBy: [String]
}
