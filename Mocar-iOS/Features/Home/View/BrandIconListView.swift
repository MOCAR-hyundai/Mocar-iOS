//
//  BrandIconListView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct BrandIconView: View {
    let brand: Brand
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action:{
            onSelect()
        }){
            VStack{
                Image(brand.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(15) // 이미지 주변에 여백 → 원 안에 들어가게
                    .background(
                        Circle()
                            .fill(Color.white) // 흰 배경 원
                            .overlay(
                                Circle().stroke(isSelected ? Color.keyColorBlue : Color.gray200, lineWidth: 1)
                            )
                            .frame(width: 65, height: 65)
                    )
                Text(brand.name)
                    .foregroundColor(Color.textGray200)
            }
        }
    }
}

#Preview {
    //BrandIconListView()
}
