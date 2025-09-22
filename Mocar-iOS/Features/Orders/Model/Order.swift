//
//  Order.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import Foundation
import FirebaseFirestore

struct Order: Codable, Identifiable {
    @DocumentID var id: String?      // Firestore 문서 ID (자동 매핑)
    var orderId: String              // 명시적으로 저장된 orderId
    var listingId: String
    var buyerId: String
    var sellerId: String
    var status: OrderStatus
    
    var reservedAt: String?          // ISO8601 문자열
    var soldAt: String?
}

enum OrderStatus: String, Codable {
    case reserved
    case sold
}
