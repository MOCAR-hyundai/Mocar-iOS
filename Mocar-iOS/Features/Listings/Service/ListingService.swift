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
    let seller: User?           // 판매자 정보 추가
    let prices: [Double]        // 같은 모델 매물들의 가격 리스트
    let minPrice: Double        // 최저가
    let maxPrice: Double        // 최고가
    let safeMin: Double         // 시세 안전 구간 최소값
    let safeMax: Double         // 시세 안전 구간 최대값
    let ticks: [Double]          // 가격 구간 눈금
}

extension ListingDetailData {
    func withStatus(_ status: ListingStatus) -> ListingDetailData {
        ListingDetailData(
            listing: listing.with(status: status),
            seller: seller,
            prices: prices,
            minPrice: minPrice,
            maxPrice: maxPrice,
            safeMin: safeMin,
            safeMax: safeMax,
            ticks: ticks
        )
    }
}

//프로토콜 인터페이스 역할
protocol ListingService {
    // 전체 매물 가져오기 (홈, 검색 등)
    func getAllListings() async throws -> [Listing]
    
    // 단일 매물 가져오기 (상세 화면, 찜한 매물 조회)
    func getListing(id: String) async throws -> Listing

    // 매물 상세 분석 데이터 (상세 화면 전용)
    func getListingDetail(id: String, allListings: [Listing]) async throws -> ListingDetailData
    
    //차량 상태 업데이트
    func updateListingAndOrders(listingId: String, status: ListingStatus) async throws
    
    // 매물 삭제
    func deleteListing(listingId: String, currentUserId: String) async throws
}


final class ListingServiceImpl: ListingService {
    private let repository: ListingRepository
    private let userStore: UserStore
    
    init(repository: ListingRepository, userStore: UserStore) {
        self.repository = repository
        self.userStore = userStore
    }

    func getAllListings() async throws -> [Listing] {
        return try await repository.fetchListings()
    }

    func getListing(id: String) async throws -> Listing {
        return try await repository.fetchListing(id: id)
    }

    func getListingDetail(id: String, allListings: [Listing]) async throws -> ListingDetailData {
        //Listing + PriceIndex 가져오기
        let (found, priceIndex) = try await repository.fetchListingWithPrice(id: id)
        
        //유저 정보 가져오기
        var seller: User? = nil
        if let cachedUser = userStore.getUser(userId: found.sellerId) {
            seller = cachedUser
        } else {
            //seller = userStore.getUser(userId: found.sellerId)
            do {
                seller = try await userStore.fetchUser(userId: found.sellerId)
                print(" seller fetched:", seller?.name ?? "nil", seller?.photoUrl ?? "nil")
            } catch {
                print(" Failed to fetch seller:", error.localizedDescription)
            }
        }
        
        //값을 담을 변수
        let prices: [Double]
        let minPrice: Double
        let maxPrice: Double
        let safeMin: Double
        let safeMax: Double
        let ticks: [Double]

        if let index = priceIndex {
            // PriceIndex 테이블 값 활용
            prices = [Double(index.avgPrice), Double(index.minPrice), Double(index.maxPrice)]
            minPrice = Double(index.minPrice)
            maxPrice = Double(index.maxPrice)
            
            ticks = makeTicks(minPrice: minPrice, maxPrice: maxPrice)
            safeMin = ticks.count > 1 ? ticks[1] : minPrice
            safeMax = ticks.count > 4 ? ticks[4] : maxPrice
        } else {
            // fallback: 동일 모델 기반
            let sameModelListings = allListings.filter { $0.model == found.model }
            prices = sameModelListings.map { Double($0.price) }
            minPrice = prices.min() ?? 0
            maxPrice = prices.max() ?? 0
            
            ticks = makeTicks(minPrice: minPrice, maxPrice: maxPrice)
            safeMin = ticks.count > 1 ? ticks[1] : minPrice
            safeMax = ticks.count > 4 ? ticks[4] : maxPrice
        }
        
//        // 동일 모델 매물들 필터링
//        let sameModelListings = allListings.filter { $0.model == found.model }
//        let prices = sameModelListings.map { Double($0.price) }
//        
//        // 최소, 최대 값 계산
//        let minPrice = prices.min() ?? 0
//        let maxPrice = prices.max() ?? 0
//        let ticks = makeTicks(minPrice: minPrice, maxPrice: maxPrice)
//        
//        // 시세 안전 구간 범위
//        let safeMin = ticks.count > 1 ? Double(ticks[1]) : minPrice
//        let safeMax = ticks.count > 4 ? Double(ticks[4]) : maxPrice\
        
        return ListingDetailData(
            listing: found,
            seller: seller,
            prices: prices,
            minPrice: minPrice,
            maxPrice: maxPrice,
            safeMin: safeMin,
            safeMax: safeMax,
            ticks: ticks
        )

    }

    private func makeTicks(minPrice: Double, maxPrice: Double) -> [Double] {
        guard minPrice < maxPrice else { return [minPrice] }
        let step = (maxPrice - minPrice) / 5.0
        return (0...5).map { i in minPrice + Double(i) * step }
    }
    
    func updateListingAndOrders(listingId: String, status: ListingStatus) async throws {
        try await repository.updateListingAndOrders(listingId: listingId, newStatus: status)
    }
    
    func deleteListing(listingId: String, currentUserId: String) async throws {
        try await repository.deleteListing(id: listingId, currentUserId: currentUserId)
    }
}

    

