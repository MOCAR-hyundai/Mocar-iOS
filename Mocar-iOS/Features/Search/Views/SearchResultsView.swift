//
//  SearchResultsView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import SwiftUI

struct SearchResultsView: View {
    @StateObject private var viewModel = SearchResultsViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    
    let keyword: String?
    let filter: RecentFilter?
    
    @State private var selectedCategory: String = "" // 선택된 카테고리 저장
    
    @Environment(\.dismiss) private var dismiss   // 현재 화면 닫기 위한 dismiss

    @State private var showPopup: Bool = false
    @State private var popupTitle: String = ""
    @State private var minValue: Double = 0
    @State private var maxValue: Double = 0
    @State private var lowerValue: Double = 0
    @State private var upperValue: Double = 0
    @State private var lowerPlaceholder: String = ""
    @State private var upperPlaceholder: String = ""
    @State private var unit: String = ""
    
    let cardWidth = (UIScreen.main.bounds.width - 12*3) / 2 // 좌우 패딩 12, 그리드 간격 12

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    
    var body: some View {
            NavigationView {
                  VStack {
                      HStack {
                          Button(action: {
                              dismiss() // 뒤로가기
                          }) {
                              Image(systemName: "chevron.left")
                                  .frame(width: 20, height: 20)
                                  .padding(12) // 아이콘 주변 여백
                                  .foregroundColor(.black)
                                  .overlay(
                                      RoundedRectangle(cornerRadius: 50) // 충분히 큰 값이면 원처럼 둥글게
                                        .stroke(Color.lineGray, lineWidth: 1) // 테두리 색과 두께
                                  )
                          }
                          Text("123대")
                              .font(.system(size: 16, weight: .bold, design: .default))
                          
                          Spacer()
                          
                          
                          Group {
                              Image("SortAscending")
                              Image("MagnifyingGlass")
                              Image("HeartStraight")
                              Image("House")
                          }
                          .foregroundColor(.gray)
                          .frame(width: 20, height: 20)
                          .padding(1)

                          
                      }
                      .padding(.horizontal)
                      .padding(3)
                      .padding(.vertical, 6)
                      .padding(.bottom, 5)
                      .padding(.trailing, 7)
                      .background(Color.backgroundGray100)
                      
                    
                      // MARK: - 카테고리 바
                      HStack(spacing: 16) {
                          // 가격
                             Button {
                                 popupTitle = "가격"
                                 minValue = 0
                                 maxValue = 6000
                                 lowerValue = minValue
                                 upperValue = maxValue
                                 lowerPlaceholder = "최소 가격"
                                 upperPlaceholder = "최대 가격"
                                 unit = "만원"
                                 showPopup = true
                             } label: {
                                 HStack(spacing: 5) {
                                     Text("가격")
                                         .foregroundColor(.black)
                                         .font(.system(size: 12))
                                     Image(systemName: "chevron.down")
                                         .foregroundColor(.black)
                                         .font(.system(size: 10))
                                 }
                             }
                             
                             // 연식
                             Button {
                                 popupTitle = "연식"
                                 minValue = 2020
                                 maxValue = 2025
                                 lowerValue = minValue
                                 upperValue = maxValue
                                 lowerPlaceholder = "최소 연식"
                                 upperPlaceholder = "최대 연식"
                                 unit = "년"
                                 showPopup = true
                             } label: {
                                 HStack(spacing: 5) {
                                     Text("연식")
                                         .foregroundColor(.black)
                                         .font(.system(size: 12))
                                     Image(systemName: "chevron.down")
                                         .foregroundColor(.black)
                                         .font(.system(size: 10))
                                 }
                             }
                             
                             // 주행거리
                             Button {
                                 popupTitle = "주행거리"
                                 minValue = 0
                                 maxValue = 10_000
                                 lowerValue = minValue
                                 upperValue = maxValue
                                 lowerPlaceholder = "최소 km"
                                 upperPlaceholder = "최대 km"
                                 unit = "km"
                                 showPopup = true
                             } label: {
                                 HStack(spacing: 5) {
                                     Text("주행거리")
                                         .foregroundColor(.black)
                                         .font(.system(size: 12))
                                     Image(systemName: "chevron.down")
                                         .foregroundColor(.black)
                                         .font(.system(size: 10))
                                 }
                             }
                          
                          
                          
                          Menu {
                              Button("가솔린") { selectedCategory = "가솔린" }
                              Button("디젤") { selectedCategory = "디젤" }
                              Button("하이브리드") { selectedCategory = "하이브리드" }
                          } label: {
                              HStack(spacing: 5) {
                                  Text("연료")
                                      .foregroundColor(.black)
                                      .font(.system(size: 12))
                                  Image(systemName: "chevron.down")
                                      .foregroundColor(.black)
                                      .font(.system(size: 10))
                              }
                          }
                          Menu {
                              Button("경기") { selectedCategory = "경기" }
                              Button("서울") { selectedCategory = "서울" }
                          } label: {
                              HStack(spacing: 5) {
                                  Text("지역")
                                      .foregroundColor(.black)
                                      .font(.system(size: 12))
                                  Image(systemName: "chevron.down")
                                      .foregroundColor(.black)
                                      .font(.system(size: 10))
                              }
                          }
                          
                          Spacer()
                        
                      }
                      .padding(.horizontal)
                      .padding(.leading,3)
                      
                      // MARK: - 검색 결과 그리드
                      ScrollView {
                          LazyVGrid(columns: [
                              GridItem(.fixed(cardWidth), spacing: 12),
                              GridItem(.fixed(cardWidth), spacing: 12)
                          ], spacing: 12) {
                              ForEach(viewModel.listings) { listing in
                                  NavigationLink(destination: ListingDetailView(listingId: listing.id ?? "", favoritesViewModel: favoritesViewModel)) {
                                      ListingCard(listing: listing, favoritesViewModel: favoritesViewModel)
                                        .frame(width: cardWidth) // 카드 폭 고정
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
                // MARK: - RangeSliderPopup
                  .background(Color.backgroundGray100)
//                  .sheet(isPresented: $showPopup) {
//                           RangeSliderPopup(
//                               isPresented: $showPopup,
//                               title: popupTitle,
//                               minValue: minValue,
//                               maxValue: maxValue,
//                               lowerPlaceholder: lowerPlaceholder,
//                               upperPlaceholder: upperPlaceholder,
//                               unit: unit,
//                               lowerValue: $lowerValue,
//                               upperValue: $upperValue
//                           )
//                       }
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
                                    upperValue: $upperValue
                                )
                            }
                        }
                    )
                

        }
            .navigationBarBackButtonHidden(true)

    }

}

struct ListingCard: View {
    let listing: Listing
    @State private var isFavorite: Bool = false
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    
    let cardWidth = (UIScreen.main.bounds.width - 12*3) / 2 // 좌우 패딩 12, 그리드 간격 12

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            ZStack(alignment: .topTrailing) {
                // 이미지 배경 통일
                Color.cardBgGray // 배경색
                    .frame(height: 124)
                    .frame(maxWidth: .infinity)
                
                  // 실제 이미지
                if let first = listing.images.first, let url = URL(string: first) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: cardWidth, height: 124)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()    // 꽉 채우기
                                .frame(width: cardWidth, height: 124)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .clipped()         // 넘치는 부분 잘라냄
                        case .failure:
                            Image(systemName: "car.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: cardWidth, height: 124)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                  
                // 좋아요 버튼
                Button(action: {
                    favoritesViewModel.toggleFavorite(listing)
                }) {
                    Image(systemName: favoritesViewModel.isFavorite(listing) ? "heart.fill" : "heart")
                        .foregroundColor(favoritesViewModel.isFavorite(listing) ? .red : Color.keyColorDarkGray)
                        .padding(5)
                        .background(Color.clear)
                        .clipShape(Circle())
                        .padding(5)
                }
            }
            
