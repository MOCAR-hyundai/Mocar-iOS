//
//  SearchResultsView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import SwiftUI

struct SearchResultsView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    @State private var selectedCategory: String = "" // 선택된 카테고리 저장

//    @State private var selectedOption1 = "전체"
//    @State private var selectedOption2 = "전체"
//    @State private var selectedOption3 = "전체"
    
    let columns = [
        GridItem(.flexible(minimum: 160, maximum: 200), spacing: 12),
        GridItem(.flexible(minimum: 160, maximum: 200), spacing: 12)
    ]

    
    var body: some View {
        NavigationView {
              VStack {
                  HStack {
                      Button(action: {
                          // 뒤로가기 액션
                      }) {
                          Image(systemName: "chevron.left")
                              .frame(width: 20, height: 20)
                              .padding(12) // 아이콘 주변 여백
                              .foregroundColor(.black)
                              .overlay(
                                  RoundedRectangle(cornerRadius: 50) // 충분히 큰 값이면 원처럼 둥글게
                                      .stroke(Color(hex: "D7D7D7"), lineWidth: 1) // 테두리 색과 두께
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
                  .background(Color(hex:"F8F8F8"))
                  
                
                  // MARK: - 카테고리 바
                  HStack(spacing: 16) {
                      Menu {
                             Button("500만원 이하") { selectedCategory = "500만원 이하" }
                             Button("500~1000만원") { selectedCategory = "500~1000만원" }
                             Button("1000만원 이상") { selectedCategory = "1000만원 이상" }
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
                      
                      Menu {
                          Button("2023년") { selectedCategory = "2023년" }
                          Button("2022년") { selectedCategory = "2022년" }
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
                      
                      Menu {
                          Button("1만 km 이하") { selectedCategory = "1만 km 이하" }
                          Button("1~3만 km") { selectedCategory = "1~3만 km" }
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
                      LazyVGrid(columns: columns, spacing: 25) {
                          ForEach(viewModel.listings) { listing in
                              NavigationLink(destination: ListingDetailView(listing: listing)) {
                                  ListingCard(listing: listing)
                              }
                          }
                      }
                      .padding(.horizontal)
                      .padding(.top, 10)
                  }
              }
              .background(Color(hex:"F8F8F8"))
            
          }
    }
    
}

struct ListingCard: View {
    let listing: Listing
    @State private var isFavorite: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            ZStack(alignment: .topTrailing) {
                // 이미지 배경 통일
                  Color(hex: "F0F0F0") // 배경색
                    .frame(maxWidth: .infinity)
                  
                  // 실제 이미지
                  if listing.images.count > 0 {
                      Image(listing.images[0])
                          .resizable()
                          .scaledToFit()
                          .padding(5)
                          .frame(height: 124)
                          .clipped()
                  }
                  
                // 좋아요 버튼
                Button(action: {
                    isFavorite.toggle()
                    // TODO: 서버에 찜 상태 업데이트
                    
                    
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                        .padding(5)
                        .background(Color.clear)
                        .clipShape(Circle())
                        .padding(5)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(listing.title)
//                Text("23/02식(23년형) ・ 23,214km · 하이브리드(가솔린) ・ 경기")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading) // 왼쪽 정렬
                
//                Text("\(listing.year)식 · \(listing.mileage) km · \(listing.fuel)")
                Text("23/02식(23년형) ・ 23,214km · 하이브리드(가솔린) ・ 경기")
                    .foregroundColor(.secondary)
                    .font(.system(size: 11, weight: .regular))
                    .lineLimit(2)          // 최대 2줄까지 허용
                    .multilineTextAlignment(.leading) // 왼쪽 정렬
 
                    
                
//                Text("\(listing.price.formattedWithSeparator())원")
                Text("1억 3,860만원")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "3058EF"))
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
                .stroke(Color(hex: "D7D7D7"), lineWidth: 1) // 회색 테두리, 두께 1
        )
    }
}

// MARK: - 상세 페이지
struct ListingDetailView: View {
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

// MARK: - 숫자 포맷 Extension
extension Int {
    func formattedWithSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}


func duplicate() {
    print("Duplicate tapped")
}

func rename() {
    print("Rename tapped")
}

func delete() {
    print("Delete tapped")
}

func copy() { print("Copy tapped") }
func copyFormatted() { print("Copy Formatted tapped") }
func copyPath() { print("Copy Library Path tapped") }



#Preview {
    SearchResultsView()
}
