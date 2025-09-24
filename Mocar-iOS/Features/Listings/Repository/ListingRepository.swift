//
//  ListingService.swift
//  Mocar-iOS
//
//  Created by Admin on 9/19/25.
//

import SwiftUI

import FirebaseFirestore

//Firebase에서 데이터 가져옴
class ListingRepository {
    private let db = Firestore.firestore()
    
    
    func fetchListings() async throws -> [Listing] {
        do {
            //Firestore에서 listings 컬렉션의 모든 문서를 가져옴
            let snapshot = try await db.collection("listings").getDocuments()
            return snapshot.documents.compactMap { doc in
                do {
                    return try doc.data(as: Listing.self) //Firestore 문서를 Swift의 Listing 모델로 디코딩
                } catch {
                    print("ERROR MESSAGE -- Decoding error in \(doc.documentID): \(error)")
                    return nil  //디코딩 실패시 nil로 스킵
                }
            }
        } catch {
            print("ERROR MESSAGE -- Firestore error: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    func fetchListing(id: String) async throws -> Listing {
            do {
                //특정 document id에 해당하는 매물을 가져옴.
                let doc = try await db.collection("listings").document(id).getDocument()
                guard let listing = try? doc.data(as: Listing.self) else { //디코딩 실패 → 404 Not Found 에러 throw
                    throw NSError(domain: "ListingRepository",
                                  code: 404,
                                  userInfo: [NSLocalizedDescriptionKey: "Listing not found"])
                }
                return listing //성공하면 listing 객체 반환
            } catch {
                print("ERROR MESSAGE -- Firestore error: \(error.localizedDescription)")
                throw error
            }
        }
    
    //in 쿼리(whereField(FieldPath.documentID(), in: ids))를 사용
    //favorites DB에 저장된 listingId들을 기반으로, listings 컬렉션에서 실제 매물 데이터를 가져오는 함수
    func fetchListings(byIds ids: [String]) async throws -> [Listing] {
        guard !ids.isEmpty else { return [] }
        
        let snapshot = try await db.collection("listings")
            .whereField(FieldPath.documentID(), in: ids)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Listing.self) }
    }
    
    //브랜드별 매물 불러오기
    func fetchListingsByBrand(brand: String) async throws -> [Listing] {
        do {
            let snapshot = try await db.collection("listings")
                .whereField("brand", isEqualTo: brand)   // Firestore 필드: brand
                .getDocuments()
            return snapshot.documents.compactMap { doc in
                try? doc.data(as: Listing.self)
            }
        } catch {
            print("ERROR MESSAGE -- Firestore error: \(error.localizedDescription)")
            throw error
        }
    }


}
