//
//  RecentSearchView.swift
//  Mocar-iOS
//
//  Created by wj on 9/21/25.
//

import SwiftUI

struct RecentSearchView: View {
    @ObservedObject var viewModel: SearchDetailViewModel
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더
            HStack {
                Text("최근 검색")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Button("전체 삭제") {
                    viewModel.clearRecentSearches()
                }
                .foregroundColor(.red)
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)

            Divider()

            // 리스트
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
                                    isPresented = false
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
            Button("닫기") {
                isPresented = false
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
            .padding()
        }
        .background(Color.white)
    }
}
