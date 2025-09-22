//
//  SearchKeywordView.swift
//  Mocar-iOS
//
//  Created by wj on 9/19/25.
//

import SwiftUI

struct SearchKeywordView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SearchDetailViewModel
    @State private var query: String = ""
    @State private var debouncedQuery: String = ""
    @FocusState private var isSearchFieldFocused: Bool
    
    // 디바운스 태스크
    @State private var debounceTask: Task<Void, Never>? = nil
    
    // 검색 결과 (2글자 이상 + 디바운스 적용)
    @State private var searchResults: [SearchCar] = []
    
    // title별 요약: title, count, 연식 범위
    private var searchSummary: [(title: String, count: Int, yearText: String)] {
        var dict: [String: [SearchCar]] = [:]
        
        for car in searchResults {
            dict[car.title, default: []].append(car)
        }
        
        return dict.map { title, cars in
            let count = cars.count
            let years = cars.map { $0.year }
            let minYear = years.min() ?? 0
            let maxYear = years.max() ?? 0
            let yearText = minYear != maxYear ? "\(minYear)~\(maxYear)년" : "\(minYear)년"
            return (title: title, count: count, yearText: yearText)
        }
        .sorted { $0.title < $1.title }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 상단 검색창
            HStack {
                Button {
                    dismiss()
                    query = ""
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                searchField
            }
            .padding(.top, 16)
            .padding(.horizontal)
            
            recentKeywordsSection
                .padding(.horizontal)
            
            // 검색 입력이 충분하지 않을 때 안내
            if query.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 {
                Spacer()
                Text("모델명을 입력해 차량을 검색하세요.")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                // 검색 결과가 없을 때 안내
                if searchResults.isEmpty {
                    Spacer()
                    Text("일치하는 차량이 없습니다.")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    // 검색 결과 리스트
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(searchSummary, id: \.title) { item in
                                NavigationLink(destination: SearchResultsView(keyword: item.title, filter: nil)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(item.title)
                                                    .font(.headline)
                                                Spacer()
                                            }
                                            HStack(spacing: 12) {
                                                Text("\(item.yearText)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                Spacer()
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        
                                        Spacer()
                                        Text("\(item.count)대")
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                        Image(systemName: "chevron.right")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    viewModel.addKeyword(item.title)
                                    viewModel.recentKeyword = ""
                                    query = ""
                                })
                                .buttonStyle(.plain)
                                
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            query = viewModel.recentKeyword
            debouncedQuery = query
            viewModel.loadRecentKeywords()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSearchFieldFocused = true
            }
        }
        // 디바운스 적용 및 검색
        .onChange(of: query) { newValue in
            debounceTask?.cancel()
            debounceTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3초
                if !Task.isCancelled {
                    debouncedQuery = newValue
                    await performSearch(keyword: newValue)
                }
            }
        }
    }
    
    // MARK: - 검색 수행
    private func performSearch(keyword: String) async {
        guard keyword.count >= 2 else {
            searchResults = []
            return
        }
        searchResults = viewModel.searchCars(keyword: keyword)
    }
    
    // MARK: - 검색창
    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("모델명을 입력하세요", text: $query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.default)
                .focused($isSearchFieldFocused)
            
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 2)
        )
    }
    
    // MARK: - 최근 키워드
    private var recentKeywordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("최근 검색 키워드")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                Spacer()
                Button("전체 삭제") {
                    Task {
                        await viewModel.clearKeywords()
                    }
                }
                .font(.footnote)
                .foregroundColor(.red)
                .buttonStyle(.plain)
            }
            if !viewModel.recentKeywords.isEmpty {
                SearchKeywordChipsView(
                    keywords: viewModel.recentKeywords,
                    onTap: { keyword in
                        query = keyword
                        viewModel.recentKeyword = keyword
                    },
                    onDelete: { keyword in
                        viewModel.removeKeyword(keyword)
                    }
                )
            }
        }
    }
}
