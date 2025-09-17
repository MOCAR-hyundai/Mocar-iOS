//
//  PriceFilterView.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct PriceFilterView: View {
    @Binding var minPrice: Int
    @Binding var maxPrice: Int

    @State private var minText: String = ""
    @State private var maxText: String = ""

    private let priceRange: ClosedRange<Int> = 0...10000

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("가격")
                    .font(.headline)

                // 슬라이더: Int ↔ Double 변환
                RangeSlider(
                    lowerValue: Binding(
                        get: { Double(minPrice) },
                        set: { newValue in
                            let intValue = Int(newValue.rounded())
                            minPrice = min(max(intValue, priceRange.lowerBound), maxPrice)
                            minText = String(minPrice)
                        }),
                    upperValue: Binding(
                        get: { Double(maxPrice) },
                        set: { newValue in
                            let intValue = Int(newValue.rounded())
                            maxPrice = max(min(intValue, priceRange.upperBound), minPrice)
                            maxText = String(maxPrice)
                        }),
                    range: Double(priceRange.lowerBound)...Double(priceRange.upperBound)
                )
                .frame(height: 50)
                .padding(.horizontal, 16)
            }
            .padding(.top, 20)
            // 텍스트 입력
            HStack {
                TextField("최소", text: $minText)
                    .keyboardType(.numberPad)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                    .onChange(of: minText) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            minText = filtered
                        }
                        if let value = Int(filtered) {
                            minPrice = min(max(value, priceRange.lowerBound), maxPrice)
                        }
                    }
                    .onSubmit {
                        minText = String(minPrice)
                    }

                Text("만원")

                Spacer()

                TextField("최대", text: $maxText)
                    .keyboardType(.numberPad)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                    .onChange(of: maxText) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            maxText = filtered
                        }
                        if let value = Int(filtered) {
                            maxPrice = max(min(value, priceRange.upperBound), minPrice)
                        }
                    }
                    .onSubmit {
                        maxText = String(maxPrice)
                    }

                Text("만원")
            }
        }
        .padding(.horizontal, 16)
        .onAppear {
            minText = String(minPrice)
            maxText = String(maxPrice)
        }
        .onChange(of: minPrice) { newValue in
            let value = String(newValue)
            if minText != value {
                minText = value
            }
        }
        .onChange(of: maxPrice) { newValue in
            let value = String(newValue)
            if maxText != value {
                maxText = value
            }
        }
        Spacer()
    }
}
