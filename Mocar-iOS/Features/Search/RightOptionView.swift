//
//  RightOptionView.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct RightOptionView: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        VStack {
            switch viewModel.selectedCategory {
            case .brand:
                BrandView(viewModel: viewModel)
            case .price:
                PriceFilterView(minPrice: $viewModel.minPrice, maxPrice: $viewModel.maxPrice)
            case .year:
                YearFilterView(minYear: $viewModel.minYear, maxYear: $viewModel.maxYear)
            case .mileage:
                MileageFilterView(minMileage: $viewModel.minMileage, maxMileage: $viewModel.maxMileage)
            case .bodyType:
                CarSizeFilterView(carTypes: $viewModel.carTypeOptions)
            case .fuel:
                FuelFilterView(fuels: $viewModel.fuelOptions)
            case .region:
                AreaFilterView(regions: $viewModel.regionOptions)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
