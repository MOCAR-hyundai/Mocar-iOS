//
//  BottomBar.swift
//  Mocar-iOS
//
//  Created by wj on 9/15/25.
//

import SwiftUI

struct BottomBar: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 메인 콘텐츠
            TabView(selection: $selectedTab) {

                HomeView().tag(0)
                SellCarFlowView().tag(1)
                SearchView().tag(2)
                ContentView().tag(3)
                MyPageView().tag(4)
            }
            
            // 커스텀 탭바
            VStack(spacing: 0) {
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                HStack(spacing: 5) {
                    bottomBarItem(icon: "Home", title: "내차사기", index: 0)
                    bottomBarItem(icon: "Car", title: "내차팔기", index: 1)
                    bottomBarItem(icon: "Search", title: "검색", index: 2)
                    bottomBarItem(icon: "Chat", title: "채팅", index: 3)
                    bottomBarItem(icon: "User", title: "마이", index: 4)
                }
                .padding(.top, 10)
                .padding(.horizontal)
                .padding(.bottom, -14) // 화면 최하단에서 10 내려옴
                .background(Color.white)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom) // 키보드 뜰 때만 safe area 무시
    }
    
    @ViewBuilder
    private func bottomBarItem(icon: String, title: String, index: Int) -> some View {
        Button {
            withAnimation(.spring()) {
                selectedTab = index
            }
        } label: {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 20) // Capsule 대신 적당한 라운드
                        .fill(selectedTab == index ? Color(UIColor(red: 48/255, green: 88/255, blue: 239/255, alpha: 1)) : Color.clear)
                        .frame(width: 68, height: 60)
                    
                    VStack {
                        Image(icon)
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(selectedTab == index ? .white : .gray)
                        
                        Text(title)
                            .font(.caption2)
                            .foregroundColor(selectedTab == index ? .white : .gray)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    BottomBar()
}
