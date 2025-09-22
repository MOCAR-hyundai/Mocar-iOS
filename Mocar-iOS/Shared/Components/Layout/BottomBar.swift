//
//  BottomBar.swift
//  Mocar-iOS
//
//  Created by wj on 9/15/25.
//

import SwiftUI

struct BottomBar: View {
    @State private var selectedTab: Int = 0
    
    @EnvironmentObject var session: UserSession //전역 세션 받아오기
    @State private var showLoginModal = false
     @State private var navigateToLogin = false
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .bottom) {
                // 메인 콘텐츠
                TabView(selection: $selectedTab) {

                    HomeView().tag(0)
                    SellCarFlowView().tag(1)
                    SearchView().tag(2)
                    
                   // ChatListView에 currentUserId 전달
                    if let user = session.user {
                       ChatListView(currentUserId: user.id ?? " ")
                           .tag(3)
                    } else {
                       Color.clear.tag(3)
                    }
                    if let _ = session.user {
                        MyPageView().tag(4)
                    } else {
                        Color.clear.tag(4)
                    }
                   
                }
                
                // 커스텀 탭바
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    HStack(spacing: 5) {
                        bottomBarItem(icon: "Home", title: "내차사기", index: 0)
                        bottomBarItem(icon: "Car", title: "내차팔기", index: 1)
                        bottomBarItem(icon: "Search", title: "검색", index: 2)
                        bottomBarItem(icon: "Chat", title: "채팅", index: 3,requiresLogin: true)
                        bottomBarItem(icon: "User", title: "마이", index: 4,requiresLogin: true)
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
                    .padding(.bottom, -14) // 화면 최하단에서 10 내려옴
                    .background(Color.white)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom) // 키보드 뜰 때만 safe area 무시
            .navigationDestination(isPresented: $navigateToLogin){
                LoginView()
            }
            //모달
            .overlay{
                if showLoginModal {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ConfirmModalView(
                        message: "로그인 이후 사용 가능합니다.",
                        confirmTitle: "로그인",
                        cancelTitle: "취소",
                        onConfirm: {
                            showLoginModal = false
                            navigateToLogin = true
                        },
                        onCancel: {
                            showLoginModal = false
                        }
                    )
                    .background(Color.clear) // 배경 투명
                    .transition(.opacity) // 부드럽게 등장
                    .animation(.easeInOut, value: showLoginModal)
                }
            }
        }
        
    }
    
    @ViewBuilder
    private func bottomBarItem(icon: String, title: String, index: Int,requiresLogin: Bool = false) -> some View {
        Button {
            if requiresLogin && session.user == nil {
                // 로그인 필요 → 모달 표시
                showLoginModal = true
            } else {
                withAnimation(.spring()) {
                    selectedTab = index
                }
            }
        } label: {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 20) // Capsule 대신 적당한 라운드
                        .fill(selectedTab == index ? Color.keyColorBlue : Color.clear)
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
