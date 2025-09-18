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
            TopBar(style: .listing(title:viewModel.listing.plateNumber))
                .padding()
            ScrollView{
                VStack{
                    ZStack(alignment: .topTrailing){
                        Image("현대차-아이오닉-4-01")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 600)
                        Button(action: {
                            print("하트")
                        }) {
                            Image(systemName: "heart")
                                .foregroundColor(.gray)
                                .frame(width: 30, height: 30)
                        }
                        .padding(14)
                    }
                    VStack(alignment: .leading){
                        Text(viewModel.listing.model)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading,8)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("\(viewModel.listing.year)년")
                            .padding(.leading,8)
                            .foregroundStyle(.gray)
                        
                        Text("\(viewModel.listing.price)만원")
                            .padding(.leading,8)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#3058EF"))
                    }
                    .padding(.horizontal)
                    
                    ProfileinfoView()
                        .padding(.horizontal)
                    
                    
                    VStack(alignment: .leading){
                        Text("기본 정보")
                            .font(.title3)
                            .fontWeight(.semibold)
                        VStack(alignment: .leading, spacing: 10){
                            InfoRow(label: "차량 번호", value: viewModel.listing.plateNumber)
                            InfoRow(label: "연식", value: "\(viewModel.listing.year)")
                            InfoRow(label: "변속기", value: viewModel.listing.transmission)
                            InfoRow(label: "차종", value: "대형")
                            InfoRow(label: "배기량", value: "0cc")
                            InfoRow(label: "연료", value: viewModel.listing.fuel)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                    }
                    .padding()
                    
                    
                    VStack{
                        Text("이 차의 상태")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.bottom,3)
                        Text("실내외 사용감이 다수 있습니다. 조수석 뒤 휠에 경미한 흠집이 있고 조수석 도외 외부 도어캐치 부근 경미한 붓 터치 자국이 있습니다.")
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
                            Text("4,245~5,180만원")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.bottom, 15)
                            
                            PriceRangeView(viewModel: viewModel)
                                .frame(height: 100)
                            
                            
                            
                        }
                        
                    }
                    .padding()
                    
                    
                    
                }
                .padding(.bottom, 90)
                .onAppear {
                    // 목업 데이터에서 id 매칭
                    if let found = Listing.listingData.first(where: { $0.id == listingId }) {
                        viewModel.listing = found
                    }
                }
            }
            .onAppear {
                viewModel.loadListing(id: listingId)
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
    }
}

struct ProfileinfoView: View {
    var body: some View {
        VStack{
            HStack(spacing: 12){
                Image("짱구")
                    .resizable()
                    .clipShape(Circle())
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                
                Text("Hela Quintin")
                Spacer()
                
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background(Color.white) // 배경색
            .cornerRadius(12) // 모서리 둥글게
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

struct PriceRangeView: View {
    @ObservedObject var viewModel: ListingDetailViewModel
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let safeStartX = viewModel.safeStartX(width: width)
            let safeWidth = viewModel.safeWidth(width: width)
            let circleX = viewModel.circleX(width: width)
            
            let _ = print("""
                        [DEBUG] width: \(width)
                        safeStartX: \(safeStartX)
                        safeWidth: \(safeWidth)
                        circleX: \(circleX)
                        currentValue: \(viewModel.currentValue)
                        min: \(viewModel.minValue), max: \(viewModel.maxValue)
                        """)
            
            VStack(spacing: 8) {
                // 라벨 + 원
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "car.fill")
                        Text("적정")
                    }
                    .font(.system(size: 12))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(6)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 16, height: 16)
                }
                .offset(x: circleX - 8, y: -5) // 반지름만큼 보정
                
                // 막대기
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: width, height: 6)
                    
                    Capsule()
                        .fill(Color.blue)
                        .frame(width: safeWidth, height: 6)
                        .offset(x: safeStartX)
                }
                
                // 눈금
                HStack {
                    ForEach([4010, 4293, 4576, 4859, 5142, 5425], id: \.self) { value in
                        Text("\(value)")
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .frame(width: width)
            }
        }
        .frame(height: 100)
        
    }
}




#Preview {
    
    let previewVM = ListingDetailViewModel()
    previewVM.listing = Listing.listingData.first ?? .placeholder
    previewVM.currentValue = 4680 // 미리보기용 값
    return PriceRangeView(viewModel: previewVM)
        .frame(height: 120) // 최소 높이 지정
        .padding()
    
    
    
    
}
