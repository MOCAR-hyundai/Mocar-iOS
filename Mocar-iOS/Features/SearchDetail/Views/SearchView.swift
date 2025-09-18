//
//  SearchView.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct SearchView: View {
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
                .padding(.horizontal)
                
                // 최근검색기록 (헤더 오른쪽에 팝업 열기 버튼)
                HStack {
                    Spacer()
                    Button(action: { showRecentSheet = true }) {
                        Text("최근검색기록")
                            .font(.footnote)
                            .foregroundColor(.blue)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .padding(.vertical, 8)
                .sheet(isPresented: $showRecentSheet) {
                    NavigationStack {
                        List {
                            if viewModel.recentSearches.isEmpty {
                                Text("저장된 검색 필터가 없습니다.")
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 24)
                            } else {
                                Section(
                                    header: HStack {
                                        Text("최근 검색 기록")
                                            .font(.headline)
                                        Spacer()
                                        Button("전체 삭제") {
                                            viewModel.clearRecentSearches()
                                        }
                                        .font(.footnote)
                                        .foregroundColor(.red)
                                        .buttonStyle(.plain)
                                    }
                                ) {
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
                                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                                    }
                                }
                            }
                        }
                        .navigationTitle("최근 검색")
                        .toolbar { ToolbarItem(placement: .cancellationAction) { Button("닫기") { showRecentSheet = false } } }
                    }
                }
                
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
