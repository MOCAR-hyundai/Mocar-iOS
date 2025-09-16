//
//  PriceFilterView.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct PriceFilterView: View {
    @Binding var minPrice: Double
    @Binding var maxPrice: Double
    
    @State private var minText: String = ""
    @State private var maxText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("가격 범위")
                .font(.headline)
            
            // 슬라이더
            RangeSlider(lowerValue: $minPrice,
                        upperValue: $maxPrice,
                        range: 0...10000)
                .frame(height: 50)
                .padding(.horizontal, 16)
        }
        .padding(.top, 20)
        .onAppear {
            // 초기값 동기화
            minText = String(Int(minPrice))
            maxText = String(Int(maxPrice))
        }
        .onChange(of: minPrice) {
            minText = String(Int(minPrice))
        }
        .onChange(of: maxPrice) {
            maxText = String(Int(maxPrice))
        }
        
        // 텍스트 입력
        HStack {
            TextField("최소", text: $minText)
                .keyboardType(.numberPad)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                .onChange(of: minText) {
                    if let value = Double(minText) {
                        minPrice = min(value, maxPrice)
                    }
                }
            
            Text("만원")
            
            Spacer()
            
            TextField("최대", text: $maxText)
                .keyboardType(.numberPad)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                .onChange(of: maxText) {
                    if let value = Double(maxText) {
                        maxPrice = max(value, minPrice)
                    }
                }
            
            Text("만원")
        }
        .padding(.horizontal, 16)
    }
}
