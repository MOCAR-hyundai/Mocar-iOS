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
    
    var minValue: Double = 4010
    var maxValue: Double = 5525
    var safeMin: Double = 4254
    var safeMax: Double = 5180
    
    @Published var favorites: [Listing] = []
    
    // 초기화
    init() {
        let placeholder = Listing.placeholder
        self.listing = placeholder
        self.currentValue = Double(placeholder.price)
    }
    
    func loadListing(id: String) {
        if let found = Listing.listingData.first(where: { $0.id == id }) {
            self.listing = found
            self.currentValue = Double(found.price) // 가격을 기준으로 초기화
            print(currentValue)
        }
    }
    // 안전 구간 시작 X 좌표
    func safeStartX(width: CGFloat) -> CGFloat {
        (safeMin - minValue) / (maxValue - minValue) * width
    }
    
    // 안전 구간 너비
    func safeWidth(width: CGFloat) -> CGFloat {
        (safeMax - safeMin) / (maxValue - minValue) * width
    }
    
    // 현재 값 좌표
    func circleX(width: CGFloat) -> CGFloat {
        guard maxValue > minValue else { return 0 } // 0으로 나누기 방지
        
        let ratio = (currentValue - minValue) / (maxValue - minValue)
        let clampedRatio = min(max(ratio, 0), 1) // 0 ~ 1 사이로 보정
        return clampedRatio * width
    }
    
    
    func toggleFavorite(_ listing: Listing){
        if favorites.contains(where: {$0.id == listing.id}){
            favorites.removeAll{$0.id == listing.id}
        }else{
            favorites.append(listing)
        }
    }
}
