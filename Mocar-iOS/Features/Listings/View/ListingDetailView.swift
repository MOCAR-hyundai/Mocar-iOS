//
//  ListingView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/15/25.
//

import SwiftUI

struct ListingDetailView: View {
    let listingId: String
    @StateObject private var viewModel = ListingDetailViewModel()
    
    var body: some View {
        NavigationStack{
            if let listing = viewModel.listing {
                VStack{
                    TopBar(style: .listing(title:viewModel.listing?.plateNo ?? ""))
                        .padding()
                    ScrollView{
                        VStack{
                            ZStack(alignment: .topTrailing){
                                CarImageTabView(images: listing.images)
                                FavoriteButton(isFavorite: viewModel.favorites.contains(where: {$0.id == listing.id}), action: {viewModel.toggleFavorite(listing)})
                            }
                            
                            //차량 기본 정보
                            VStack(alignment: .leading){
                                Text(listing.model)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading,8)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("\(listing.year)년")
                                    .padding(.leading,8)
                                    .foregroundStyle(.gray)
                                
                                Text("\(listing.priceInManwon)만원")
                                    .padding(.leading,8)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.keyColorBlue)
                            }
                            .padding(.horizontal)
                            
                            ProfileInfoView()
                                .padding(.horizontal)
                            
                            
                            VStack(alignment: .leading){
                                Text("기본 정보")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                VStack(alignment: .leading, spacing: 10){
                                    InfoRow(label: "차량 번호", value: listing.plateNo ?? "번호 없음")
                                    InfoRow(label: "연식", value: "\(listing.year)")
                                    InfoRow(label: "변속기", value: listing.transmission ?? "0cc")
                                    InfoRow(label: "차종", value: listing.carType ?? "-")
                                    InfoRow(label: "주행거리", value: "\(listing.mileage)km")
                                    InfoRow(label: "연료", value: listing.fuel)
                                }
                                .padding()
                                .background(Color.pureWhite)
                                .cornerRadius(12)
                                
                            }
                            .padding()
                            
                            
                            VStack{
                                Text("이 차의 상태")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(.bottom,3)
                                Text(listing.description)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                            .padding()
                            VStack{
                                Text("시세")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(.bottom, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                VStack{
                                    Text("시세안전구간")
                                        .foregroundStyle(.gray)
                                    Text("\(Int(viewModel.safeMin))~\(Int(viewModel.safeMax))만원")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .padding(.bottom, 15)
                                    
                                    PriceRangeView(viewModel: viewModel)
                                    
                                }
                                
                            }
                            .padding()
                            
                        }
                        .padding(.bottom, 90)
                        .onAppear {
                            viewModel.loadListing(id: listingId)
                            }
                        }
                    HStack{
                        Button(action:{
                            
                        }){
                            Text("구매 문의")
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                            
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                        )
                        
                    }
                    .padding()
                }
                .background(Color.backgroundGray100)
                .navigationBarHidden(true)   // 기본 네비게이션 바 숨김
                .navigationBarBackButtonHidden(true) // 기본 뒤로가기 숨김
                .onAppear {
                    viewModel.loadListing(id: listingId)
                }
            } else {
                VStack {
                    ProgressView()
                    Text("불러오는 중...")
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.backgroundGray100)
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                .onAppear {
                    viewModel.loadListing(id: listingId)
                }
            }
            
            }
    }

}


struct InfoRow: View{
    let label: String
    let value: String
    
    var body:some View{
        HStack {
            Text(label)
            Spacer()
            Text(value)
        }
    }
}



