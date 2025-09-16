//
//  Listing.swift
//  Mocar-iOS
//
//  Created by Admin on 9/15/25.
//

import Foundation

struct ListingStats: Codable {
    //var viewCount: Int
    var favoriteCount: Int      //찜 횟수
}

struct Listing : Identifiable, Codable{
    var id: String?
    var sellerId: String
    var title: String
    var brand: String
    var model: String
    var trim: String
    var year: Int
    var mileage: Int
    var fuel: String
    var transmission: String
    var price: Int
    var region: String
    var description: String
    var images: [String]
    var status: String
    //var stats: ListingStats
    var createdAt: Date
    var updatedAt: Date
}

