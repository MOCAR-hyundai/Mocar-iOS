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
    private var results: [SearchCar] {
        guard debouncedQuery.count >= 2 else { return [] }
        return viewModel.searchCars(keyword: debouncedQuery)
    }
    
    // title별 그룹핑
    private var groupedResults: [String: [SearchCar]] {
        Dictionary(grouping: results, by: { $0.title })
    }
    
    private var categories: [String] {
        let set = Set(viewModel.allCars.map { $0.category })
        return Array(set).sorted()
    }
    
    var body: some View {
        VStack(spacing: 16) {
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
            
            if !viewModel.recentKeywords.isEmpty {
                recentKeywordsSection
                    .padding(.horizontal)
            }
            
            if query.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 {
                Spacer()
                Text("모델명을 입력해 차량을 검색하세요.")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                if results.isEmpty {
                    Spacer()
                    Text("일치하는 차량이 없습니다.")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    // title별로 중복 제거하고 리스트
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(groupedResults.keys.sorted(), id: \.self) { title in
                                if let cars = groupedResults[title], let car = cars.first {
                                    NavigationLink(destination: SearchResultsView()) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Text("\(title)")
                                                        .font(.headline)
                                                    Spacer()
                                                }
                                                HStack(spacing: 12) {
                                                    Text("연식 \(car.year)년")
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                    Text("가격 \(formattedPrice(car.price))만원")
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                    Text("주행 \(formattedMileage(car.mileage))km")
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            .padding(.vertical, 8)
                                            
                                            Spacer()
                                            Text("\(cars.count)대")
                                                .font(.subheadline)
                                                .foregroundColor(.black)
                                            Image(systemName: "chevron.right")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                    }
                                    .simultaneousGesture(TapGesture().onEnded {
                                        viewModel.addRecentKeyword(title)
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
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            query = viewModel.recentKeyword
            debouncedQuery = query
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSearchFieldFocused = true
            }
        }
        // 디바운스 적용
        .onChange(of: query) { newValue in
            debounceTask?.cancel()
            debounceTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3초 딜레이
                if !Task.isCancelled {
                    debouncedQuery = newValue
                }
            }
        }
    }
    
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
    
    private func formattedPrice(_ value: Int) -> String {
        NumberFormatter.decimal.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    private func formattedMileage(_ value: Int) -> String {
        NumberFormatter.decimal.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    private var recentKeywordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !viewModel.recentKeywords.isEmpty {
                HStack {
                    Text("최근 검색 키워드")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Spacer()
                    Button("전체 삭제") {
                        viewModel.clearRecentKeywords()
                    }
                    .font(.footnote)
                    .foregroundColor(.red)
                    .buttonStyle(.plain)
                }
                SearchKeywordChipsView(
                    keywords: viewModel.recentKeywords,
                    onTap: { keyword in
                        query = keyword
                        viewModel.recentKeyword = keyword
                    },
                    onDelete: { keyword in
                        viewModel.removeRecentKeyword(keyword)
                    }
                )
            }
        }
    }
}
