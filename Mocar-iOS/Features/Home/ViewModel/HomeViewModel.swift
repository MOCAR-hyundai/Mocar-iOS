//
//  HomeViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import Foundation
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    private let service = ListingService()
    
    @Published var listings: [Listing] = []
    @Published var selectedBrand: String? = nil
    @Published var favorites: [Listing] = []
    @Published var brands : [String] = []
    
    private let db = Firestore.firestore()
    
    init() {
        //listings 불러오기
        fetchListings()
    }
    
    func fetchListings() {
        service.fetchListings { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let listings):
                    self.listings = listings
                    //print("불러온 listings 브랜드들:", listings.map { $0.brand })
                    self.brands = Array(Set(listings.map{$0.brand})).sorted()
                    
                    if let first = self.brands.first {
                        self.selectedBrand = first
                    }
                case .failure(let error):
                    print("Error fetching listings: \(error)")
                }
            }
        }
    }
    
    func selectBrand(_ brand: String) {
            selectedBrand = brand
    }
        
    var filteredListings: [Listing] {
        if let brand = selectedBrand {
            return listings.filter { $0.brand == brand }
        }
        return listings
    }
    
    func toggleFavorite(_ listing: Listing){
        if favorites.contains(where: {$0.id == listing.id}){
            favorites.removeAll{$0.id == listing.id}
        }else{
            favorites.append(listing)
        }
    }
}
