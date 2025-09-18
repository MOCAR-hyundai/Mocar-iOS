//
//  SearchView.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SearchDetailViewModel()
    @State private var selectedCategory: String? = "제조사"
    @State private var showRecentSheet: Bool = false
    
    private let categories = ["제조사", "가격", "연식", "주행거리", "차종", "연료", "지역"]
    
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
                    
                    NavigationLink(destination: SearchKeywordView(viewModel: viewModel)) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            Text("모델, 차량번호, 판매자를 검색해보세요")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 16)
                .padding(.horizontal)
                
                // 최근검색기록 (헤더 오른쪽에 팝업 열기 버튼)
                HStack {
                    Spacer()
                    Button(action: { showRecentSheet = true }) {
                        Text("최근검색기록")
                        Image(systemName: "chevron.right")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    
                }
                .padding()
                .sheet(isPresented: $showRecentSheet) {
                    VStack(spacing: 0) {
                        // 상단 커스텀 헤더
                        HStack {
                            Text("최근 검색")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            Button(action: {
                                viewModel.clearRecentSearches()
                            }) {
                                Text("전체 삭제")
                                    .font(.footnote)
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding()
                        .background(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)

                        Divider()

                        // 리스트 영역
                        if viewModel.recentSearches.isEmpty {
                            Spacer()
                            Text("저장된 검색 필터가 없습니다.")
                                .foregroundColor(.gray)
                                .padding(.vertical, 24)
                            Spacer()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(viewModel.recentSearches, id: \.self) { item in
                                        RecentSearchRow(
                                            summary: item,
                                            onApply: {
                                                viewModel.applyRecentSearch(item)
                                                showRecentSheet = false
                                            },
                                            onDelete: {
                                                viewModel.removeRecentSearch(item)
                                            }
                                        )
                                        .padding(.vertical, 8)
                                        Divider()
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // 닫기 버튼
                        Button(action: {
                            showRecentSheet = false
                        }) {
                            Text("닫기")
                                .font(.body)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                .padding()
                        }
                    }
                    .background(Color.white)                }
                
                Divider()
                
                // 메인 검색영역
                HStack(spacing: 0) {
                    LeftCategoryView(
                        categories: categories,
                        selectedCategory: $selectedCategory,
                        hasSelection: { viewModel.hasActiveFilters(for: $0) }
                    )
                    Divider()
                    RightOptionView(
                        selectedCategory: $selectedCategory,
                        viewModel: viewModel
                    )
                }
                
                // 하단 버튼
                HStack(spacing: 12) {
                    Button(action: {
                        selectedCategory = "제조사"
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
                    
                    Button(action: {
                        viewModel.saveCurrentFiltersAsRecent()
                        viewModel.debugLogAppliedFilters()
                    }) {
                        Text("\(formattedResultCount)대 보기")
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

private extension SearchView {
    var formattedResultCount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: viewModel.filteredCount)) ?? "\(viewModel.filteredCount)"
    }
}
