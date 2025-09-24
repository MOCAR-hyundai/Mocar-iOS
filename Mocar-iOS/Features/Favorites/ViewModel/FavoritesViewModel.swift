//
//  FavoritesViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/21/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Favorite] = []          // 찜한 원본 데이터
    @Published var favoriteListings: [Listing] = []    // 찜한 매물 상세
    @Published var isLoading: Bool = false
    
    private let service: FavoriteService
    private var favoritesTask: Task<Void, Never>?
    
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    init(service: FavoriteService) {
        self.service = service
        observeFavorites()
    }
    
    // 실시간 구독 시작
    func observeFavorites() {
        guard let userId else { return }
        // 기존 리스너 취소 (중복 방지)
        favoritesTask?.cancel()
        
//        Task {
//            for await favorites in service.listenFavorites(userId: userId) {
//                //중복 호출 방지
//                if self.favorites.map(\.id) != favorites.map(\.id){
//                    self.favorites = favorites
//                    // 동시에 listing 데이터도 가져오기
//                    do {
//                        self.favoriteListings = try await service.getFavoriteListings(userId: userId)
//                    } catch {
//                        print("ERROR MESSAGE -- Failed to fetch favorite listings: \(error)")
//                    }
//                }
//            }
//        }
//        favoritesTask = Task {
//            for await favorites in service.listenFavorites(userId: userId) {
//                // 중복 호출 방지
//                if self.favorites.map(\.id) != favorites.map(\.id) {
//                    self.favorites = favorites
//                    // 동시에 listing 데이터도 가져오기
//                    do {
//                        self.favoriteListings = try await service.getFavoriteListings(userId: userId)
//                    } catch {
//                        print("❌ Failed to fetch favorite listings: \(error)")
//                    }
//                }
//            }
//        }
        
        favoritesTask = Task {
            for await favorites in service.listenFavorites(userId: userId) {
                // ✅ 단순 비교로 갱신 스킵 방지 (count/내용 바뀌면 무조건 반영)
                if favorites.count != self.favorites.count || favorites.map(\.id) != self.favorites.map(\.id) {
                    self.favorites = favorites
                    do {
                        self.favoriteListings = try await service.getFavoriteListings(userId: userId)
                        print("✅ UI 업데이트 - listings count: \(self.favoriteListings.count)")
                    } catch {
                        print("❌ Failed to fetch favorite listings: \(error)")
                    }
                }
            }
        }
    }
    
    //리스너 중단 + 데이터 초기화
    func stopObserving() {
        favoritesTask?.cancel()
        favoritesTask = nil
        clearFavorites()
    }
    
    // 매물이 찜 상태인지 확인
    func isFavorite(_ listing: Listing) -> Bool {
       favorites.contains(where: { $0.listingId == listing.id })
    }
    
    // 찜/찜 해제 토글
    func toggleFavorite(_ listing: Listing) async {
        guard let userId else { return }
        do {
            try await service.toggleFavorite(userId: userId, listingId: listing.id ?? "")
        } catch {
            print("ERROR MESSAGE -- toggleFavorite error: \(error)")
        }
    }
    
    //찜하기 클리어
    func clearFavorites() {
        self.favoriteListings = []
        self.favorites = []
    }
}
