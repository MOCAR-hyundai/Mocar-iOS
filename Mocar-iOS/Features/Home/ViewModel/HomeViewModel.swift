//
//  HomeViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class HomeViewModel: ObservableObject {
    private let service = ListingService()
    
    let favoritesViewModel: FavoritesViewModel
    
    @Published var listings: [Listing] = []
    @Published var selectedBrand: String? = nil
    @Published var brands : [String] = []
    
    private let db = Firestore.firestore()
    
    
    init(favoriteViewModel: FavoritesViewModel) {
        self.favoritesViewModel = favoriteViewModel
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
    //브랜드 필터링
    var filteredListings: [Listing] {
        if let brand = selectedBrand {
            return listings.filter { $0.brand == brand }
        }
        return listings
    }
    
}
