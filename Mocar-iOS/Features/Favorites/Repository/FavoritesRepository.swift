//
//  FavoritesRepository.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import Foundation
import FirebaseFirestore

class FavoriteRepository {
    private let db = Firestore.firestore()
    
    // 특정 유저의 찜 목록 실시간 구독
    func listenFavorites(userId: String, completion: @escaping ([Favorite]) -> Void) {
        //        db.collection("favorites")
        //            .whereField("userId", isEqualTo: userId)
        //            .addSnapshotListener { snapshot, error in
        //                if let docs = snapshot?.documents {
        //                    let favorites = docs.compactMap { try? $0.data(as: Favorite.self) }
        //                    //항상 MainActor에서 실행
        //                    DispatchQueue.main.async {
        //                        completion(favorites)
        //                    }
        //                } else {
        //                    DispatchQueue.main.async {
        //                        completion([])
        //                    }
        //                }
        //            }
        db.collection("favorites")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let docs = snapshot?.documents {
                    let favorites = docs.compactMap { try? $0.data(as: Favorite.self) }
                    // ✅ 메인 스레드에서 completion 호출
                    DispatchQueue.main.async {
                        completion(favorites)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            }
    }
        // 찜 추가
    func addFavorite(_ favorite: Favorite, completion: ((Error?) -> Void)? = nil) {
        guard let favId = favorite.id else { return }
        //        do {
        //            try db.collection("favorites").document(favId).setData(from: favorite) { error in
        //                completion?(error)
        //            }
        //        } catch {
        //            completion?(error)
        //        }
        do {
            try db.collection("favorites").document(favId).setData(from: favorite) { error in
                DispatchQueue.main.async {
                    completion?(error)
                }
            }
        } catch {
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
    // 찜 삭제
    func removeFavorite(favId: String, completion: ((Error?) -> Void)? = nil) {
        //        db.collection("favorites").document(favId).delete { error in
        //            completion?(error)
        //        }
        db.collection("favorites").document(favId).delete { error in
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
}

