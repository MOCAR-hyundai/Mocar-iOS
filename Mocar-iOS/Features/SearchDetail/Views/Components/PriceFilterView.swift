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
        
        private let priceRange: ClosedRange<Int> = 0...100000
        
        var body: some View {
            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    Text("가격")
                        .font(.footnote)
                        .fontWeight(.semibold)
                    
                    // 슬라이더
                    RangeSlider(
                        lowerValue: Binding(
                            get: { Double(minPrice) },
                            set: { newValue in
                                let intValue = Int(newValue.rounded())
                                minPrice = min(max(intValue, priceRange.lowerBound), maxPrice)
                                minText = minPrice == priceRange.lowerBound ? "" : "\(minPrice)"
                            }),
                        upperValue: Binding(
                            get: { Double(maxPrice) },
                            set: { newValue in
                                let intValue = Int(newValue.rounded())
                                maxPrice = max(min(intValue, priceRange.upperBound), minPrice)
                                maxText = maxPrice == priceRange.upperBound ? "" : "\(maxPrice)"
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
                        .onChange(of: minText) { newValue, _ in
                            minText = newValue.filter { "0123456789".contains($0) }
                            minPrice = Int(minText) ?? priceRange.lowerBound
                        }
                    
                    
                    Text("만원")
                    
                    Spacer()
                    Text("~")
                    Spacer()
                    
                    TextField("최대", text: $maxText)
                        .keyboardType(.numberPad)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                        .onChange(of: maxText) { newValue, _ in
                            maxText = newValue.filter { "0123456789".contains($0) }
                            maxPrice = Int(maxText) ?? priceRange.upperBound
                            
                        }
                    Text("만원")
                }
            }
            .padding(.horizontal, 16)
            .onAppear {
                minText = minPrice == priceRange.lowerBound ? "" : "\(minPrice)"
                maxText = maxPrice == priceRange.upperBound ? "" : "\(maxPrice)"
            }
            Spacer()
        }
    }
