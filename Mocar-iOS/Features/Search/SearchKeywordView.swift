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
    @FocusState private var isSearchFieldFocused: Bool
    
    private var results: [SearchCar] {
        viewModel.searchCars(keyword: query)
    }
    
    private var categories: [String] {
        let set = Set(viewModel.allCars.map { $0.category })
        return Array(set).sorted()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            searchField
                .padding(.top, 16)
                .padding(.horizontal)
            
            if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
                    List(results) { car in
                        Button(action: {
                            viewModel.addRecentSearch("모델: \(car.model)")
                            viewModel.recentKeyword = car.model
                            dismiss()
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(car.maker) \(car.model)")
                                    .font(.headline)
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
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                }
            }
        }
        .navigationTitle("모델 검색")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            query = viewModel.recentKeyword
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSearchFieldFocused = true
            }
        }
        .onChange(of: query) { newValue, _ in
            viewModel.recentKeyword = newValue
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
                    Button(action: { query = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(UIColor.systemGray4), lineWidth: 1)
            )
        }
        
        private func formattedPrice(_ value: Int) -> String {
            NumberFormatter.decimal.string(from: NSNumber(value: value)) ?? "\(value)"
        }
        
        private func formattedMileage(_ value: Int) -> String {
            NumberFormatter.decimal.string(from: NSNumber(value: value)) ?? "\(value)"
        }
}
