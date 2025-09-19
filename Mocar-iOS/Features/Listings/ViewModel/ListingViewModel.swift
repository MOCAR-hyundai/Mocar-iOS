//
//  ListingViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/17/25.
//

import Foundation

class ListingDetailViewModel: ObservableObject {
    @Published var listing: Listing = Listing.placeholder
    @Published var currentValue: Double
    
    @Published var prices: [Double] = []
    @Published var minPrice: Double = 0
    @Published var maxPrice: Double = 0
    @Published var safeMin: Double = 0
    @Published var safeMax: Double = 0
    @Published var ticks: [Int] = []
    
    var minValue: Double = 4010
    var maxValue: Double = 5525
    //var safeMin: Double = 4254
    //var safeMax: Double = 5180
    
    @Published var favorites: [Listing] = []
    
    // 초기화
    init() {
            let placeholder = Listing.placeholder
            self.listing = placeholder
            self.currentValue = Double(placeholder.price)
    }
    
    // 상태 문구
    var statusText: String {
        let value = clamped(currentValue)
        if currentValue < safeMin { return "낮음" }
        if currentValue > safeMax { return "높음" }
        return "적정"
    }
    
    // 특정 ID의 매물을 불러오면서 동일 모델의 가격 리스트도 가져오기
    func loadListing(id: String) {
        // 1. 전체 데이터에서 해당 매물 찾기
        if let found = Listing.listingData.first(where: { $0.id == id }) {
            self.listing = found
            self.currentValue = Double(found.price)
            
            // 2. 동일 모델의 매물들 필터링
            let sameModelListings = Listing.listingData.filter { $0.model == found.model }
            
            // 3. 가격 리스트만 추출
            self.prices = sameModelListings.map { Double($0.price) }
            
            // 4. 최소, 최대 값 계산
            self.minPrice = prices.min() ?? 0
            self.maxPrice = prices.max() ?? 0
            self.ticks = makeTicks(minPrice: minPrice, maxPrice: maxPrice)
            
            if ticks.count == 6 {
                self.safeMin = Double(ticks[1])
                self.safeMax = Double(ticks[4])
            }
        }
    }
    
    private func makeTicks(minPrice: Double, maxPrice: Double) -> [Int] {
            guard minPrice < maxPrice else { return [Int(minPrice)] }
            let step = (maxPrice - minPrice) / 5.0
            return (0...5).map {i in
                Int(minPrice + Double(i) * step) }
    }
    
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
    
    
    func toggleFavorite(_ listing: Listing){
        if favorites.contains(where: {$0.id == listing.id}){
            favorites.removeAll{$0.id == listing.id}
        }else{
            favorites.append(listing)
        }
    }
}
