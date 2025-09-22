//
//  MyPageView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
struct MyPageView: View {
    @StateObject private var viewModel = MyPageViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()

    @State private var showLogoutConfirm = false

    
    let UserId = Auth.auth().currentUser?.uid
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack(alignment: .leading) {
                    
                    TopBar(style: .MyPage(title: "Profile"))
                        .padding(.bottom)
                        .background(Color.backgroundGray100)
                    
                    
                    // 상단 사용자 정보
                    HStack(alignment: .center, spacing: 16) {
                        ZStack(alignment: .bottomTrailing) {
                            
                            if let photoString = viewModel.photoURL, let url = URL(string: photoString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    // placeholder 생략
                                    Image("user1sample")
                                        .resizable()
                                        .scaledToFill()
                                }
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                            } else {
                                Image("user1sample")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            }
                            
                            // 오른쪽 하단 카메라 버튼
                            Button(action: {
                                // 사진 변경 액션

                            }) {
                                Image("Camera") // 또는 이미지로 대체 가능
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 26, height: 26)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 1)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.displayName)
                                .font(.system(size: 16, weight: .semibold))
                            if !viewModel.email.isEmpty {
                                Text(viewModel.email)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        

                        
                        Spacer()
                        

                    }
                    .padding(.horizontal)
                    .padding(.vertical,4)
                    
                    
                    Spacer().frame(height: 23)
                    
                    // My Section
                    Text("My")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .padding(.horizontal)
                        
                    
                    VStack(spacing: 0) {
                        ProfileRow(icon: "heart", title: "나의 찜 매물")
                        
                        NavigationLink(
                            destination: MyOrdersView(
                                currentUserId: UserId ?? "",
                                favoritesViewModel: favoritesViewModel // 외부에서 만든 뷰모델 주입
                            )
                            .navigationBarHidden(true)   // 기본 네비게이션 바 숨김
                        ) {
                            ProfileRow(icon: "car.fill", title: "나의 구입 매물")
                        }
                        
                        
                        
                        NavigationLink(
                            destination: MyListingsView(
                                currentUserId: UserId ?? "",
                                favoritesViewModel: favoritesViewModel // 외부에서 만든 뷰모델 주입
                            )
                            .navigationBarHidden(true)   // 기본 네비게이션 바 숨김
                        ) {
                           ProfileRow(icon: "dollarsign.circle", title: "나의 등록 매물")
                       }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                    
                    
                    
                    // Account Section
                    Text("Account")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
//                        ProfileRow(icon: "gearshape", title: "비밀번호 변경")
                        
                        NavigationLink(destination: ChangePasswordView()
                            .navigationBarHidden(true)
                        ) {
                            ProfileRow(icon: "gearshape", title: "비밀번호 변경")
                        }

                        
                        ProfileRow(icon: "arrow.right.square", title: "Log out")
                        .onTapGesture {
                                showLogoutConfirm = true
                            }
                        
    //                    .onTapGesture {
    //                        viewModel.logout()
    //                    }
                        
                        ProfileRow(icon: "person.fill.xmark", title: "회원 탈퇴")
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                    
                    Spacer()
                }
                .onAppear {
                    viewModel.fetchUser()
                }
            }
            
            // ✅ 로그아웃 확인 모달
            if showLogoutConfirm {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { showLogoutConfirm = false }
                
                ConfirmModalView(
                    message: "정말 로그아웃 하시겠습니까?",
                    confirmTitle: "로그아웃",
                    cancelTitle: "취소",
                    onConfirm: {
                        viewModel.logout()
                        showLogoutConfirm = false
                        // 여기서 홈 화면으로 이동시키고 싶다면,
                        // 예: root 뷰를 LoginView로 교체하는 로직 필요
                    },
                    onCancel: {
                        showLogoutConfirm = false
                    }
                )
            }
            
            
        }
        
    }
}



struct ProfileRow: View {
    var icon: String
    var title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()                 // resizable 추가
                .scaledToFit()               // 비율 유지
                .frame(width: 20, height: 20) // 아이콘 크기 증가
                .padding(10)                 // 원과의 여백 조절
                .foregroundColor(Color.iconGray)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.lineGray, lineWidth: 1)
                        .frame(width: 36, height: 36) // 원 크기 조정 (아이콘보다 약간 큰)
                )
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(Color.textGray300)
            
            Spacer()
            Image(systemName: "chevron.right")//person.badge.minus
                .foregroundColor(.gray)
            
        }
        .padding(.bottom, 16)
    }
}

#Preview {
    MyPageView()
}
