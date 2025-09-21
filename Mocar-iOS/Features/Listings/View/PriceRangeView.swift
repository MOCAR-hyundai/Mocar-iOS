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
            
            let safeStartX = viewModel.safeStartX(width:width)
            
            let safeWidth = viewModel.circleX(width: width)
            
            let circleX = viewModel.circleX(width: width, circleRadius: 8)
            VStack(spacing: 2){
                ZStack(alignment: .leading) {
                    // 라벨 + 원
                    VStack(spacing: 8) {
                        if viewModel.statusText == "적정" {
                            HStack(spacing: 4) {
                                Image(systemName: "car.fill")
                                Text(viewModel.statusText)
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
                        else{
                            HStack(spacing: 4) {
                                Image(systemName: "car.fill")
                                Text("낮음")
                            }
                            .font(.system(size: 12))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(6)
                            
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 16, height: 16)
                        }
                    }
                    .offset(x: min(max(circleX - 8, 0), width - 50), y: -15)// 반지름만큼 보정
                    // 전체 회색 막대
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    //  안전 구간 (2번째 ~ 5번째 값)
                    Capsule()
                        .fill(Color.blue)
                        .frame(width: safeWidth, height: 6)
                        .offset(x: safeStartX)
                }
                // 눈금
                HStack {
                    ForEach(viewModel.ticks, id: \.self) { value in
                        Text("\(value)")
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .frame(width: width)
            }
            
        }
        //.frame(height: 50)
        
    }
}

#Preview {

}
