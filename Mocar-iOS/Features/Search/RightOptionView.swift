//
//  RightOptionView.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct RightOptionView: View {
    @Binding var selectedCategory: String?
    @Binding var minPrice: Double
    @Binding var maxPrice: Double
    let makers: [SearchView.Maker]
    
    var body: some View {
        ScrollView {
            VStack {
                if selectedCategory == "제조사" {
                    ForEach(makers) { maker in
                        OptionsRow(maker: maker)
                    }
                    .padding(.horizontal)
                } else if selectedCategory == "가격" {
                    PriceFilterView(minPrice: $minPrice, maxPrice: $maxPrice)
                } else {
                    Spacer()
                    Text("\(selectedCategory ?? "") 선택 화면")
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
