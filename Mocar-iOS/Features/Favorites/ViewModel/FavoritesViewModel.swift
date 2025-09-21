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
    
    private let db = Firestore.firestore()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    init() {
        listenFavorites()
    }
    
    //실시간 업데이트
    func listenFavorites() {
        guard let userId = userId else { return }
        
        db.collection("favorites")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let docs = snapshot?.documents {
                    DispatchQueue.main.async {
                        self.favorites = docs.compactMap { try? $0.data(as: Favorite.self) }
                    }
                }
            }
    }
    
    // 찜 토글
    func toggleFavorite(_ listing: Listing) {
        guard let userId = userId, let listingId = listing.id else { return }
        
        let favId = "\(userId)_\(listingId)"
        let favRef = db.collection("favorites").document(favId)
        let listingRef = db.collection("listings").document(listingId)
        
        if favorites.contains(where: { $0.listingId == listingId }) {
            // 찜 해제
            favRef.delete { error in
                if error == nil {
                    listingRef.updateData([
                        "favoriteCount": FieldValue.increment(Int64(-1))
                    ])
                }
            }
        } else {
            // 찜 추가
            let newFavorite = Favorite(
                id: favId,
                userId: userId,
                listingId: listingId,
                createdAt: Date()
            )
            do {
                try favRef.setData(from: newFavorite) { error in
                    if error == nil {
                        listingRef.updateData([
                            "favoriteCount": FieldValue.increment(Int64(1))
                        ])
                    }
                }
            } catch {
                print("Encoding error: \(error)")
            }
        }
    }
    
    // 찜 여부 확인
    func isFavorite(_ listing: Listing) -> Bool {
        return favorites.contains(where: { $0.listingId == listing.id })
    }
}

