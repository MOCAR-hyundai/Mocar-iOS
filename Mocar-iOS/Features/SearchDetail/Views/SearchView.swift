//
//  SearchView.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI
import FirebaseAuth

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel 
    @ObservedObject var viewModel: SearchDetailViewModel
    @State private var selectedCategory: String? = "제조사"
    @State private var showRecentSheet: Bool = false
    @State private var path: [SearchDestination] = []
    var onDismiss: (() -> Void)? = nil
    
    private let categories = ["제조사", "가격", "연식", "주행거리", "차종", "연료", "지역"]
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                // 상단 검색창
                HStack {
                    Button(action: {
                        if let onDismiss = onDismiss {
                            onDismiss()
                        } else {
                           dismiss()
                        }
                    }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                    NavigationLink(value: SearchDestination.searchKeyword) {
                        SearchBar(style: .placeholder(text: "차량 모델을 검색해보세요"))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 16)
                .padding(.horizontal)
                
                // 최근검색기록
                HStack {
                    Spacer()
                    Button(action: { showRecentSheet = true }) {
                        Text("최근검색기록")
                        Text("\(viewModel.recentSearches.count)")
                        Image(systemName: "chevron.right")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .padding()
                .sheet(isPresented: $showRecentSheet) {
                    RecentSearchView(viewModel: viewModel, isPresented: $showRecentSheet)
                }
                
                Divider()
                
                // 메인 검색 영역
                HStack(spacing: 0) {
                    LeftCategoryView(
                        categories: categories,
                        selectedCategory: $selectedCategory,
                        hasSelection: { viewModel.hasActiveFilters(for: $0) }
                    )
                    Divider()
                    RightOptionView(
                        selectedCategory: $selectedCategory,
                        viewModel: viewModel,
                        path: $path
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
                        // 필터 저장
                        viewModel.saveCurrentFiltersAsRecent()
                        viewModel.debugLogAppliedFilters()

                        // SearchDestination으로 이동
                        let firestoreFilter = RecentFilter(
                            userId: Auth.auth().currentUser?.uid,
                            brand: viewModel.selectedMaker,
                            model: viewModel.selectedModel,
                            subModels: Array(viewModel.selectedTrims),
                            carTypes: Array(viewModel.carTypeOptions.filter { $0.checked }.map { $0.name }),
                            fuels: Array(viewModel.fuelOptions.filter { $0.checked }.map { $0.name }),
                            regions: Array(viewModel.regionOptions.filter { $0.checked }.map { $0.name }),
                            minPrice: viewModel.minPrice,
                            maxPrice: viewModel.maxPrice,
                            minYear: viewModel.minYear,
                            maxYear: viewModel.maxYear,
                            minMileage: viewModel.minMileage,
                            maxMileage: viewModel.maxMileage
                        )
                        path.append(.searchResults(keyword: nil, filter: firestoreFilter))
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
            .navigationDestination(for: SearchDestination.self) { dest in
                switch dest {
                case .model(let makerName):
                    ModelSelectionView(viewModel: viewModel,
                                       makerName: makerName,
                                       onCancel: { path = [] })
                case .trim(let makerName, let modelName):
                    TrimSelectionView(viewModel: viewModel,
                                      makerName: makerName,
                                      modelName: modelName,
                                      path: $path
                    )
                case .searchKeyword:
                    SearchKeywordView(viewModel: viewModel)
                    
                case .searchResults(let keyword, let filter):
                    SearchResultsView(keyword: keyword, filter: filter)
                    
                case .searchResultDetail(let listingId):
                    ListingDetailView(
                        service: ListingServiceImpl(repository: ListingRepository(),
                            userStore: UserStore()),
                                    listingId: listingId
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadRecentFilters()
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

// Destination enum
enum SearchDestination: Hashable {
    case model(makerName: String)
    case trim(makerName: String, modelName: String)
    case searchKeyword
    case searchResults(keyword: String?, filter: RecentFilter?)
    case searchResultDetail(listingId: String)
}
