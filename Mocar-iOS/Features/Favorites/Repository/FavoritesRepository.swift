//
//  FavoritesRepository.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import Foundation
import FirebaseFirestore

final class FavoriteRepository {
    private let db = Firestore.firestore()
    
    // MARK: - 실시간 구독 (AsyncStream)
    //Firestore의 addSnapshotListener을 사용하여 실시간 구독
//    func listenFavorites(userId: String) -> AsyncStream<[Favorite]> {
//        AsyncStream { continuation in
//            let listener = db.collection("favorites")
//                .whereField("userId", isEqualTo: userId)
//                .addSnapshotListener { snapshot, error in
//                    if let error = error {
//                        print("ERROR MESSAGE -- listenFavorites error: \(error)")
//                        continuation.yield([])
//                        return
//                    }
//                    
//                    let favorites = snapshot?.documents.compactMap {
//                        try? $0.data(as: Favorite.self)
//                    } ?? []
//                    
//                    Task {
//                        var validFavorites: [Favorite] = []
//                        for doc in snapshot?.documents ?? [] {
//                            if let fav = try? doc.data(as: Favorite.self) {
//                                let listingDoc = try? await self.db.collection("listings")
//                                    .document(fav.listingId)
//                                    .getDocument()
//                                
//                                if listingDoc?.exists == true {
//                                    validFavorites.append(fav)
//                                } else {
//                                    //  listings에 없으면 favorites에서도 삭제
//                                    try? await doc.reference.delete()
//                                    print(" orphan favorite 삭제됨: \(fav.listingId)")
//                                }
//                            }
//                        }
//                        continuation.yield(validFavorites)
//                        
//                    }
//                    
//                    //continuation.yield(favorites)
//                    
//                    print("Firestore에 favorites 가져오기 성공")
//                }
//            
//            // Task가 취소되면 Firestore 리스너 해제
//            continuation.onTermination = { _ in
//                listener.remove()
//            }
//        }
//    }
    func listenFavorites(userId: String) -> AsyncStream<[Favorite]> {
        AsyncStream { continuation in
            let listener = db.collection("favorites")
                .whereField("userId", isEqualTo: userId)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("❌ listenFavorites error: \(error)")
                        continuation.yield([])
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        continuation.yield([])
                        return
                    }
                    
                    // ✅ orphan 제거 및 유효 favorites만 yield
                    Task.detached {
                        var validFavorites: [Favorite] = []
                        
                        for doc in documents {
                            if let fav = try? doc.data(as: Favorite.self) {
                                let listingDoc = try? await self.db.collection("listings")
                                    .document(fav.listingId)
                                    .getDocument()
                                
                                if listingDoc?.exists == true {
                                    validFavorites.append(fav)
                                } else {
                                    try? await doc.reference.delete()
                                    print("🗑 orphan favorite 삭제됨: \(fav.listingId)")
                                }
                            }
                        }
                        
                        continuation.yield(validFavorites)
                        print("✅ listenFavorites yield count: \(validFavorites.count)")
                    }
                }
            
            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }
    
    
    // MARK: - 단발 조회
    func fetchFavorites(userId: String) async throws -> [Favorite] {
        let snapshot = try await db.collection("favorites")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        var validFavorites: [Favorite] = []
        for doc in snapshot.documents {
            if let fav = try? doc.data(as: Favorite.self) {
                let listingDoc = try? await db.collection("listings")
                    .document(fav.listingId)
                    .getDocument()
                
                if listingDoc?.exists == true {
                    validFavorites.append(fav)
                } else {
                    try? await doc.reference.delete() // ❌ orphan 제거
                }
            }
        }
        
        print("favorites 단발 조회 성공")
        return validFavorites
    }
    
    func isFavorite(userId: String, listingId: String) async throws -> Bool {
        let snapshot = try await db.collection("favorites")
            .whereField("userId", isEqualTo: userId)
            .whereField("listingId", isEqualTo: listingId)
            .getDocuments()
        print("isFavorites 단발 조회 성공")
        return !snapshot.documents.isEmpty
    }
    
    // MARK: - 추가
    func addFavorite(_ favorite: Favorite) async throws {
        _ = try db.collection("favorites").addDocument(from: favorite)
    }
    
    // MARK: - 삭제
    func removeFavorite(favId: String) async throws {
        try await db.collection("favorites").document(favId).delete()
    }
}
