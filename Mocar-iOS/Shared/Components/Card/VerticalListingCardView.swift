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
                if let imageUrl = listing.images.first, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 170, height: 125)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()    //  비율 유지 + 꽉 채움
                                .frame(width: 170, height: 125)
                                .clipped()         // 프레임 밖 잘라냄
                        case .failure:
                            Image("이미지없음icon") // fallback 이미지
                                .resizable()
                                .scaledToFit()   // 아이콘 비율 유지
                                .frame(width: 60, height: 60) // 아이콘 크기 (작게)
                                .frame(width: 170, height: 125) // 이미지 영역 크기 강제
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image("이미지없음icon")
                        .resizable()
                        .scaledToFit()   // 아이콘 비율 유지
                        .frame(width: 60, height: 60) // 아이콘 크기 (작게)
                        .frame(width: 170, height: 125) // 이미지 영역 크기 강제
                }
                // 좋아요 버튼
                FavoriteButton(
                    isFavorite: isFavorite,
                    onToggle: onToggleFavorite
                )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(listing.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading) // 왼쪽 정렬
                
                Text("\(String(listing.year))식 · \(listing.mileage) km · \(listing.fuel)")
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

