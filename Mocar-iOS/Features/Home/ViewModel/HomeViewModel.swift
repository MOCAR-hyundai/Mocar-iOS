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
    
    @Published var listings: [Listing] = []
    @Published var selectedBrand: String? = nil
    @Published var favorites: [Favorite] = []
    @Published var brands : [String] = []
    
    private let db = Firestore.firestore()
    
    private var userId : String? {
        Auth.auth().currentUser?.uid
    }
    
    init() {
        //listings 불러오기
        fetchListings()
        fetchFavorites()
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
    
    func fetchFavorites(){
        guard let userId = userId else {return}
        
        db.collection("favorites")
            .whereField( "userId", isEqualTo: userId )
            .getDocuments { snapshot, error in
                if let error = error {
                    print("찜하기 목록 불러오기 실패: \(error)")
                    return
                }
                self.favorites = snapshot?.documents.compactMap{
                    try? $0.data(as: Favorite.self)
                } ?? []
            }
    }
    
    func toggleFavorite(_ listing: Listing){
        guard let userId = userId, let listingId = listing.id else {return}
        
        let favId = "\(userId)_\(listingId)" // favorites 테이블 id
        let favRef = db.collection( "favorites" ).document( favId )
        let listingRef = db.collection( "listings" ).document( listingId )
        
        if favorites.contains(where: {$0.listingId == listingId}){
            //찜해제
            favRef.delete{ error in
                if let error = error {
                    print("찜 해제 실패: \(error)")
                    return
                }
                listingRef.updateData([
                    "favoriteCount": FieldValue.increment(Int64(-1))
                ])
                DispatchQueue.main.async {
                    self.favorites.removeAll{ $0.listingId == listingId}
                }
                
            }
        }else{
            //찜하기
            let newFavorite = Favorite(
                id: favId,
                userId: userId,
                listingId: listingId,
                createdAt: Date()
            )
            
            do {
                try favRef.setData(from: newFavorite){ error in
                    if let error = error {
                        print("찜하기 실패: \(error)")
                        return
                    }
                    listingRef.updateData([
                        "favoriteCount": FieldValue.increment(Int64(1))
                    ])
                    DispatchQueue.main.async {
                        self.favorites.append(newFavorite)
                    }
                }
            } catch {
                print("Firebase encode errer: \(error)")
            }
            
        }
    }
    
    func isFavorite(_ listing: Listing) -> Bool {
        return favorites.contains(where : {$0.listingId == listing.id})
    }
}
