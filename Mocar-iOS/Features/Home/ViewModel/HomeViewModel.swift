//
//  HomeViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var selectedBrand: String? = nil
    @Published var favorites: [Listing] = []
    
    func selectBrand(_ brand: Brand) {
            selectedBrand = brand.name
        }
        
    var filteredListings: [Listing] {
        if let brand = selectedBrand {
            return Listing.listingData.filter { $0.brand == brand }
        }
        return Listing.listingData
    }
    
    func toggleFavorite(_ listing: Listing){
        if favorites.contains(where: {$0.id == listing.id}){
            favorites.removeAll{$0.id == listing.id}
        }else{
            favorites.append(listing)
        }
    }
}
