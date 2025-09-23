//
//  HomeService.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import Foundation

//protocol HomeService {
//    func getListingsAndBrands() async throws -> ([Listing], [CarBrand])
//}
//
//final class HomeServiceImpl: HomeService {
//    private let repository: ListingRepository
//    private let carBrandRepository = CarBrandRepository()
//    
//    init(repository: ListingRepository) {
//        self.repository = repository
//    }
//    
//    func getListingsAndBrands() async throws -> ([Listing], [CarBrand]) {
//        let listings = try await repository.fetchListings()
//        let brands = try await carBrandRepository.fetchCarBrands()
//        return (listings, brands)
//    }
//}


protocol HomeService {
    // 브랜드 목록 가져오기
    func getCarBrands() async throws -> [CarBrand]
    
    // 특정 브랜드의 매물만 가져오기
    func getListings(by brand: String) async throws -> [Listing]
}

final class HomeServiceImpl: HomeService {
    private let listingRepository: ListingRepository
    private let carBrandRepository: CarBrandRepository
    
    init(listingRepository: ListingRepository,
         carBrandRepository: CarBrandRepository = CarBrandRepository()) {
        self.listingRepository = listingRepository
        self.carBrandRepository = carBrandRepository
    }
    
    func getCarBrands() async throws -> [CarBrand] {
        return try await carBrandRepository.fetchCarBrands()
    }
    
    func getListings(by brand: String) async throws -> [Listing] {
        return try await listingRepository.fetchListingsByBrand(brand: brand)
    }
}
