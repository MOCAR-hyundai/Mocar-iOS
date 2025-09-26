//
//  FavoriteCarListView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct FavoriteCardView: View{
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
                                .frame( height: 143)
                                .frame(maxWidth: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()    //  비율 유지 + 꽉 채움
                                .frame(height: 143)
                                .frame(maxWidth: .infinity)
                                .clipped()         // 프레임 밖 잘라냄
                        case .failure:
                            Image("이미지없음icon") // fallback 이미지
                                .frame( height: 143)
                                .frame(maxWidth: .infinity)
                                .clipped()
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image("이미지없음icon")
                        .frame( height: 143)
                        .frame(maxWidth: .infinity)
                        .clipped()
                }
                
                
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
            .padding(.horizontal, 12)
            .padding(4)
            
        }
        .frame(width: 240, height: 240)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 0.5)
        )
        .background(Color.white)  // 카드 내부 색 지정
        .cornerRadius(12)

    }
}
