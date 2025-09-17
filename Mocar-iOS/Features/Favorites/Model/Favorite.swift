//
//  Favorite.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import Foundation


struct Favorite: Codable, Identifiable {
    var id:UUID = UUID() 
    var userId: String
    var listingId: String
    var createdAt: Date
    

}


