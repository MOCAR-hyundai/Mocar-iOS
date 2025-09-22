//
//  TopBar.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import SwiftUI

enum TopBarStyle{
    case home(isLoggedIn: Bool)                 // 로고 + 검색
    case login                   // 로그인
    case singup                  //회원가입
    case listing(title: String)     // 뒤로가기 + 타이틀
    case MyPage(title: String)      // 뒤로가기 + 타이틀
    case Mylistings(title: String)  // 뒤로가기 + 왼쪽 타이틀
    //case chat(title: String)   // 뒤로가기 + 채팅방 이름
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
                
            case .login:
                BackButton()
            case .singup:
                BackButton()
            case .listing(title: let title):
                ZStack{
                    HStack {
                        BackButton()
                        Spacer()
                    }
                    Text(title)
                }
            case .MyPage(title: let title):
                ZStack{
                    HStack {
                        BackButton()
                            .padding(.leading, 5)
                        Spacer()
                    }
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .default))
                }
                
            case .Mylistings(title: let title):
                ZStack{
                    BackButton()
                        .padding(.leading, 5)
                    HStack {
                        Text(title)
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .padding(.leading, 45)
                        Spacer()
                        
                    }
                }
//                ZStack{
//                    HStack {
//                        BackButton()
//                            .padding(.leading, 5)
//                        Spacer()
//                    }
//                    Text(title)
//                        .font(.system(size: 18, weight: .semibold, design: .default))
//                }
                
            
            }
        }
        //.padding(.horizontal, 16)   // 좌우 여백
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
            Spacer()
        }
    }
}

#Preview {
    BackButton()
}
