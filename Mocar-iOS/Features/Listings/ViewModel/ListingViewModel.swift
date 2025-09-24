//
//  ListingViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/17/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

//ui 상태 관리
//SwiftUI의 @Published 프로퍼티로 화면에 바인딩될 데이터 상태를 보관
//버튼 클릭, 슬라이더 이동 같은 사용자 액션 처리 담당

//@MainActor:
//이 클래스의 모든 메서드와 프로퍼티 접근이 메인 스레드에서만 실행되도록 보장
//네트워크/DB 작업은 백그라운드에서 실행되지만, UI 바인딩은 메인 스레드로 안전하게 전환
@MainActor
final class ListingDetailViewModel: ObservableObject {
    // 전체 매물 (홈에서 받아오거나, 다른 곳에서 공유 가능)
    @Published var listings: [Listing] = []
    // 상세 분석 데이터 (서비스에서 한 번에 받아옴)
    @Published var detailData: ListingDetailData?
    
    private let service: ListingService
    //let favoritesViewModel: FavoritesViewModel
    
    init(service: ListingService/*, favoritesViewModel: FavoritesViewModel*/){
        self.service = service
        //self.favoritesViewModel = favoritesViewModel
    }
    
    // MARK: - 상태 문구
    var statusText: String {
        guard let data = detailData else { return "" }
        if Double(data.listing.price) < data.safeMin { return "낮음" }
        if Double(data.listing.price) > data.safeMax { return "낮음" }
        return "적정"
    }
    
    // MARK: - 데이터 로딩
    func loadListing(id: String) async {
        //이미 로딩된 경우 다시 불러오지 않음
        if detailData != nil { return }
        do {
            let data = try await service.getListingDetail(id: id, allListings: listings)
            self.detailData = data
        } catch {
            print("Error Message -- fail to load listing: \(error)")
        }
    }

    // MARK: - 안전 구간 계산 X좌표
    func safeStartX(width: CGFloat) -> CGFloat {
        guard let data = detailData, data.maxPrice > data.minPrice else { return 0 }
        let start = clamped(data.safeMin, min: data.minPrice, max: data.maxPrice)
        return CGFloat((start - data.minPrice) / (data.maxPrice - data.minPrice)) * width
    }
    
    // MARK: - 안전 구간 계산 너비
    func safeWidth(width: CGFloat) -> CGFloat {
        guard let data = detailData, data.maxPrice > data.minPrice else { return 0 }
        let start = clamped(data.safeMin, min: data.minPrice, max: data.maxPrice)
        let end   = clamped(data.safeMax, min: data.minPrice, max: data.maxPrice)

        let startRatio = (start - data.minPrice) / (data.maxPrice - data.minPrice)
        let endRatio = (end - data.minPrice) / (data.maxPrice - data.minPrice)

        return width * CGFloat(endRatio - startRatio)
    }

    
    // MARK: - Util
    private func clamped(_ value: Double, min: Double, max: Double) -> Double {
        return Swift.min(Swift.max(value, min), max)
    }
    
    // 현재 값 좌표
    func circleX(width: CGFloat, circleRadius: CGFloat = 8) -> CGFloat {
        guard let data = detailData, data.maxPrice > data.minPrice else { return 0 }
        
        let value = clamped(Double(data.listing.price), min: data.minPrice, max: data.maxPrice)
        let ratio = (value - data.minPrice) / (data.maxPrice - data.minPrice)
        
        var pos = CGFloat(ratio) * width
        pos = min(max(pos, circleRadius), width - circleRadius)
        
        return pos
    }
    
    //MARK: - 유저 정보
    var sellerName: String {
           detailData?.seller?.name ?? "알 수 없음"
    }
       
   var sellerProfileImageUrl: String? {
       detailData?.seller?.photoUrl
   }
    
    //MARK: - 매물 상태 변경
    func changeStatus(to status: ListingStatus) async {
        guard let listingId = detailData?.listing.id else { return }
        
        do {
            try await service.updateListingAndOrders(listingId: listingId, status: status)
            if let current = detailData {
                self.detailData = current.withStatus(status) // UI 즉시 반영
            }
        } catch {
            print("EROOR MESAAGE -- Failed to update status: \(error)")
        }
    }

}
