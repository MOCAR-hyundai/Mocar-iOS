//
//  HomeViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var selectedBrand: CarBrand? = nil
    @Published var brands : [CarBrand] = []
    
    private let service : HomeService
    let favoritesViewModel: FavoritesViewModel
    
    init(service: HomeService, favoritesViewModel: FavoritesViewModel) {
        self.service = service
        self.favoritesViewModel = favoritesViewModel
    }
    
    func fetchListings() async {
        do {
            let (listings, brands) = try await service.getListingsAndBrands()
            self.listings = listings
            self.brands = brands
            self.selectedBrand = brands.first
        } catch {
            print(" Error fetching listings: \(error)")
        }
        
    }
    
    func selectBrand(_ brand: CarBrand) {
            selectedBrand = brand
    }
    //브랜드 필터링
    var filteredListings: [Listing] {
        if let brand = selectedBrand {
            return listings.filter { $0.brand == brand.name }
        }
        return listings
    }
    
}
