//
//  HomeViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var brandListings: [Listing] = []   // 현재 선택된 브랜드의 매물
    @Published var brands: [CarBrand] = []         // 브랜드 목록
    @Published var selectedBrand: CarBrand? = nil
    @Published var isLoading: Bool = false
    
    private let service: HomeService
    
    init(service: HomeService) {
        self.service = service
    }
    
    // 브랜드 목록 불러오기
    func loadBrands() async {
        isLoading = true
        do {
            let brands = try await service.getCarBrands()
            self.brands = brands
            self.selectedBrand = brands.first
            // 기본 선택 브랜드 매물도 같이 불러오기
            if let firstBrand = brands.first {
                await loadListings(for: firstBrand)
            }
        } catch {
            print("ERROR MESSAGE --  Failed to fetch brands: \(error)")
        }
        isLoading = false
    }
    
    // 특정 브랜드의 매물 불러오기
    func loadListings(for brand: CarBrand) async {
        isLoading = true
        do {
            let listings = try await service.getListings(by: brand.name)
            self.brandListings = listings
            self.selectedBrand = brand
        } catch {
            print("ERROR MESSAGE -- Failed to fetch listings for brand \(brand.name): \(error)")
        }
        isLoading = false
    }
}
