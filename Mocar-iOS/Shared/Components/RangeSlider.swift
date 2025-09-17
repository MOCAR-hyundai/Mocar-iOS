//
//  RangeSlider.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct RangeSlider: View {
    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height: CGFloat = 4
            
            let lowerRatio = (lowerValue - range.lowerBound) / (range.upperBound - range.lowerBound)
            let upperRatio = (upperValue - range.lowerBound) / (range.upperBound - range.lowerBound)
            
            ZStack(alignment: .leading) {
                // 전체 바
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: height)
                
                // 선택된 범위 바
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: width * (upperRatio - lowerRatio), height: height)
                    .offset(x: width * lowerRatio)
                
                // 왼쪽 핸들
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    .frame(width: 28, height: 28)
                    .offset(x: width * lowerRatio - 14)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let ratio = min(max(0, value.location.x / width), 1)
                                let newValue = range.lowerBound + ratio * (range.upperBound - range.lowerBound)
                                lowerValue = min(newValue, upperValue)
                            }
                    )
                
                // 오른쪽 핸들
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    .frame(width: 28, height: 28)
                    .offset(x: width * upperRatio - 14)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let ratio = min(max(0, value.location.x / width), 1)
                                let newValue = range.lowerBound + ratio * (range.upperBound - range.lowerBound)
                                upperValue = max(newValue, lowerValue)
                            }
                    )
            }
        }
        .frame(height: 40)
    }
}
