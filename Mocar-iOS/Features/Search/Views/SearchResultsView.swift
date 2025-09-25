//
//  SearchResultsView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import SwiftUI

struct SearchResultsView: View {
    
    @StateObject private var viewModel = SearchResultsViewModel()
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    @StateObject private var detailViewModel = SearchDetailViewModel()
    
    let keyword: String?
    let filter: RecentFilter?
    
    @State private var selectedFuels: [String] = []
    @State private var selectedRegions: [String] = []
    
    @State private var selectedCategory: String = "" // 임시용
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showPopup: Bool = false
    @State private var popupTitle: String = ""
    @State private var minValue: Double = 0
    @State private var maxValue: Double = 0
    @State private var lowerValue: Double = 0
    @State private var upperValue: Double = 0
    @State private var lowerPlaceholder: String = ""
    @State private var upperPlaceholder: String = ""
    @State private var unit: String = ""
    
    let cardWidth = (UIScreen.main.bounds.width - 12*3) / 2

    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack {
            // MARK: - 상단 바
            TopBar(style: .search(title:"\(viewModel.listings.count)대"))
                .background(Color.backgroundGray100)
//            HStack {
//                Button(action: { dismiss() }) {
//                    Image(systemName: "chevron.left")
//                        .frame(width: 20, height: 20)
//                        .padding(12)
//                        .foregroundColor(.black)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 50)
//                                .stroke(Color.lineGray, lineWidth: 1)
//                        )
//                }
//                Text("\(viewModel.listings.count)대")
//                    .font(.system(size: 16, weight: .bold))
//                Spacer()
//                HStack(spacing: 12) {
//                    Image("SortAscending")
//                    Image("MagnifyingGlass")
//                    Image("HeartStraight")
//                    Image("House")
//                }
//                .foregroundColor(.gray)
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 6)
//            .background(Color.backgroundGray100)
            
            // MARK: - 필터 바
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // 가격
                    Button {
                        popupTitle = "가격"
                        minValue = Double(detailViewModel.priceRange.lowerBound)
                        maxValue = Double(detailViewModel.priceRange.upperBound)
                        lowerValue = Double(viewModel.currentMinPrice ?? Int(detailViewModel.priceRange.lowerBound))
                        upperValue = Double(viewModel.currentMaxPrice ?? Int(detailViewModel.priceRange.upperBound))
                        lowerPlaceholder = "최소 가격"
                        upperPlaceholder = "최대 가격"
                        unit = "만원"
                        showPopup = true
                    } label: {
                        let minPrice = viewModel.currentMinPrice ?? Int(detailViewModel.priceRange.lowerBound)
                        let maxPrice = viewModel.currentMaxPrice ?? Int(detailViewModel.priceRange.upperBound)
                        let text = (minPrice == Int(detailViewModel.priceRange.lowerBound) &&
                                    maxPrice == Int(detailViewModel.priceRange.upperBound))
                        ? "가격"
                        : "\(minPrice)만원~\(maxPrice)만원"
                        FilterButtonLabel(title: text)
                    }
                    
                    // 연식
                    Button {
                        popupTitle = "연식"
                        minValue = Double(detailViewModel.yearRange.lowerBound)
                        maxValue = Double(detailViewModel.yearRange.upperBound)
                        lowerValue = Double(viewModel.currentMinYear ?? detailViewModel.yearRange.lowerBound)
                        upperValue = Double(viewModel.currentMaxYear ?? detailViewModel.yearRange.upperBound)
                        lowerPlaceholder = "최소 연식"
                        upperPlaceholder = "최대 연식"
                        unit = "년"
                        showPopup = true
                    } label: {
                        let minYear = viewModel.currentMinYear ?? detailViewModel.yearRange.lowerBound
                        let maxYear = viewModel.currentMaxYear ?? detailViewModel.yearRange.upperBound
                        let text = (minYear == detailViewModel.yearRange.lowerBound &&
                                    maxYear == detailViewModel.yearRange.upperBound)
                        ? "연식"
                        : "\(minYear)년~\(maxYear)년"
                        FilterButtonLabel(title: text)
                    }
                    
                    // 주행거리
                    Button {
                        popupTitle = "주행거리"
                        minValue = Double(detailViewModel.mileageRange.lowerBound)
                        maxValue = Double(detailViewModel.mileageRange.upperBound)
                        lowerValue = Double(viewModel.currentMinMileage ?? detailViewModel.mileageRange.lowerBound)
                        upperValue = Double(viewModel.currentMaxMileage ?? detailViewModel.mileageRange.upperBound)
                        lowerPlaceholder = "최소 km"
                        upperPlaceholder = "최대 km"
                        unit = "km"
                        showPopup = true
                    } label: {
                        let minMileage = viewModel.currentMinMileage ?? detailViewModel.mileageRange.lowerBound
                        let maxMileage = viewModel.currentMaxMileage ?? detailViewModel.mileageRange.upperBound
                        let text = (minMileage == detailViewModel.mileageRange.lowerBound &&
                                    maxMileage == detailViewModel.mileageRange.upperBound)
                        ? "주행거리"
                        : "\(minMileage)km~\(maxMileage)km"
                        FilterButtonLabel(title: text)
                    }
                    
