////
////  BrandIconListView.swift
////  Mocar-iOS
////
////  Created by Admin on 9/18/25.
////
//
import SwiftUI

struct BrandIconView: View {
    let brand: CarBrand 
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: {
            onSelect()
        }) {
            VStack {
                AsyncImage(url: URL(string: brand.logoUrl)) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(15) // 로고를 원 안에 배치
                        .background(
                            Circle()
                                .fill(Color.white)
                                .overlay(
                                    Circle().stroke(isSelected ? Color.keyColorBlue : Color.borderGray, lineWidth: 1)
                                )
                                .frame(width: 65, height: 65)
                        )
                } placeholder: {
                    ProgressView()
                        .frame(width: 40, height: 40)
                        .padding(15)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .overlay(
                                    Circle().stroke(Color.borderGray, lineWidth: 1)
                                )
                                .frame(width: 65, height: 65)
                        )
                }
                
                Text(brand.name)
                    .foregroundColor(Color.textGray200)
                    .font(.caption)
            }
        }
    }
}

//
//struct BrandIconView: View {
//    let brand: CarBrand
//    let isSelected: Bool
//    let onSelect: () -> Void
//    
//    var body: some View {
//        Button(action:{
//            onSelect()
//        }){
//            
//            VStack{
//                Image(brand.logo)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 40, height: 40)
//                    .padding(15) // 이미지 주변에 여백 → 원 안에 들어가게
//                    .background(
//                        Circle()
//                            .fill(Color.white) // 흰 배경 원
//                            .overlay(
//                                Circle().stroke(isSelected ? Color.keyColorBlue : Color.borderGray, lineWidth: 1)
//                            )
//                            .frame(width: 65, height: 65)
//                    )
//                Text(brand.name)
//                    .foregroundColor(Color.textGray200)
//            }
//        }
//    }
//}
