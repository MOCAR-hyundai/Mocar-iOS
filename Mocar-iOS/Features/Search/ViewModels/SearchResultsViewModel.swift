//
//  SearchResultsViewModel.swift
//  Mocar-iOS
//
//  Created by wj on 9/22/25.
//

import SwiftUI
import FirebaseFirestore

@MainActor
class SearchResultsViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    
    private let db = Firestore.firestore()
    
    // MARK: - 키워드 검색
    func fetchListings(forKeyword keyword: String) async {
        do {
            let snapshot = try await db.collection("listings")
                .whereField("title", isEqualTo: keyword)
                .getDocuments()
            
            let fetched = snapshot.documents.compactMap { doc -> Listing? in
                try? doc.data(as: Listing.self)
            }
            
            self.listings = fetched
        } catch {
            print("키워드 검색 실패:", error)
        }
    }
    
    // MARK: - 필터 검색
    func fetchListings(forFilter filter: RecentFilter) async {
        do {
            var query: Query = db.collection("listings")
            
            // Firestore: 가격 필터만 적용
            if let minPrice = filter.minPrice {
                query = query.whereField("price", isGreaterThanOrEqualTo: minPrice * 10000)
            }
            if let maxPrice = filter.maxPrice {
                query = query.whereField("price", isLessThanOrEqualTo: maxPrice * 10000)
            }
            
            // Firestore 조회
            let snapshot = try await query.getDocuments()
            var fetched = snapshot.documents.compactMap { try? $0.data(as: Listing.self) }
            
            // ormalize 함수
            func normalize(_ str: String?) -> String {
                (str ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            }
            
            // 앱 단 필터링
            fetched = fetched.filter { listing in
                // 브랜드
                if let brand = filter.brand, !brand.isEmpty,
                   normalize(listing.brand) != normalize(brand) {
                    return false
                }
                
                // 모델
                if let model = filter.model, !model.isEmpty,
                   normalize(listing.model) != normalize(model) {
                    return false
                }
                
                // 서브모델 / 트림
                let subModels = filter.subModels ?? []
                if !subModels.isEmpty,
                   !subModels.contains(where: { normalize($0) == normalize(listing.title) }) {
                    return false
                }
                
                // 차종
                let carTypes = filter.carTypes ?? []
                if !carTypes.isEmpty,
                   !carTypes.contains(where: { normalize($0) == normalize(listing.carType) }) {
                    return false
                }
                
                // 연료
                let fuels = filter.fuels ?? []
                if !fuels.isEmpty,
                   !fuels.contains(where: { normalize($0) == normalize(listing.fuel) }) {
                    return false
                }
                
                // 지역
                let regions = filter.regions ?? []
                if !regions.isEmpty,
                   !regions.contains(where: { normalize($0) == normalize(listing.region) }) {
                    return false
                }
                
                // 연식
                if let minYear = filter.minYear, listing.year < minYear { return false }
                if let maxYear = filter.maxYear, listing.year > maxYear { return false }
                
                // 주행거리
                if let minMileage = filter.minMileage, listing.mileage < minMileage { return false }
                if let maxMileage = filter.maxMileage, listing.mileage > maxMileage { return false }
                
                return true
            }
            
            self.listings = fetched
            
            // 디버깅
            print("===== 필터 결과 =====")
            print("브랜드:", filter.brand ?? "전체")
            print("모델:", filter.model ?? "전체")
            print("서브모델:", filter.subModels ?? [])
            print("차종:", filter.carTypes ?? [])
            print("연료:", filter.fuels ?? [])
            print("지역:", filter.regions ?? [])
            print("연식:", filter.minYear ?? 0, "~", filter.maxYear ?? 0)
            print("주행거리:", filter.minMileage ?? 0, "~", filter.maxMileage ?? 0)
            print("가격:", filter.minPrice ?? 0, "~", filter.maxPrice ?? 0)
            print("총 결과 수:", listings.count)
            print("====================")
            
        } catch {
            print("필터 검색 실패:", error)
        }
    }
}
