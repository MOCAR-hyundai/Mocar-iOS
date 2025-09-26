//
//  YearFilterView.swift
//  Mocar-iOS
//
//  Created by wj on 9/17/25.
//

import SwiftUI

struct YearFilterView: View {
    @Binding var minYear: Int
    @Binding var maxYear: Int
    
    @State private var minText: String = ""
    @State private var maxText: String = ""
    
    private let yearRange: ClosedRange<Int> = 1990...Calendar.current.component(.year, from: Date())
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("연식")
                    .font(.footnote)
                    .fontWeight(.semibold)
                
                // 슬라이더: Int ↔ Double 변환
                RangeSlider(
                    lowerValue: Binding(
                        get: { Double(minYear) },
                        set: { newValue in
                            let intValue = Int(newValue.rounded())
                            minYear = min(max(intValue, yearRange.lowerBound), maxYear)
                            minText = minYear == yearRange.lowerBound ? "" : "\(minYear)"
                        }),
                    upperValue: Binding(
                        get: { Double(maxYear) },
                        set: { newValue in
                            let intValue = Int(newValue.rounded())
                            maxYear = max(min(intValue, yearRange.upperBound), minYear)
                            maxText = maxYear == yearRange.upperBound ? "" : "\(maxYear)"
                        }),
                    range: Double(yearRange.lowerBound)...Double(yearRange.upperBound)
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
                    .onChange(of: minText) { newValue, _ in
                        minText = newValue.filter { "0123456789".contains($0) }
                        minYear = Int(minText) ?? yearRange.lowerBound
                    }
                
                Text("년")
                
                Spacer()
                Text("~")
                Spacer()
                
                TextField("최대", text: $maxText)
                    .keyboardType(.numberPad)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                    .onChange(of: maxText) { newValue, _ in
                        maxText = newValue.filter { "0123456789".contains($0) }
                        maxYear = Int(maxText) ?? yearRange.upperBound
                    }
                
                Text("년")
            }
        }
        .padding(.horizontal, 16)
        .onAppear {
            minText = minYear == yearRange.lowerBound ? "" : "\(minYear)"
            maxText = maxYear == yearRange.upperBound ? "" : "\(maxYear)"
        }
        Spacer()
    }
}
