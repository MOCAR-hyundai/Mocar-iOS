//
//  ListingCardView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct ListingCardView: View{
    let listing: Listing
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading,spacing: 4) {
            ZStack(alignment: .topTrailing){
                Image("hyundai")
                    .resizable()
                
//                Button(action: {
//                    onToggleFavorite()
//                }) {
//                    Image(systemName: isFavorite ? "heart.fill" : "heart")
//                        .foregroundColor(isFavorite ? .red : .gray)
//                        .padding(8)
//                }
            }
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

#Preview {
    //ListingCardView()
}
