//
//  PriceRangeView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct PriceRangeView: View {
    @ObservedObject var viewModel: ListingDetailViewModel
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let safeStartX = viewModel.safeStartX(width: width)
            let safeWidth = viewModel.safeWidth(width: width)
            let circleX = viewModel.circleX(width: width)
            
            let _ = print("""
                        [DEBUG] width: \(width)
                        safeStartX: \(safeStartX)
                        safeWidth: \(safeWidth)
                        circleX: \(circleX)
                        currentValue: \(viewModel.currentValue)
                        min: \(viewModel.minValue), max: \(viewModel.maxValue)
                        """)
            
            VStack(spacing: 8) {
                // 라벨 + 원
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "car.fill")
                        Text("적정")
                    }
                    .font(.system(size: 12))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(6)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 16, height: 16)
                }
                .offset(x: circleX - 8, y: -5) // 반지름만큼 보정
                
                // 막대기
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: width, height: 6)
                    
                    Capsule()
                        .fill(Color.blue)
                        .frame(width: safeWidth, height: 6)
                        .offset(x: safeStartX)
                }
                
                // 눈금
                HStack {
                    ForEach([4010, 4293, 4576, 4859, 5142, 5425], id: \.self) { value in
                        Text("\(value)")
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .frame(width: width)
            }
        }
        .frame(height: 100)
        
    }
}

#Preview {
    let previewVM = ListingDetailViewModel()
    previewVM.listing = Listing.listingData.first ?? .placeholder
    previewVM.currentValue = 4680 // 미리보기용 값
    return PriceRangeView(viewModel: previewVM)
        .frame(height: 120) // 최소 높이 지정
        .padding()
}
