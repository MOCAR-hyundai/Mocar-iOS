//
//  FavoritesViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/21/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Favorite] = []
    @Published var favoriteListings: [Listing] = []
    
    private let listingRepository: ListingRepository
    private let favoriteRepository: FavoriteRepository
    private var userId: String? { Auth.auth().currentUser?.uid }
    
    init(listingRepository: ListingRepository,
         favoriteRepository: FavoriteRepository) {
        self.listingRepository = listingRepository
        self.favoriteRepository = favoriteRepository
        listenFavorites()
    }
    
//    var favoritesCount: Int {
//        favorites.count
//    }
    
//    //실시간 업데이트
//    func listenFavorites() {
//        guard let userId = userId else { return }
//        
//        db.collection("favorites")
//            .whereField("userId", isEqualTo: userId)
//            .addSnapshotListener { snapshot, error in
//                if let docs = snapshot?.documents {
//                    DispatchQueue.main.async {
//                        self.favorites = docs.compactMap { try? $0.data(as: Favorite.self) }
//                    }
//                }
//            }
//    }
//    
//    // 찜 토글
//    func toggleFavorite(_ listing: Listing) {
//        guard let userId = userId, let listingId = listing.id else { return }
//        
//        let favId = "\(userId)_\(listingId)"
//        let favRef = db.collection("favorites").document(favId)
//        let listingRef = db.collection("listings").document(listingId)
//        
//        if favorites.contains(where: { $0.listingId == listingId }) {
//            // 찜 해제
//            favRef.delete { error in
//                if error == nil {
//                    listingRef.updateData([
//                        "favoriteCount": FieldValue.increment(Int64(-1))
//                    ])
//                }
//            }
//        } else {
//            // 찜 추가
//            let newFavorite = Favorite(
//                id: favId,
//                userId: userId,
//                listingId: listingId,
//                createdAt: Date()
//            )
//            do {
//                try favRef.setData(from: newFavorite) { error in
//                    if error == nil {
//                        listingRef.updateData([
//                            "favoriteCount": FieldValue.increment(Int64(1))
//                        ])
//                    }
//                }
//            } catch {
//                print("Encoding error: \(error)")
//            }
//        }
//    }
    
    
    private func listenFavorites(){
        guard let userId = userId else {
            return
        }
        print("🟡 Starting to listen favorites for user: \(userId)")
        favoriteRepository.listenFavorites(userId: userId) { [weak self] favs in
            //Task { await self?.updateFavorites(favs) }
//            Task { [weak self] in
//                await self?.updateFavorites(favs)
//            }
            Task { @MainActor in
                        await self?.updateFavorites(favs)
                    }
        }
    }
    

    private func updateFavorites(_ favs: [Favorite]) async {
//        self.favorites = favs
//        let ids = favs.map { $0.listingId }
//        do {
//            let listings = try await listingRepository.fetchListings(byIds: ids)
//            await MainActor.run {
//                self.favoriteListings = listings
//            }
//        } catch {
//            print("Failed to load favorite listings: \(error)")
//        }
        
        
        
//        await MainActor.run {
//            if !self.favorites.map({ $0.id }) .elementsEqual(favs.map({ $0.id })) {
//                   self.favorites = favs
//               }
//            }
//
//            let ids = favs.map { $0.listingId }
//            do {
//                let listings = try await listingRepository.fetchListings(byIds: ids)
//                await MainActor.run {
//                    if !self.favoriteListings.map({ $0.id }) .elementsEqual(favs.map({ $0.id })) {
//                           self.favoriteListings = listings
//                       }
//                   
//                }
//            } catch {
//                print("❌ Failed to load favorite listings: \(error)")
//            }
        
        await MainActor.run {
                if favorites.map(\.id) != favs.map(\.id) {
                    favorites = favs
                }
         }
        let ids = favs.map { $0.listingId }
            do {
                let listings = try await listingRepository.fetchListings(byIds: ids)
                await MainActor.run {
                    if favoriteListings.map(\.id) != listings.map(\.id) {
                        favoriteListings = listings
                    }
                }
            } catch {
                print("❌ Failed to load favorite listings: \(error)")
            }
        
    }
    
    func toggleFavorite(_ listing: Listing) {
        guard let userId = userId, let listingId = listing.id else {
            print("❌ toggleFavorite: Missing userId or listingId")
            return
        }
        
            let favId = "\(userId)_\(listingId)"
//
//            if isFavorite(listing) {
//                // 찜 해제
//                favoriteRepository.removeFavorite(favId: favId) { error in
//                    if error == nil {
//                        self.updateFavoriteCount(listingId: listingId, increment: -1)
//                    }
//                }
//            } else {
//                // 찜 추가
//                let newFavorite = Favorite(
//                    id: favId,
//                    userId: userId,
//                    listingId: listingId,
//                    createdAt: Date()
//                )
//                favoriteRepository.addFavorite(newFavorite) { error in
//                    if error == nil {
//                        self.updateFavoriteCount(listingId: listingId, increment: 1)
//                    }
//                }
//            }
        if isFavorite(listing) {
            // 로컬 먼저 업데이트
                    favorites.removeAll { $0.listingId == listingId }
                    favoriteRepository.removeFavorite(favId: favId)
                } else {
                    let newFavorite = Favorite(
                        id: favId,
                        userId: userId,
                        listingId: listingId,
                        createdAt: Date()
                    )
                    favorites.append(newFavorite)
                    favoriteRepository.addFavorite(newFavorite)
                }
                
        }
    private func updateFavoriteCount(listingId: String, increment: Int64) {
        //            Task {
        //                let docRef = Firestore.firestore().collection("listings").document(listingId)
        //                docRef.updateData([
        //                    "favoriteCount": FieldValue.increment(increment)
        //                ])
        //            }
        Task {
            let docRef = Firestore.firestore().collection("listings").document(listingId)
            try? await docRef.updateData([
                "favoriteCount": FieldValue.increment(increment)
            ])
        }
    }
    
    // 찜 여부 확인
    func isFavorite(_ listing: Listing) -> Bool {
        let result = favorites.contains(where: { $0.listingId == listing.id })
                print("🔍 isFavorite(\(listing.id ?? "nil")): \(result)")
                return result
    }
}

