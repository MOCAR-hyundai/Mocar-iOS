//
//  ListingService.swift
//  Mocar-iOS
//
//  Created by Admin on 9/19/25.
//

import SwiftUI

import FirebaseFirestore

class ListingService {
    private let db = Firestore.firestore()
    
    // 전체 매물 불러오기
    func fetchListings(completion: @escaping (Result<[Listing], Error>) -> Void) {
        db.collection("listings").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let snapshot = snapshot {
                var decodedListings: [Listing] = []
                
                for doc in snapshot.documents {
                    do {
                        let listing = try doc.data(as: Listing.self)
                        decodedListings.append(listing)
                    } catch {
                        print("Decoding error in \(doc.documentID): \(error)")
                        print("Raw data:", doc.data())
                    }
                }
                //디버깅용
                //let brands = decodedListings.map { $0.brand }
                //print("브랜드 목록: \(brands)")
                print("listings count:", decodedListings.count)
                completion(.success(decodedListings))
            }
        }
        
        // 단일 매물 불러오기
        func fetchListing(id: String, completion: @escaping (Result<Listing, Error>) -> Void) {
            db.collection("listings").document(id).getDocument { doc, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let doc = doc, doc.exists {
                    do {
                        let listing = try doc.data(as: Listing.self)
                        completion(.success(listing))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
}
