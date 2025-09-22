//
//  HomeService.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import Foundation

protocol HomeService {
    func getListingsAndBrands() async throws -> ([Listing], [String])
}

final class HomeServiceImpl: HomeService {
    private let repository: ListingRepository
    
    init(repository: ListingRepository) {
        self.repository = repository
    }
    
    func getListingsAndBrands() async throws -> ([Listing], [String]) {
        let listings = try await repository.fetchListings()
        let brands = Array(Set(listings.map { $0.brand })).sorted()
        return (listings, brands)
    }
}
