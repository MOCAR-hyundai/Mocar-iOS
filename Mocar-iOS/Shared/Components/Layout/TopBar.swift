//
//  TopBar.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import SwiftUI

enum TopBarStyle{
    case home(isLoggedIn: Bool)                             // 로고 + 검색
    case loginSignup                                        // 로그인,회원가입
    case listing(title: String, status: ListingStatus)      // 뒤로가기 + 타이틀
    case MyPage(title: String)                              // 뒤로가기 + 타이틀
    case Mylistings(title: String)                          // 뒤로가기 + 왼쪽 타이틀
    case RestPwd                                            // 뒤로가기 + 왼쪽 로고
    case chat                                               // 뒤로가기 + 채팅방 이름
    case search(title: String)
}

struct TopBar: View {
    let style : TopBarStyle
    var onLoginTap: (() -> Void)? = nil
    
    var body: some View {
        HStack{
            switch style {
            case .home(let isLoggedIn):
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 150)
                
                Spacer()
                if !isLoggedIn {
                    Button("로그인/회원가입") {
                        onLoginTap?()
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.vertical,10)
                }
                
            case .loginSignup:
                HStack(spacing: 0) {
                    BackButton()
                        .padding(.leading, 5)
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 150)
                        .frame(height: 30)
                        .padding(.leading, -23)
                    Spacer()
                }
                
            case .listing(title: let title, status: let status):
                HStack {
                    BackButton()
                    Spacer()
                    Text(title)
                    Spacer()
                    Text(status.displayText)
                        .font(.system(size: 14))
                        .foregroundColor(status.displayColor)
                        .padding(.trailing,10)
                    
                }
            case .MyPage(title: let title):
                HStack {
                    Spacer()
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .padding(.vertical,5)
                    Spacer()
                }
            case .Mylistings(title: let title):
                HStack {
                    BackButton()
                        .padding(.leading, 5)
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .default))
                    Spacer()
                }
                
            case .RestPwd:
                ZStack{
                    BackButton()
                        .padding(.leading, 3)
                    HStack {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 150)
                            .padding(.leading, 40)
                        Spacer()
                        
                    }
                    
                }
            case .chat:
                HStack{
                    BackButton()
                }
            case .search(title: let title):
                HStack {
                    BackButton()
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .default))
                    Spacer()
//                    if let onHomeTap = onHomeTap {
//                        Button(action: { onHomeTap() }) {
//                            Image("House")
//                                .font(.system(size: 18))
//                                .foregroundColor(.black)
//                                .frame(width: 36, height: 36)
//                                .padding(.vertical, 5)
//                        }
//                    }
                }
                
                
            }
            //.padding(.horizontal, 16)   // 좌우 여백
        }
    }
}

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack{
            Button(action:{
                dismiss()
            }){
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 36, height: 36)
            }
        }
    }
}

//#Preview {
//    Image(systemName: "chevron.right")
//}
