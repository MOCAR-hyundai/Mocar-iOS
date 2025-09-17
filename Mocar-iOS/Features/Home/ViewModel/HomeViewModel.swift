//
//  HomeViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var selectedBrand: String? = nil
    
    func selectBrand(_ brand: Brand) {
            selectedBrand = brand.name
        }
        
    var filteredListings: [Listing] {
        if let brand = selectedBrand {
            return Listing.listingData.filter { $0.brand == brand }
        }
        return Listing.listingData
    }
}
