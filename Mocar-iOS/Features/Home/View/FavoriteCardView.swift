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
                Image("hyundai")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 120)   // frame을 카드 width에 맞춤
                    .clipped()                        // 잘려서 여백 없애기

//                Button(action: {
//                    onToggleFavorite()
//                }) {
//                    Image(systemName: isFavorite ?  "heart.fill" : "heart")
//                        .foregroundColor(.red)
//                        .padding(0)
//                }
//                FavoriteButton(
//                    isFavorite: isFavorite,           
//                    onToggle: onToggleFavorite
//                )
            }
            CarInfoView(listing: listing)
            
        }
        .padding(24)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 0.5)
        )
        .background(Color.white)  // 카드 내부 색 지정
        .cornerRadius(12)

    }
}

#Preview {
    //FavoriteListCardView()
}
