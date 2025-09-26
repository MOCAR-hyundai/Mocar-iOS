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
            
            // 계산된 값
            let safeStartX = viewModel.safeStartX(width: width)
            let safeWidth = viewModel.safeWidth(width: width)
            let circleX = viewModel.circleX(width: width, circleRadius: 8)
            
            VStack(spacing: 2) {
                if let data = viewModel.detailData,
                   data.minPrice > 0, data.maxPrice > 0 {
                    // 정상 시세 데이터 있을 때
                    ZStack(alignment: .leading) {
                        // 상태 라벨 + 원
                        VStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "car.fill")
                                Text(viewModel.statusText)
                            }
                            .font(.system(size: 12))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusBackgroundColor)
                            .cornerRadius(6)
                            
                            Circle()
                                .fill(statusCircleColor)
                                .frame(width: 16, height: 16)
                        }
                        .offset(x: min(max(circleX - 8, 0), width - 50), y: -15)
                        
                        // 전체 회색 막대
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                        
                        // 안전 구간 막대
                        Capsule()
                            .fill(Color.blue)
                            .frame(width: safeWidth, height: 6)
                            .offset(x: safeStartX)
                    }
                    
                    // 눈금 (ticks)
                    if let ticks = viewModel.detailData?.ticks {
                        HStack {
                            ForEach(ticks, id: \.self) { value in
                                Text("\(Int(value / 10000).decimalString)")
                                    .font(.system(size: 12))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        .frame(width: width)
                        // 우측 하단 단위 텍스트
                        HStack {
                            Spacer()
                            Text("단위: 만원")
                                .font(.system(size: 12))
                                .foregroundColor(Color.textGray200)
                                .padding(.top, 5)
                        }
                    }
                } else {
                    // 데이터 없을 때
                    VStack {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                        
                        Text("시세 데이터 없음")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                }
            }
        }
    }
    
    // MARK: - 상태 색상
    private var statusBackgroundColor: Color {
        switch viewModel.statusText {
        case "적정":
            return Color.blue.opacity(0.15)
        case "높음", "낮음":
            return Color.gray.opacity(0.15)
        default:
            return Color.gray.opacity(0.1)
        }
    }
    
    private var statusCircleColor: Color {
        switch viewModel.statusText {
        case "적정":
            return .blue
        case "높음", "낮음":
            return .gray
        default:
            return .gray
        }
    }
}
