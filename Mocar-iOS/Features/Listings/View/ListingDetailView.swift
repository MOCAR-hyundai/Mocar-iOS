//
//  ListingView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/15/25.
//

import SwiftUI

struct ListingDetailView: View {
    let listingId: String
    @State private var listing: Listing?
    
    @State private var currentValue: Double = 4680
    
    var minValue: Double = 4010
    var maxValue: Double = 5525
    var safeMin: Double = 4254
    var safeMax: Double = 5180
    
    var body: some View {
        NavigationStack{
            TopBar(style: .listing(title: "12가1234 "))
            ScrollView{
                VStack{
                    ZStack(alignment: .topTrailing){
                        Image("hyundai")
                                .resizable()
                                .frame(width: 300, height: 170)
                                .scaledToFit()
                                .padding()

                            Button(action: {
                                print("하트")
                            }) {
                                Image(systemName: "heart")
                                    .foregroundColor(.gray)
                                    .frame(width: 30, height: 30)
                                    .background(
                                        RoundedRectangle(cornerRadius: 50)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                            }
                            .padding(8) // 이미지 테두리와 버튼 사이 여백
                    }
                    
                    Text("현대 뉴 그랜저 하이브리드 2.4 캘리그래피")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading,8)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("22년 12(23년형)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading,8)
                        .foregroundStyle(.gray)
                    
                    Text("4,700만원")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading,8)
                        .padding(.top,4)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#3058EF"))
                    Divider()
                    HStack{
                        Image("kuromi")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 50, height: 50)
                        Text("Hela Quintin")
                        Spacer()
                        VStack(alignment: .trailing){
                            Text("100+Reviews")
                            HStack{
                                Text("5.0")
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                    
                            }
                        }
                        
                    }
                    
                    Divider()
                    VStack(alignment: .leading, spacing: 10) {
                        Text("기본 정보")
                            .font(.title3)
                            .fontWeight(.semibold)
                            

                        InfoRow(label: "차량 번호", value: "21나4827")
                        InfoRow(label: "연식", value: "22년 12월")
                        InfoRow(label: "변속기", value: "오토")
                        InfoRow(label: "차종", value: "대형")
                        InfoRow(label: "배기량", value: "0cc")
                        InfoRow(label: "연료", value: "하이브리드(가솔린)")
                    }
                    .padding(5)
                    VStack(spacing: 0){
                        Text("이 차의 상태")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.bottom,3)
                        Text("실내외 사용감이 다수 있습니다. 조수석 뒤 휠에 경미한 흠집이 있고 조수석 도외 외부 도어캐치 부근 경미한 붓 터치 자국이 있습니다.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(5)
                    }
                    
                    Text("시세")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("시세안전구간")
                        .foregroundStyle(.gray)
                    Text("4,245~5,180만원")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.bottom, 15)
                    //슬라이더 영역
                    GeometryReader { geo in
                            let width = geo.size.width
                            let total = maxValue - minValue
                        
                            let xPosition: (Double) -> CGFloat = { value in
                                CGFloat((value - minValue) / total * width)
                            }
                        
                            // 계산
                            let safeStartX = (safeMin - minValue) / total * width
                            let safeWidth = (safeMax - safeMin) / total * width
                            let circleX = (currentValue - minValue) / total * width
                            
                            
                            VStack() {
                                ZStack(alignment: .leading) {
                                    // 전체 바
                                    Capsule()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: width, height: 6)
                                    
                                    // 안전 구간
                                    Capsule()
                                        .fill(Color.blue)
                                        .frame(width: safeWidth, height: 6)
                                        .offset(x: safeStartX)
                                    
                                    // 현재 값
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
                                    .offset(x: circleX - 8,y:-13)
                                
                                }
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
                                                

                    
                }
                .padding()
            }
            HStack{
                Button(action:{
                    
                }){
                    Image("chat2")
                    
                }
                .frame(width: 50, height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 10) // 둥근 사각형
                        .stroke(Color.gray, lineWidth: 1) // 테두리 색과 두께
                )
                Button(action:{
                    
                }){
                   Text("구매하기")
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

#Preview {
    //ListingDetailView()
}
