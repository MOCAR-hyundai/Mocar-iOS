//
//  MyListingsCardView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import SwiftUI

struct MyListingsCardView: View {
    
    let listing: Listing
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading, spacing: 4) {
                
                ZStack(alignment: .topTrailing) {
                    // 이미지 배경 통일
                    Color.cardBgGray // 배경색
                    GeometryReader { geo in
                        let width = geo.size.width
                        let height = width * 5 / 7   // 5:7 (0.71) → 전통 사진 비율
                        
                        if let url = URL(string: listing.images[0]) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: width, height: height)
                                    .clipped()
                            } placeholder: {
                                ProgressView()
                                    .frame(width: width, height: height)
                            }
                        }
                    }
                    
                    // 좋아요 버튼
                    Button(action: {
                        // TODO: 서버에 찜 상태 업데이트
                        onToggleFavorite()
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : Color.keyColorDarkGray)
                            .padding(5)
                            .background(Color.clear)
                            .clipShape(Circle())
                            .padding(5)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(listing.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading) // 왼쪽 정렬
                    
                    //23/02식(23년형) · 23,214 km · 하이브리드(가솔린) ·  경기
                    let tyear = String(listing.year).suffix(2)
                    Text("\(tyear)년형 · \(listing.mileage.decimalString)km · \(listing.fuel) · \(listing.region)")
                        .foregroundColor(.secondary)
                        .font(.system(size: 11, weight: .regular))
                        .lineLimit(2)          // 최대 2줄까지 허용
                        .multilineTextAlignment(.leading) // 왼쪽 정렬
                    
                    Text("\(NumberFormatter.koreanPriceString(from: listing.price))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.keyColorBlue)
                    
                    
                    
                }
                .frame(height: 80)
                .padding(.bottom, 6)
                .padding(.horizontal, 6)
                .padding(3)
            }
            .frame(height: 223)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.lineGray, lineWidth: 1) // 회색 테두리, 두께 1
            )
            
            // ✅ 상태 오버레이 (enum 기반)
            switch listing.status {
            case .reserved:
                statusOverlay(text: "예약 중")
            case .soldOut:
                statusOverlay(text: "판매 완료")
            default:
                EmptyView()
            }
        }
        
    }
    
    // 오버레이 뷰 따로 분리
      @ViewBuilder
      private func statusOverlay(text: String) -> some View {
          ZStack {
              Color.black.opacity(0.5)
                  .cornerRadius(12)
              Text(text)
                  .font(.system(size: 16, weight: .bold))
                  .foregroundColor(.white)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
}

#Preview {
//    MyListingsCardView()
}
