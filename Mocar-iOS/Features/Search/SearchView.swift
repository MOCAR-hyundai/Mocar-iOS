//
//  SearchView.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

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

                    TextField("모델, 차량번호, 판매자를 검색해보세요", text: $viewModel.searchText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
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
                    LeftCategoryView(categories: viewModel.categories, selectedCategory: $viewModel.selectedCategory)
                    Divider()
                    RightOptionView(viewModel: viewModel)
                }

                Divider()

                // 결과 요약
                HStack {
                    Text("검색 결과 \(viewModel.filteredListings.count)대")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // 하단 버튼
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.resetFilters()
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
                        Text("\(viewModel.filteredListings.count)대 보기")
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
