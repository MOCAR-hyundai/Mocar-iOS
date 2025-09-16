//
//  SearchView.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedCategory: String? = "제조사"
    @State private var minPrice: Double = 0
    @State private var maxPrice: Double = 10000
    
    let categories = ["제조사", "가격", "연식", "주행거리", "차종", "연료", "지역"]
    
    struct Maker: Identifiable {
        let id = UUID()
        let name: String
        let count: Int
        let imageName: String
    }
    
    let makers: [Maker] = [
        Maker(name: "현대", count: 49355, imageName: "car.fill"),
        Maker(name: "제네시스", count: 7381, imageName: "car.fill"),
        Maker(name: "기아", count: 41936, imageName: "car.fill"),
        Maker(name: "한국GM", count: 9297, imageName: "car.fill"),
        Maker(name: "르노코리아", count: 7728, imageName: "car.fill"),
        Maker(name: "KG모빌리티", count: 7246, imageName: "car.fill"),
        Maker(name: "기타", count: 178, imageName: "car.fill"),
        Maker(name: "벤츠", count: 8413, imageName: "car.fill"),
        Maker(name: "BMW", count: 8362, imageName: "car.fill")
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 상단 검색창
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    
                    TextField("모델, 차량번호, 판매자를 검색해보세요", text: $searchText)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 2)
                        )
                }
                .padding(.horizontal)
                
                // 최근검색기록
                HStack {
                    Spacer()
                    Text("최근검색기록")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                
                Divider()
                
                // 메인 검색영역
                HStack(spacing: 0) {
                    LeftCategoryView(categories: categories, selectedCategory: $selectedCategory)
                    Divider()
                    RightOptionView(selectedCategory: $selectedCategory, minPrice: $minPrice, maxPrice: $maxPrice, makers: makers)
                }
                
                // 하단 버튼
                HStack(spacing: 12) {
                    Button(action: {
                        selectedCategory = "제조사"
                        searchText = ""
                        minPrice = 0
                        maxPrice = 10000
                    }) {
                        Text("초기화")
                            .fontWeight(.bold)
                            .frame(height: 50)
                            .frame(maxWidth: 120)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    
                    Button(action: {}) {
                        Text("156,973대 보기")
                            .fontWeight(.bold)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .background(Color.white)
        }
    }
}
