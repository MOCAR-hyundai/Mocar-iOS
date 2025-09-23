//
//  Listing.swift
//  Mocar-iOS
//
//  Created by Admin on 9/15/25.
//

import Foundation
import FirebaseFirestore

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

struct Listing : Identifiable, Codable{
    @DocumentID var id: String?
    var sellerId: String
    var plateNo: String?
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
    var carType: String?
    
    var priceInManwon: Int {
            return price / 10000
    }
    
}
