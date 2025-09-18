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
    
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
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
                                    .stroke(Color.lineGray, lineWidth: 1) // 테두리 색과 두께
                            )
                    }
                    Spacer()
                    Text("Profile")
                        .font(.system(size: 18, weight: .bold, design: .default))
                    
                    
                    Spacer()
                    
                    Button(action: {
                        // 점 세개 액션
                    }) {
                        Image("3Dot")
                            .frame(width: 20, height: 20)
                            .padding(12) // 아이콘 주변 여백
                            .overlay(
                                RoundedRectangle(cornerRadius: 50) // 충분히 큰 값이면 원처럼 둥글게
                                    .stroke(Color.lineGray, lineWidth: 1) // 테두리 색과 두께
                            )
                    }
                }
                .padding(.horizontal)
                .padding(3)
                .padding(.vertical, 6)
                .padding(.bottom, 5)
                .background(Color.backgroundGray100) // <- F8F8F8 배경
                
                
                // 상단 사용자 정보
                HStack(alignment: .center, spacing: 16) {
                    ZStack(alignment: .bottomTrailing) {
                        // 프로필 사진
//                        Image("user1sample")
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 80, height: 80)
//                            .clipShape(Circle())
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
                    
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Benjamin Jack")
//                            .font(.system(size: 16, weight: .semibold, design: .default))
//                        
//                        Text("benjaminJack@gmail.com")
//                            .font(.system(size: 14))
//                            .foregroundColor(.gray)
//                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Edit profile action
                    }) {
                        VStack{
                             Image("edit")
                                 .resizable()           // 이미지 크기 조절 가능하게
                                 .scaledToFit()         // 비율 유지
                                 .frame(width: 18, height: 18) // 원하는 크기

                             Text("Edit profile")
                                 .font(.footnote)
                                 .foregroundColor(.gray)
                         }
                    }
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
                    ProfileRow(icon: "car.fill", title: "나의 구입 매물")
                    ProfileRow(icon: "dollarsign.circle", title: "나의 등록 매물")
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
                
                
                
                // Support Section
                Text("Account")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 0) {
                    ProfileRow(icon: "gearshape", title: "Settings")
                    ProfileRow(icon: "arrow.right.square", title: "Log out")
                    .onTapGesture {
                        viewModel.logout()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
                
                Spacer()
            }
            .onAppear {
                viewModel.fetchUser()
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
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.bottom, 16)
    }
}

#Preview {
    MyPageView()
}
