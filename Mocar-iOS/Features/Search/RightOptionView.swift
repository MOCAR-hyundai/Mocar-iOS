//
//  RightOptionView.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct RightOptionView: View {
    @Binding var selectedCategory: String?
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        VStack {
            if selectedCategory == "제조사" {
                BrandView(viewModel: viewModel)
            } else if selectedCategory == "가격" {
                PriceFilterView(minPrice: $viewModel.minPrice, maxPrice: $viewModel.maxPrice)
            } else if selectedCategory == "연식" {
                YearFilterView(minYear: $viewModel.minYear, maxYear: $viewModel.maxYear)
            } else if selectedCategory == "주행거리" {
                MileageFilterView(minMileage: $viewModel.minMileage, maxMileage: $viewModel.maxMileage)
            } else if selectedCategory == "차종" {
                CarSizeFilterView(options: $viewModel.carTypeOptions, countProvider: viewModel.countForCarType) { updated in
                    if updated.checked {
                        viewModel.addRecentSearch("차종: \(updated.name)")
                    }
                }
            } else if selectedCategory == "연료" {
                FuelFilterView(options: $viewModel.fuelOptions, countProvider: viewModel.countForFuel)
            } else if selectedCategory == "지역" {
                AreaFilterView(options: $viewModel.areaOptions, countProvider: viewModel.countForArea)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
