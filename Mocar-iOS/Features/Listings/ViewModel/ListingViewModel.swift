//
//  ListingViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/17/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

//ui 상태 관리
//SwiftUI의 @Published 프로퍼티로 화면에 바인딩될 데이터 상태를 보관
//버튼 클릭, 슬라이더 이동 같은 사용자 액션 처리 담당

//@MainActor:
//이 클래스의 모든 메서드와 프로퍼티 접근이 메인 스레드에서만 실행되도록 보장
//네트워크/DB 작업은 백그라운드에서 실행되지만, UI 바인딩은 메인 스레드로 안전하게 전환
@MainActor
final class ListingViewModel: ObservableObject {
    // 전체 매물 (홈에서 받아오거나, 다른 곳에서 공유 가능)
    @Published var listings: [Listing] = []
    // 상세 분석 데이터 (서비스에서 한 번에 받아옴)
    @Published var detailData: ListingDetailData?
    
    @Published var photos: [UIImage] = []
    
    private let service: ListingService
    //let favoritesViewModel: FavoritesViewModel
    
    init(service: ListingService/*, favoritesViewModel: FavoritesViewModel*/){
        self.service = service
        //self.favoritesViewModel = favoritesViewModel
    }
    private let db = Firestore.firestore()
    
    // MARK: - 상태 문구
    var statusText: String {
        guard let data = detailData else { return "" }
        if Double(data.listing.price) < data.safeMin { return "낮음" }
        if Double(data.listing.price) > data.safeMax { return "낮음" }
        return "적정"
    }
    
    // MARK: - 데이터 로딩
    func loadListing(id: String, forceReload: Bool = false) async {
        //이미 로딩된 경우 다시 불러오지 않음
        if detailData != nil, !forceReload { return }
            do {
                let data = try await service.getListingDetail(id: id, allListings: listings)
                print(" loadListing result listing:", data.listing.title, data.listing.sellerId)
                print(" loadListing result seller:", data.seller?.name ?? "nil", data.seller?.photoUrl ?? "nil")
                self.detailData = data
            } catch {
                print(" fail to load listing: \(error)")
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
    func changeStatus(to status: ListingStatus, buyerId: String) async {
        guard let listing = detailData?.listing else { return }
        
        do {
            try await service.updateListingAndOrders(
                listingId: listing.safeId,   // safeId로 보장
                status: status,
                sellerId: listing.sellerId,  // 판매자 ID는 listing에서
                buyerId: buyerId             // 구매자 ID는 Chat에서 전달
            )
            if let current = detailData {
                self.detailData = current.withStatus(status) // UI 즉시 반영
            }
        } catch {
            print("EROOR MESAAGE -- Failed to update status: \(error)")
        }
    }
    
    // MARK: - 이미지 업로드 (Storage)
    private func uploadImageToStorage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        let filename = UUID().uuidString + ".jpg"
        let ref = Storage.storage().reference().child("listings/\(filename)")
        
        ref.putData(data, metadata: nil) { _, error in
            if let error = error {
                print("업로드 실패:", error.localizedDescription)
                completion(nil)
                return
            }
            ref.downloadURL { url, _ in
                completion(url?.absoluteString)
            }
        }
    }
        
    // MARK: - 사진 여러 장 업로드 후 Firestore에 저장
    func saveListing(_ listing: Listing) {
        let group = DispatchGroup()
        var uploadedURLs: [String] = []
        
        for photo in photos {
            group.enter()
            uploadImageToStorage(photo) { url in
                if let url = url {
                    uploadedURLs.append(url)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            
            let finalImages = uploadedURLs.isEmpty ? listing.images : uploadedURLs
            // Firestore 문서 저장
            var data: [String: Any] = [
                "sellerId": listing.sellerId,
                "plateNo": listing.plateNo,
                "title": listing.title,
                "brand": listing.brand,
                "model": listing.model,
                "trim": listing.trim,
                "year": listing.year,
                "mileage": listing.mileage,
                "fuel": listing.fuel,
                "transmission": listing.transmission ?? "",
                "price": listing.price,
                "region": listing.region,
                "description": listing.description,
                "images": finalImages,
                "status": listing.status.rawValue,
                "stats": [
                    "viewCount": listing.stats.viewCount,
                    "favoriteCount": listing.stats.favoriteCount
                ],
                "createdAt": listing.createdAt,
                "updatedAt": Date().ISO8601Format(), // 수정 시간 갱신
                "carType": listing.carType
            ]
            
            if let id = listing.id {
                // 이미 있는 listing 수정
                self.db.collection("listings").document(id).updateData(data) { error in
                    if let error = error {
                        print("매물 수정 실패: \(error.localizedDescription)")
                    } else {
                        print("매물 수정 성공: \(id)")
                        // UI에 즉시 반영
                        self.detailData = ListingDetailData(
                            listing: Listing(
                                id: id,
                                sellerId: listing.sellerId,
                                plateNo: listing.plateNo,
                                title: listing.title,
                                brand: listing.brand,
                                model: listing.model,
                                trim: listing.trim,
                                year: listing.year,
                                mileage: listing.mileage,
                                fuel: listing.fuel,
                                transmission: listing.transmission,
                                price: listing.price,
                                region: listing.region,
                                description: listing.description,
                                images: finalImages,
                                status: listing.status,
                                stats: listing.stats,
                                createdAt: listing.createdAt,
                                updatedAt: Date().ISO8601Format(),
                                carType: listing.carType
                            ),
                            seller: self.detailData?.seller,
                            prices: self.detailData?.prices ?? [],    //  추가
                            minPrice: self.detailData?.minPrice ?? 0,
                            maxPrice: self.detailData?.maxPrice ?? 0,
                            safeMin: self.detailData?.safeMin ?? 0,
                            safeMax: self.detailData?.safeMax ?? 0,
                            ticks: self.detailData?.ticks ?? []
                        )
                    }
                }
            } else {
                // 새 등록
                let ref = self.db.collection("listings").addDocument(data: data) { error in
                    if let error = error {
                        print("새 listing 등록 실패: \(error.localizedDescription)")
                    }
                }
                print("새 listing 등록 완료: \(ref.documentID)")
            }
        }
    }
    
    // MARK: - 매물 삭제
    func deleteListing() async {
        guard let listingId = detailData?.listing.id else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print(" 로그인한 유저가 아님")
            return
        }
        
        do {
            try await service.deleteListing(listingId: listingId, currentUserId: currentUserId)
            print(" 매물 삭제 성공: \(listingId)")
            self.detailData = nil  // UI 상태 비우기
        } catch {
            print(" 매물 삭제 실패: \(error.localizedDescription)")
        }
    }
    

}