            // 차량 정보
            VStack(alignment: .leading, spacing: 6) {
                Text(listing.title)
//                Text("23/02식(23년형) ・ 23,214km · 하이브리드(가솔린) ・ 경기")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading) // 왼쪽 정렬
                
                Text("\(listing.year)년 · \(listing.mileage)km · \(listing.fuel) · \(listing.region)")
//                Text("23/02식(23년형) ・ 23,214km · 하이브리드(가솔린) ・ 경기")
                    .foregroundColor(.secondary)
                    .font(.system(size: 11, weight: .regular))
                    .lineLimit(2)          // 최대 2줄까지 허용
                    .multilineTextAlignment(.leading) // 왼쪽 정렬
 
                
                Text("\(listing.price.formattedWithSeparator())원")
//                Text("1억 3,860만원")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.keyColorBlue)
            }
            .frame(height: 80)
            .padding(.bottom, 6)
            .padding(.horizontal, 6)
            .padding(3)
        }
        .frame(height: 223)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.lineGray, lineWidth: 1) // 회색 테두리, 두께 1
        )
    }
}

// MARK: - 상세 페이지
struct SearchListingDetailView: View {
    let listing: Listing
    
    var body: some View {
//        VStack {
//            if listing.images.count > 1 {
//                Image(listing.images[1])
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 120)
//                    .clipped()
//            } else {
//                Color.gray.opacity(0.2)
//                    .frame(height: 120)
//            }
//
//            Text(listing.title)
//                .font(.title2)
//                .bold()
//                .padding()
//            
//            Text("가격: \(listing.price.formattedWithSeparator())원")
//                .font(.headline)
//            
//            Text("연식: \(listing.year)년 | 주행거리: \(listing.mileage) km | 연료: \(listing.fuel)")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .padding(.top, 8)
//            
//            Spacer()
//        }
//        .navigationTitle("차량 상세")
    }
}

