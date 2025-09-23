//
//  ListingService.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import Foundation

//Repository에서 데이터 가져오기 + 비지니스 로직(가공), ui와는 독립적

struct ListingDetailData {
    let listing: Listing        // 단일 매물
    let prices: [Double]        // 같은 모델 매물들의 가격 리스트
    let minPrice: Double        // 최저가
    let maxPrice: Double        // 최고가
    let safeMin: Double         // 시세 안전 구간 최소값
    let safeMax: Double         // 시세 안전 구간 최대값
    let ticks: [Int]            // 가격 구간 눈금
}

//프로토콜 인터페이스 역할
protocol ListingService {
    // 전체 매물 가져오기 (홈, 검색 등)
    func getAllListings() async throws -> [Listing]
    
    // 단일 매물 가져오기 (상세 화면, 찜한 매물 조회)
    func getListing(id: String) async throws -> Listing

    // 매물 상세 분석 데이터 (상세 화면 전용)
    func getListingDetail(id: String, allListings: [Listing]) async throws -> ListingDetailData
}


final class ListingServiceImpl: ListingService {
    private let repository: ListingRepository
    
    init(repository: ListingRepository) {
        self.repository = repository
    }

    func getAllListings() async throws -> [Listing] {
        return try await repository.fetchListings()
    }

    func getListing(id: String) async throws -> Listing {
        return try await repository.fetchListing(id: id)
    }

    func getListingDetail(id: String, allListings: [Listing]) async throws -> ListingDetailData {
        let found = try await repository.fetchListing(id: id)
        
        // 동일 모델 매물들 필터링
        let sameModelListings = allListings.filter { $0.model == found.model }
        let prices = sameModelListings.map { Double($0.price) }
        
        // 최소, 최대 값 계산
        let minPrice = prices.min() ?? 0
        let maxPrice = prices.max() ?? 0
        let ticks = makeTicks(minPrice: minPrice, maxPrice: maxPrice)
        
        // 시세 안전 구간 범위
        let safeMin = ticks.count > 1 ? Double(ticks[1]) : minPrice
        let safeMax = ticks.count > 4 ? Double(ticks[4]) : maxPrice

        return ListingDetailData(
            listing: found,
            prices: prices,
            minPrice: minPrice,
            maxPrice: maxPrice,
            safeMin: safeMin,
            safeMax: safeMax,
            ticks: ticks
        )
    }

    private func makeTicks(minPrice: Double, maxPrice: Double) -> [Int] {
        guard minPrice < maxPrice else { return [Int(minPrice)] }
        let step = (maxPrice - minPrice) / 5.0
        return (0...5).map { i in Int(minPrice + Double(i) * step) }
    }
}

    

