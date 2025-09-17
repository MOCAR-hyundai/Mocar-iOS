//
//  MileageFilterView.swift
//  Mocar-iOS
//
//  Created by wj on 9/17/25.
//

import SwiftUI

struct MileageFilterView: View {
    @Binding var minMileage: Int
    @Binding var maxMileage: Int

    @State private var minText: String = ""
    @State private var maxText: String = ""

    private let mileageRange: ClosedRange<Int> = 0...200000

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("주행거리")
                    .font(.headline)

                // 슬라이더: Int ↔ Double 변환
                RangeSlider(
                    lowerValue: Binding(
                        get: { Double(minMileage) },
                        set: { newValue in
                            let intValue = Int(newValue.rounded())
                            minMileage = min(max(intValue, mileageRange.lowerBound), maxMileage)
                            minText = String(minMileage)
                        }),
                    upperValue: Binding(
                        get: { Double(maxMileage) },
                        set: { newValue in
                            let intValue = Int(newValue.rounded())
                            maxMileage = max(min(intValue, mileageRange.upperBound), minMileage)
                            maxText = String(maxMileage)
                        }),
                    range: Double(mileageRange.lowerBound)...Double(mileageRange.upperBound)
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
                            minMileage = min(max(value, mileageRange.lowerBound), maxMileage)
                        }
                    }
                    .onSubmit {
                        minText = String(minMileage)
                    }

                Text("km")

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
                            maxMileage = max(min(value, mileageRange.upperBound), minMileage)
                        }
                    }
                    .onSubmit {
                        maxText = String(maxMileage)
                    }

                Text("km")
            }
        }
        .padding(.horizontal, 16)
        .onAppear {
            minText = String(minMileage)
            maxText = String(maxMileage)
        }
        .onChange(of: minMileage) { newValue in
            let value = String(newValue)
            if minText != value {
                minText = value
            }
        }
        .onChange(of: maxMileage) { newValue in
            let value = String(newValue)
            if maxText != value {
                maxText = value
            }
        }
        Spacer()
    }
}
