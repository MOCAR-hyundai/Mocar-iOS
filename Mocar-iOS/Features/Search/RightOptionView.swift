//
//  RightOptionView.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct RightOptionView: View {
    @Binding var selectedCategory: String?
    @Binding var minPrice: Int
    @Binding var maxPrice: Int
    @Binding var minYear: Int
    @Binding var maxYear: Int
    @Binding var minMileage: Int
    @Binding var maxMileage: Int
    
    var body: some View {
        ScrollView {
            VStack {
                if selectedCategory == "제조사" {
                    BrandView()
                } else if selectedCategory == "가격" {
                    PriceFilterView(minPrice: $minPrice, maxPrice: $maxPrice)
                } else if selectedCategory == "연식" {
                    YearFilterView(minYear: $minYear, maxYear: $maxYear)
                } else if selectedCategory == "주행거리" {
                    MileageFilterView(minMileage: $minMileage, maxMileage: $maxMileage)
                } else if selectedCategory == "연료" {
                    FuelFilterView()
                }
                // 나머지 카테고리는 추후 구현
            }
            .frame(maxWidth: .infinity)
        }
    }
}
