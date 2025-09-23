//
//  FavoriteButton.swift
//  Mocar-iOS
//
//  Created by Admin on 9/19/25.
//

import SwiftUI

struct FavoriteButton: View {
    let isFavorite: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundColor(.red)
                .frame(width: 30, height: 30)
        }
        .padding(14)
    }
}


