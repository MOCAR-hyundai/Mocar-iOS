//
//  FavoritesServices.swift
//  Mocar-iOS
//
//  Created by Admin on 9/23/25.
//

import Foundation
import FirebaseAuth

protocol FavoriteService {
    // 특정 유저의 찜 목록 실시간 구독
    func listenFavorites(userId: String) -> AsyncStream<[Favorite]>
    
    // 특정 유저의 찜 목록 단발 조회
    func getFavorites(userId: String) async throws -> [Favorite]
    
    // 매물이 찜 상태인지 확인
    func isFavorite(userId: String, listingId: String) async throws -> Bool
    
    // 찜 토글 (있으면 삭제, 없으면 추가)
    func toggleFavorite(userId: String, listingId: String) async throws
    
    // 찜한 매물의 상세 Listing까지 가져오기
    func getFavoriteListings(userId: String) async throws -> [Listing]
}

final class FavoriteServiceImpl: FavoriteService {
    private let favoriteRepository: FavoriteRepository
    private let listingRepository: ListingRepository
    
    init(favoriteRepository: FavoriteRepository, listingRepository: ListingRepository) {
        self.favoriteRepository = favoriteRepository
        self.listingRepository = listingRepository
    }
    
    func listenFavorites(userId: String) -> AsyncStream<[Favorite]> {
        favoriteRepository.listenFavorites(userId: userId)
    }
    
    func getFavorites(userId: String) async throws -> [Favorite] {
        try await favoriteRepository.fetchFavorites(userId: userId)
    }
    
    func isFavorite(userId: String, listingId: String) async throws -> Bool {
        try await favoriteRepository.isFavorite(userId: userId, listingId: listingId)
    }
    
    func toggleFavorite(userId: String, listingId: String) async throws {
        if try await isFavorite(userId: userId, listingId: listingId) {
            // 이미 찜했으면 삭제
            let favorites = try await getFavorites(userId: userId)
            if let favorite = favorites.first(where: { $0.listingId == listingId }) {
                try await favoriteRepository.removeFavorite(favId: favorite.id ?? "")
            }
        } else {
            // 없으면 추가
            let newFavorite = Favorite(
                id: nil, // Firestore가 자동으로 생성
                userId: userId,
                listingId: listingId,
                createdAt: Date()
            )
            try await favoriteRepository.addFavorite(newFavorite)
        }
    }
    
    func getFavoriteListings(userId: String) async throws -> [Listing] {
        // 1. 찜 목록 가져오기
        let favorites = try await getFavorites(userId: userId)
        let ids = favorites.compactMap { $0.listingId }
        
        // 2. ListingRepository에서 해당 매물들 가져오기
        return try await listingRepository.fetchListings(byIds: ids)
    }
}
