//
//  ListingCardView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

//struct ListingCardView: View{
//    let listing: Listing
//    let isFavorite: Bool
//    let onToggleFavorite: () -> Void
//    
//    var body: some View {
//        VStack(alignment: .leading,spacing: 4) {
//            ZStack(alignment: .topTrailing){
//                Image("hyundai")
//                    .resizable()
//                
////                Button(action: {
////                    onToggleFavorite()
////                }) {
////                    Image(systemName: isFavorite ? "heart.fill" : "heart")
////                        .foregroundColor(isFavorite ? .red : .gray)
////                        .padding(8)
////                }
//            }
//            CarInfoView(listing: listing)
//            
//            
//            
//        }
//        .padding(10)
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(Color.gray, lineWidth: 1)
//        )
//        .background(Color.white)
//        .cornerRadius(12)
//        .frame(width: 170, height: 223)
//        
//    }
//}


struct ListingCardView: View {
    let listing: Listing
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topTrailing) {
                // TODO: 이미지 URL이 있다면 AsyncImage로 교체 가능
                if let imageUrl = listing.images.first, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 170, height: 120)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 170, height: 120)
                                .clipped()
                        case .failure:
                            Image("hyundai") // fallback 이미지
                                .resizable()
                                .scaledToFill()
                                .frame(width: 170, height: 120)
                                .clipped()
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image("hyundai") // fallback
                        .resizable()
                        .scaledToFill()
                        .frame(width: 170, height: 120)
                        .clipped()
                }
                
                // ✅ 찜 버튼
                FavoriteButton(
                    isFavorite: isFavorite,
                    onToggle: onToggleFavorite
                )
            }
            
            // 차량 정보 뷰
            CarInfoView(listing: listing)
        }
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 1)
        )
        .background(Color.white)
        .cornerRadius(12)
        .frame(width: 170, height: 223)
    }
}
