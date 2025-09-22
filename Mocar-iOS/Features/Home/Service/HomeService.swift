//
//  HomeService.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import Foundation

protocol HomeService {
    func getListingsAndBrands() async throws -> ([Listing], [CarBrand])
}

final class HomeServiceImpl: HomeService {
    private let repository: ListingRepository
    private let carBrandRepository = CarBrandRepository()
    
    init(repository: ListingRepository) {
        self.repository = repository
    }
    
    func getListingsAndBrands() async throws -> ([Listing], [CarBrand]) {
        let listings = try await repository.fetchListings()
        let brands = try await carBrandRepository.fetchCarBrands()
        return (listings, brands)
    }
}
