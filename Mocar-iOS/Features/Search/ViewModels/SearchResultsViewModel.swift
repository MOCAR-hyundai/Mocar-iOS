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
            
            if let brand = filter.brand {
                query = query.whereField("brand", isEqualTo: brand)
            }
            if let model = filter.model {
                query = query.whereField("model", isEqualTo: model)
            }
            if let minPrice = filter.minPrice {
                query = query.whereField("price", isGreaterThanOrEqualTo: minPrice)
            }
            if let maxPrice = filter.maxPrice {
                query = query.whereField("price", isLessThanOrEqualTo: maxPrice)
            }
            if let minYear = filter.minYear {
                query = query.whereField("year", isGreaterThanOrEqualTo: minYear)
            }
            if let maxYear = filter.maxYear {
                query = query.whereField("year", isLessThanOrEqualTo: maxYear)
            }
            if let minMileage = filter.minMileage {
                query = query.whereField("mileage", isGreaterThanOrEqualTo: minMileage)
            }
            if let maxMileage = filter.maxMileage {
                query = query.whereField("mileage", isLessThanOrEqualTo: maxMileage)
            }
            // 차종, 연료, 지역 등 추가 가능

            let snapshot = try await query.getDocuments()
            let fetched = snapshot.documents.compactMap { doc -> Listing? in
                try? doc.data(as: Listing.self)
            }
            
            self.listings = fetched
        } catch {
            print("필터 검색 실패:", error)
        }
    }
}