                    // 연료
                    Menu {
                        Button("전체") {
                            selectedFuels = []
                            applyFilter()
                        }
                        
                        ForEach(detailViewModel.fuelOptions) { fuelItem in
                            Button(action: {
                                if selectedFuels.contains(fuelItem.name) {
                                    // 이미 선택되어 있으면 해제
                                    selectedFuels.removeAll { $0 == fuelItem.name }
                                } else {
                                    // 선택 추가
                                    selectedFuels.append(fuelItem.name)
                                }
                                applyFilter()
                            }) {
                                HStack {
                                    Text(fuelItem.name)
                                    Spacer()
                                    if selectedFuels.contains(fuelItem.name) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        let title = selectedFuels.isEmpty ? "연료" : selectedFuels.joined(separator: ", ")
                        FilterButtonLabel(title: title)
                    }
                    
                    // 지역
                    Menu {
                        Button("전체") {
                            selectedRegions = []
                            applyFilter()
                        }
                        
                        ForEach(detailViewModel.regionOptions) { regionItem in
                            Button(action: {
                                if selectedRegions.contains(regionItem.name) {
                                    selectedRegions.removeAll { $0 == regionItem.name }
                                } else {
                                    selectedRegions.append(regionItem.name)
                                }
                                applyFilter()
                            }) {
                                HStack {
                                    Text(regionItem.name)
                                    Spacer()
                                    if selectedRegions.contains(regionItem.name) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        let title = selectedRegions.isEmpty ? "지역" : selectedRegions.joined(separator: ", ")
                        FilterButtonLabel(title: title)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            // MARK: - 검색 결과
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.listings) { listing in
                        NavigationLink(destination: ListingDetailView(
                            service: ListingServiceImpl(repository: ListingRepository(),userStore: UserStore()),
                            listingId: listing.id ?? ""
                        )) {
                            BaseListingCardView(
                                listing: listing,
                                isFavorite: favoritesViewModel.isFavorite(listing),
                                onToggleFavorite: {
                                    Task { await favoritesViewModel.toggleFavorite(listing) }
                                }
                            )
                            {
                                Text(NumberFormatter.koreanPriceString(from: listing.price))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.keyColorBlue)
                            }
                            .frame(width: cardWidth)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .task {
                if let keyword = keyword {
                    await viewModel.fetchListings(forKeyword: keyword)
                } else if let filter = filter {
                    await viewModel.fetchListings(forFilter: filter)
                }
            }
        }
        .background(Color.backgroundGray100)
        .overlay(
            Group {
                if showPopup {
                    RangeSliderPopup(
                        isPresented: $showPopup,
                        title: popupTitle,
                        minValue: minValue,
                        maxValue: maxValue,
                        lowerPlaceholder: lowerPlaceholder,
                        upperPlaceholder: upperPlaceholder,
                        unit: unit,
                        lowerValue: $lowerValue,
                        upperValue: $upperValue,
                        onConfirm: {
                            switch popupTitle {
                            case "가격":
                                viewModel.currentMinPrice = Int(lowerValue)
                                viewModel.currentMaxPrice = Int(upperValue)
                            case "연식":
                                viewModel.currentMinYear = Int(lowerValue)
                                viewModel.currentMaxYear = Int(upperValue)
                            case "주행거리":
                                viewModel.currentMinMileage = Int(lowerValue)
                                viewModel.currentMaxMileage = Int(upperValue)
                            default:
                                break
                            }
                            applyFilter()
                        }
                    )
                }
            }
        )
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - 필터 적용
    private func applyFilter() {
        let minP = viewModel.currentMinPrice
        let maxP = viewModel.currentMaxPrice
        let minY = viewModel.currentMinYear
        let maxY = viewModel.currentMaxYear
        let minM = viewModel.currentMinMileage
        let maxM = viewModel.currentMaxMileage
        
        let fuels = selectedFuels.isEmpty ? nil : selectedFuels
        let regions = selectedRegions.isEmpty ? nil : selectedRegions
        
        viewModel.filterCurrentListings(
            minPrice: minP, maxPrice: maxP,
            minYear: minY, maxYear: maxY,
            minMileage: minM, maxMileage: maxM,
            fuels: fuels, regions: regions
        )
    }
}

// MARK: - 필터 버튼 공통 레이블
struct FilterButtonLabel: View {
    let title: String
    var body: some View {
        HStack(spacing: 5) {
            Text(title)
                .foregroundColor(.black)
                .font(.system(size: 12))
            Image(systemName: "chevron.down")
                .foregroundColor(.black)
                .font(.system(size: 10))
        }
    }
}


// MARK: - 상세 페이지
struct SearchListingDetailView: View {
    let listing: Listing
    
    var body: some View {
        VStack {
            if listing.images.count > 1 {
                Image(listing.images[1])
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .clipped()
            } else {
                Color.gray.opacity(0.2)
                    .frame(height: 120)
            }

            Text(listing.title)
                .font(.title2)
                .bold()
                .padding()
            
            Text("가격: \(NumberFormatter.koreanPriceString(from:listing.price))")
                .font(.headline)
            
            Text("연식: \(listing.year)년 | 주행거리: \(listing.mileage) km | 연료: \(listing.fuel)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            Spacer()
        }
        .navigationTitle("차량 상세")
    }
}

