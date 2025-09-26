//
//  Listing.swift
//  Mocar-iOS
//
//  Created by Admin on 9/15/25.
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct ListingStats: Codable {
    var viewCount: Int
    var favoriteCount: Int      //찜 횟수
}

enum ListingStatus: String, Codable {
    case onSale = "on_sale"
    case reserved = "reserved"
    case soldOut = "sold"
    case draft = "draft"
}

//변환 프로퍼티
extension ListingStatus {
    var displayText: String {
        switch self {
        case .onSale: return "판매중"
        case .reserved: return "예약중"
        case .soldOut: return "판매완료"
        case .draft: return "임시저장"
        }
    }

    var displayColor: Color {
        switch self {
        case .onSale: return .green
        case .reserved: return .orange
        case .soldOut: return .red
        case .draft: return .gray
        }
    }
}


struct Listing : Identifiable, Codable{
    @DocumentID var id: String?
    var sellerId: String
    var plateNo: String
    var title: String
    var brand: String   
    var model: String
    var trim: String
    var year: Int
    var mileage: Int
    var fuel: String
    var transmission: String?
    var price: Int
    var region: String
    var description: String
    var images: [String]
    var status: ListingStatus
    var stats: ListingStats
    //@ServerTimestamp var createdAt: Date?
    //@ServerTimestamp var updatedAt: Date?
    var createdAt: String
    var updatedAt: String?
    var carType: String
    
    
}

extension Listing {
    var safeId: String { id ?? UUID().uuidString }
}

extension Listing {
    func with(status: ListingStatus) -> Listing {
        var copy = self
        copy.status = status
        return copy
    }
}
