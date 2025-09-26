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
    
    //전체 매물 데이터
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
    
    //단일 매물 데이터
    func fetchListing(id: String) async throws -> Listing {
            do {
                //특정 document id에 해당하는 매물을 가져옴.
                let doc = try await db.collection("listings").document(id).getDocument()
                print("매물 id: \(doc.documentID)")
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
                .whereField("brand", isEqualTo: brand)
                .whereField("status", in: [
                    ListingStatus.onSale.rawValue,
                    ListingStatus.reserved.rawValue
                ])
                .getDocuments()
            
            return snapshot.documents.compactMap { doc in
                try? doc.data(as: Listing.self)
            }
        } catch {
            print("ERROR MESSAGE -- Firestore error: \(error.localizedDescription)")
            throw error
        }
    }
    
    //차량 상태 불러오기
    func updateListingAndOrders(listingId: String, newStatus: ListingStatus, sellerId: String, buyerId: String) async throws {
        // 1) listings 상태 변경
        try await db.collection("listings")
            .document(listingId)
            .updateData(["status": newStatus.rawValue])

        // 2) orders 상태 변경 (필요한 경우만)
        let snapshot = try await db.collection("orders")
            .whereField("listingId", isEqualTo: listingId)
            .getDocuments()
        
        
        if snapshot.isEmpty {
            // Order 없으면 새로 생성
            let orderId = UUID().uuidString
            let orderData: [String: Any] = [
                "orderId": orderId,
                "listingId": listingId,
                "sellerId": sellerId,
                "buyerId": buyerId,
                "status": newStatus.rawValue,
                "reservedAt": newStatus == .reserved ? ISO8601DateFormatter().string(from: Date()) : NSNull(),
                "soldAt": newStatus == .soldOut ? ISO8601DateFormatter().string(from: Date()) : NSNull()
            ]
            print("db 저장 판매자: \(sellerId), 구매자:\(buyerId)")
            try await db.collection("orders").addDocument(data: orderData)
        } else {
            // 기존 Order 업데이트
            for doc in snapshot.documents {
                var updateData: [String: Any] = [
                    "status": newStatus.rawValue,
                    "sellerId": sellerId,
                    "buyerId": buyerId
                ]
                switch newStatus {
                case .reserved:
                    updateData["reservedAt"] = ISO8601DateFormatter().string(from: Date())
                case .soldOut:
                    updateData["soldAt"] = ISO8601DateFormatter().string(from: Date())
                case .onSale:
                    updateData["reservedAt"] = FieldValue.delete()
                    updateData["soldAt"] = FieldValue.delete()
                case .draft:
                    updateData["status"] = "draft"
                }
                try await db.collection("orders")
                    .document(doc.documentID)
                    .updateData(updateData)
            }
            print("db 저장 판매자: \(sellerId), 구매자:\(buyerId)")
        }
       

//        for doc in snapshot.documents {
//            var updateData: [String: Any] = ["status": newStatus.rawValue]
//
//            switch newStatus {
//            case .reserved:
//                updateData["reservedAt"] = ISO8601DateFormatter().string(from: Date())
//            case .soldOut:
//                updateData["soldAt"] = ISO8601DateFormatter().string(from: Date())
//            case .onSale:
//                // 판매중으로 되돌릴 때는 시간 필드는 null 처리
//                updateData["reservedAt"] = FieldValue.delete()
//                updateData["soldAt"] = FieldValue.delete()
//            case .draft:
//                // 초안 상태일 때는 orders에 반영하지 않거나 필요에 맞게 처리
//                updateData["status"] = "draft"
//            }
//
//            try await db.collection("orders")
//                .document(doc.documentID)
//                .updateData(updateData)
//        }
    }
    
    //가격 범위 불러오기
    func fetchListingWithPrice(id: String) async throws -> (Listing, PriceIndex?) {
        let listing = try await fetchListing(id: id) //기존 함수 재사용
        
        let queryId = "\(listing.brand)_\(listing.model)_\(listing.year)"
        let snapshot = try await db.collection("priceIndex")
            .whereField("id", isEqualTo: queryId)
            .getDocuments()
        
        let priceIndex = try? snapshot.documents.first?.data(as: PriceIndex.self)
        
        //let priceDoc = try await db.collection("priceIndex").document(id).getDocument()
        //let priceIndex = try? priceDoc.data(as: PriceIndex.self)
        
        if let priceIndex = priceIndex {
            print(" PriceIndex 디코딩 성공: \(priceIndex)")
        } else {
            print("PriceIndex 문서 없음 (queryId: \(queryId))")
        }
        
        return (listing, priceIndex)
        
    }
    // 매물 삭제 (sellerId 검증 포함)
        func deleteListing(id: String, currentUserId: String) async throws {
            // 1. 문서 가져오기
            let docRef = db.collection("listings").document(id)
            let document = try await docRef.getDocument()
            
            guard let listing = try? document.data(as: Listing.self) else {
                throw NSError(domain: "ListingRepository",
                              code: 404,
                              userInfo: [NSLocalizedDescriptionKey: "Listing not found"])
            }
            
            // 2. 본인 소유 매물인지 확인
            guard listing.sellerId == currentUserId else {
                throw NSError(domain: "ListingRepository",
                              code: 403,
                              userInfo: [NSLocalizedDescriptionKey: "You are not allowed to delete this listing"])
            }
            
            // 3. listings 컬렉션에서 삭제
            try await docRef.delete()
            print("삭제 완료: \(id)")
            
            // 4. favorites 컬렉션에서 해당 listingId 가진 문서 전부 삭제
            let favoritesSnapshot = try await db.collection("favorites")
                .whereField("listingId", isEqualTo: id)
                .getDocuments()
            
            for favDoc in favoritesSnapshot.documents {
                try await favDoc.reference.delete()
                print(" favorites에서 삭제된 listingId 제거: \(id)")
            }
        }
}
