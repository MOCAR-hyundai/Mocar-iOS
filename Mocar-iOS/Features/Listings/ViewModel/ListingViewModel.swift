//
//  ListingViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/17/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class ListingDetailViewModel: ObservableObject {
    @Published var listings: [Listing] = []     //전체 매물
    @Published var listing: Listing?            //단일 매물(상세화면용)
    
    //그래프 계산
    @Published var currentValue: Double = 0
    @Published var prices: [Double] = []
    @Published var minPrice: Double = 0
    @Published var maxPrice: Double = 0
    @Published var safeMin: Double = 0
    @Published var safeMax: Double = 0
    @Published var ticks: [Int] = []
    
    private let service: ListingService
    let favoritesViewModel: FavoritesViewModel
    
    init(service: ListingService, favoritesViewModel: FavoritesViewModel){
        self.service = service
        self.favoritesViewModel = favoritesViewModel
    }
    
    // 상태 문구
    var statusText: String {
        if currentValue < safeMin { return "낮음" }
        if currentValue > safeMax { return "높음" }
        return "적정"
    }
    
    func loadListing(id: String) async {
        do {
            let (listing, prices, minPrice, maxPrice, safeMin, safeMax, ticks) =
                            try await service.getListingDetail(id: id, allListings: listings)
            
            self.listing = listing
            self.currentValue = Double(listing.price)
            self.prices = prices
            self.minPrice = minPrice
            self.maxPrice = maxPrice
            self.safeMin = safeMin
            self.safeMax = safeMax
            self.ticks = ticks

        } catch {
            print("fail to load listing: \(error)")
        }
            
        
    }
    
    //선택된 매물, 그래프 데이터
//    private func applyListing(_ found: Listing){
//        self.listing = found
//        self.currentValue = Double(found.price)
//        
//        //동일 모델의 매물들 필터링
//        let sameModelListings = listings.filter {$0.model == found.model}
//        //가격 리스트만 추출
//        self.prices = sameModelListings.map { Double($0.price)}
//        
//        // 최소, 최대 값 계산
//        self.minPrice = prices.min() ?? 0
//        self.maxPrice = prices.max() ?? 0
//        self.ticks = makeTicks(minPrice: minPrice, maxPrice: maxPrice)
//        
//        //시세 안전 구간 범위
//        if ticks.count == 6 {
//            self.safeMin = Double(ticks[1])
//            self.safeMax = Double(ticks[4])
//        }
//    }
    
    
//    private func makeTicks(minPrice: Double, maxPrice: Double) -> [Int] {
//            guard minPrice < maxPrice else { return [Int(minPrice)] }
//            let step = (maxPrice - minPrice) / 5.0
//            return (0...5).map {i in
//                Int(minPrice + Double(i) * step) }
//    }
    
    // 안전 구간 시작 X 좌표
    func safeStartX(width: CGFloat) -> CGFloat {
        guard maxPrice > minPrice else { return 0 }
        let start = clamped(safeMin)
        return CGFloat((start - minPrice) / (maxPrice - minPrice)) * width
    }
    
    // 안전 구간 너비
    func safeWidth(width: CGFloat) -> CGFloat {
//        maxPrice - minPrice > 0 ? CGFloat((safeMax - safeMin) / (maxPrice - minPrice)) * width : 0
        guard maxPrice > minPrice else { return 0 }
        let start = clamped(safeMin)
        let end   = clamped(safeMax)
        return CGFloat((end - start) / (maxPrice - minPrice)) * width

    }
    
    private func clamped(_ value: Double) -> Double {
        return min(max(value, minPrice), maxPrice)
    }
    
    // 현재 값 좌표
    func circleX(width: CGFloat, circleRadius: CGFloat = 8) -> CGFloat {
        guard maxPrice > minPrice else { return 0 }
        
        let value = clamped(currentValue)
        
        let ratio = (value - minPrice) / (maxPrice - minPrice)
        var pos = CGFloat(ratio) * width
        
        pos = min(max(pos, circleRadius), width - circleRadius)
        
        return pos
    }
}
