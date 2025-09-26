//
//  CarBrandsRepository.swift
//  Mocar-iOS
//
//  Created by wj on 9/21/25.
//

import Foundation
import FirebaseFirestore

// Firestore 문서 구조
struct CarBrandEntity: Codable {
    let countryType: String?
    let id: String?
    let logoUrl: String?
    let name: String?
    let order: Int?
}

// SwiftUI에서 사용할 모델
struct CarBrand: Identifiable, Hashable {
    let id: String
    let name: String
    let logoUrl: String
    let countryType: String
    let order: Int
}

final class CarBrandRepository {
    private let db = Firestore.firestore()
    private let collectionName = "car_brand"
    
    /// Firestore에서 브랜드 목록을 가져옵니다.
    func fetchCarBrands() async throws -> [CarBrand] {
        let snapshot = try await db.collection(collectionName).getDocuments()
        let documents = snapshot.documents
        print("Firestore에서 가져온 브랜드 문서 수: \(documents.count)개, 컬렉션 \(collectionName)")
        
        var skipped: [(id: String, reason: String)] = []
        var results: [CarBrand] = []
        
        for document in documents {
            do {
                let entity = try document.data(as: CarBrandEntity.self)
                if let brand = mapToCarBrand(entity: entity, id: document.documentID) {
                    results.append(brand)
                } else {
                    skipped.append((id: document.documentID, reason: "필수 필드 누락"))
                }
            } catch {
                skipped.append((id: document.documentID, reason: "디코딩 오류: \(error.localizedDescription)"))
            }
        }
        
        if !skipped.isEmpty {
            print("매핑 실패한 브랜드 문서 수: \(skipped.count)")
            for s in skipped.prefix(10) {
                print("   - id=\(s.id), reason: \(s.reason)")
            }
        }
        
        print("매핑된 브랜드 수: \(results.count)개")
        return results.sorted { $0.order < $1.order }
    }
    
    /// Firestore Entity → CarBrand 모델 매핑
    private func mapToCarBrand(entity: CarBrandEntity, id: String) -> CarBrand? {
        guard let name = entity.name?.trimmingCharacters(in: .whitespacesAndNewlines),
              let logoUrl = entity.logoUrl?.trimmingCharacters(in: .whitespacesAndNewlines),
              let countryType = entity.countryType?.trimmingCharacters(in: .whitespacesAndNewlines),
              let order = entity.order
        else { return nil }
        
        return CarBrand(
            id: id,
            name: name,
            logoUrl: logoUrl,
            countryType: countryType,
            order: order
        )
    }
}
