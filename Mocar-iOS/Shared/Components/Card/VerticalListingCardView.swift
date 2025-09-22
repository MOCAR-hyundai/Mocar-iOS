//
//  VerticalListingCardView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import SwiftUI

struct VerticalListingCardView: View {
    let listing: Listing
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            ZStack(alignment: .topTrailing) {
                // 이미지 배경 통일
                Color.cardBgGray // 배경색
                    .frame(maxWidth: .infinity)
                  
                  // 실제 이미지
                  if listing.images.count > 0 {
                      Image(listing.images[0])
                          .resizable()
                          .scaledToFit()
                          .padding(5)
                          .frame(height: 124)
                          .clipped()
                  }
                  
                // 좋아요 버튼
                Button(action: {
                    onToggleFavorite()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                        .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(listing.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading) // 왼쪽 정렬
                
                Text("\(listing.year)식 · \(listing.mileage) km · \(listing.fuel)")
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
    }
}

