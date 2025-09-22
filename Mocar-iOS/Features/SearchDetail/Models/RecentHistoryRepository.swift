//
//  RecentSearchRepository.swift
//  Mocar-iOS
//
//  Created by wj on 9/22/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - RecentFilter 모델
struct RecentFilter: Codable, Identifiable, Equatable, Hashable {
    var id: String = UUID().uuidString
    var userId: String?
    var brand: String?
    var model: String?
    var subModels: [String]?
    var carTypes: [String]?
    var fuels: [String]?
    var regions: [String]?
    var minPrice: Int?
    var maxPrice: Int?
    var minYear: Int?
    var maxYear: Int?
    var minMileage: Int?
    var maxMileage: Int?
    
    // 두 개의 필터가 동일한 조건을 가지면 같은 필터로 간주
    static func == (lhs: RecentFilter, rhs: RecentFilter) -> Bool {
        return lhs.brand == rhs.brand &&
               lhs.model == rhs.model &&
               lhs.subModels == rhs.subModels &&
               lhs.carTypes == rhs.carTypes &&
               lhs.fuels == rhs.fuels &&
               lhs.regions == rhs.regions &&
               lhs.minPrice == rhs.minPrice &&
               lhs.maxPrice == rhs.maxPrice &&
               lhs.minYear == rhs.minYear &&
               lhs.maxYear == rhs.maxYear &&
               lhs.minMileage == rhs.minMileage &&
               lhs.maxMileage == rhs.maxMileage
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(brand)
        hasher.combine(model)
        hasher.combine(subModels)
        hasher.combine(carTypes)
        hasher.combine(fuels)
        hasher.combine(regions)
        hasher.combine(minPrice)
        hasher.combine(maxPrice)
        hasher.combine(minYear)
        hasher.combine(maxYear)
        hasher.combine(minMileage)
        hasher.combine(maxMileage)
    }
}

// MARK: - Repository
final class RecentHistoryRepository {
    private let db = Firestore.firestore()
    
    init() {}
    
    private func currentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    // MARK: - 필터 저장
    func saveFilter(_ filter: RecentFilter) async throws {
        guard let userId = currentUserId() else { throw NSError(domain: "NoUser", code: 0) }
        let docRef = db.collection("recent_filter").document(userId)
        
        // 기존 필터 가져오기
        let snapshot = try await docRef.getDocument()
        var filters: [RecentFilter] = []
        if let data = snapshot.data(),
           let existingFilters = data["filters"] as? [[String: Any]] {
            let decoder = JSONDecoder()
            for dict in existingFilters {
                if let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                   let decoded = try? decoder.decode(RecentFilter.self, from: jsonData) {
                    filters.append(decoded)
                }
            }
        }
        
        // 중복 검사
        if filters.contains(filter) {
            print("⚠️ 동일한 필터가 이미 존재합니다. 저장하지 않음.")
            return
        }
        
        // 새 필터 추가
        filters.insert(filter, at: 0)
        
        // 최대 10개 유지
        if filters.count > 10 { filters = Array(filters.prefix(10)) }
        
        // Firestore에 저장
        let encoder = JSONEncoder()
        let encoded = try filters.map { f -> [String: Any] in
            let data = try encoder.encode(f)
            return try JSONSerialization.jsonObject(with: data) as! [String: Any]
        }
        try await docRef.setData(["filters": encoded], merge: true)
    }

       // 불러오기
    func fetchFilters() async throws -> [RecentFilter] {
        guard let userId = currentUserId() else { return [] }
        let snapshot = try await db.collection("recent_filter").document(userId).getDocument()
        guard let data = snapshot.data(),
              let filtersData = data["filters"] as? [[String: Any]] else { return [] }
        
        let decoder = JSONDecoder()
        var filters: [RecentFilter] = []
        for dict in filtersData {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
                let filter = try decoder.decode(RecentFilter.self, from: jsonData)
                filters.append(filter)
            } catch {
                print("필터 디코딩 실패:", error)
            }
        }
        return filters
    }

       // 특정 필터 삭제
    func removeFilter(_ filterId: String) async throws {
        guard let userId = currentUserId() else { throw NSError(domain: "NoUser", code: 0) }
        let docRef = db.collection("recent_filter").document(userId)
        let snapshot = try await docRef.getDocument()
        
        guard var filters = snapshot.data()?["filters"] as? [[String: Any]] else { return }
        filters.removeAll { $0["id"] as? String == filterId }
        
        try await docRef.setData(["filters": filters], merge: true)
    }

       // 전체 삭제
    func clearFilters() async throws {
        guard let userId = currentUserId() else { throw NSError(domain: "NoUser", code: 0) }
        try await db.collection("recent_filter").document(userId).setData(["filters": []], merge: true)
    }
   
    
    // MARK: - 최근검색 키워드 저장 (문서 없으면 생성)
    func saveKeyword(_ keyword: String) async throws {
        guard let userId = currentUserId() else { throw NSError(domain: "NoUser", code: 0) }
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // setData merge:true로 문서 없으면 생성, 있으면 배열 합침
        try await db.collection("recent_keyword")
            .document(userId)
            .setData([
                "recentKeyword": FieldValue.arrayUnion([trimmed])
            ], merge: true)
    }
    
    // MARK: - 최근검색 키워드 불러오기
    func fetchKeywords() async throws -> [String] {
        guard let userId = currentUserId() else { return [] }
        let snapshot = try await db.collection("recent_keyword").document(userId).getDocument()
        return snapshot.data()?["recentKeyword"] as? [String] ?? []
    }
    
    // MARK: - 특정 키워드 삭제
    func removeKeyword(_ keyword: String) async throws {
        guard let userId = currentUserId() else { throw NSError(domain: "NoUser", code: 0) }
        try await db.collection("recent_keyword")
            .document(userId)
            .updateData([
                "recentKeyword": FieldValue.arrayRemove([keyword])
            ])
    }
    
    // MARK: - 전체 키워드 삭제
    func clearKeywords() async throws {
        guard let userId = currentUserId() else { throw NSError(domain: "NoUser", code: 0) }
        try await db.collection("recent_keyword")
            .document(userId)
            .setData([
                "recentKeyword": []
            ])
    }
}
