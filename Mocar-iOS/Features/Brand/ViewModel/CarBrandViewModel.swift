//
//  CarBrandViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import Foundation

@MainActor
final class CarBrandViewModel: ObservableObject {
    @Published var brands: [CarBrand] = []
    private let repository = CarBrandRepository()
    
    func loadBrands() async {
        do {
            let fetched = try await repository.fetchCarBrands()
            self.brands = fetched
        } catch {
            print("브랜드 불러오기 실패: \(error)")
        }
    }
}
