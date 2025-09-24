//
//  IntroView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/24/25.
//

import SwiftUI

struct IntroView: View {
    var body: some View {
        ZStack {
              // 배경 이미지
              Image("splash")
                  .resizable()
                  .scaledToFill()
                  .ignoresSafeArea()
              
              VStack(alignment: .leading) {
                  Spacer() // 상단 여백 → 텍스트를 아래로 밀어줌
                  
                  VStack(alignment: .leading, spacing: 16) {
                      Text("중고차 거래를")
                          .font(.system(size: 48, weight: .semibold, design: .default))
                          .foregroundColor(.white)
                          .padding(.leading, 32)
                      
                      Text("더 간편하게")
                          .font(.system(size: 48, weight: .semibold, design: .default))
                          .foregroundColor(.white)
                          .padding(.leading, 32)
                  }
                  .padding(.bottom, 60) // 텍스트와 로고 사이 간격
                  
                  Spacer() // 텍스트를 화면 중앙쯤으로 배치해줌
                  
                  // 하단 로고
                  HStack {
                      Spacer()
                      Image("logoClear")
                          .resizable()
                          .scaledToFit()
                          .frame(width: 230, height: 82)
                          .padding(.bottom, 90) // 바닥과의 간격
                      Spacer()
                  }
              }
          }
    }
}

#Preview {
    IntroView()
}
