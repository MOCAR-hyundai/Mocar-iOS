//
//  PriceIndex.swift
//  Mocar-iOS
//
//  Created by Admin on 9/23/25.
//

import Foundation

struct PriceIndex: Codable {
    var id: String
    var avgPrice: Int
    var minPrice: Int
    var maxPrice: Int
    var mileageBucket: [String: Int]?
    var updatedAt: String?
}
