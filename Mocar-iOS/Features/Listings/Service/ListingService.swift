//
//  ListingService.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import Foundation


protocol ListingService {
    func getListingDetail(id: String, allListings: [Listing]) async throws -> (Listing, [Double], Double, Double, Double, Double, [Int])
}
    
final class ListingServiceImpl: ListingService {
    private let repository: ListingRepository
    
    init(repository: ListingRepository) {
        self.repository = repository
    }
    

    func getListingDetail(id: String, allListings: [Listing]) async throws -> (Listing, [Double], Double, Double, Double, Double, [Int]) {
        let found = try await repository.fetchListing(id: id)
        
        //동일 모델의 매물들 필터링
        let sameModelListings = allListings.filter { $0.model == found.model }
        //가격 리스트만 추출
        let prices = sameModelListings.map { Double($0.price) }
        
        
        // 최소, 최대 값 계산
        let minPrice = prices.min() ?? 0
        let maxPrice = prices.max() ?? 0
        let ticks = makeTicks(minPrice: minPrice, maxPrice: maxPrice)
        
        //시세 안전 구간 범위
        let safeMin = ticks.count > 1 ? Double(ticks[1]) : minPrice
        let safeMax = ticks.count > 4 ? Double(ticks[4]) : maxPrice

        return (found, prices, minPrice, maxPrice, safeMin, safeMax, ticks)
    }

    private func makeTicks(minPrice: Double, maxPrice: Double) -> [Int] {
            guard minPrice < maxPrice else { return [Int(minPrice)] }
            let step = (maxPrice - minPrice) / 5.0
            return (0...5).map {i in
                Int(minPrice + Double(i) * step) }
    }
}

    

