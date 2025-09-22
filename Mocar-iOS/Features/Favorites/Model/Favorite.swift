//
//  Favorite.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import Foundation
import FirebaseFirestore

struct Favorite: Codable, Identifiable {
    @DocumentID var id: String? 
    var userId: String
    var listingId: String
    var createdAt: Date
}

extension Favorite {
    var safeId: String { id ?? UUID().uuidString }
}


