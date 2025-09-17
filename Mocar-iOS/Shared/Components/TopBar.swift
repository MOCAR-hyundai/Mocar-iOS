//
//  TopBar.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import SwiftUI

enum TopBarStyle{
    case home                   // 로고 + 검색
    case login                   // 로그인
    case singup                  //회원가입
    case listing(title: String) // 뒤로가기 + 타이틀
    //case chat(title: String)   // 뒤로가기 + 채팅방 이름
}

struct TopBar: View {
    let style : TopBarStyle

    
    var body: some View {
        HStack{
            switch style {
            case .home:
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 150)
                Spacer()
                
            case .login:
                Image("logo")
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
                
            }
        }
        .padding(.horizontal, 16)   // 좌우 여백
    }
}

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button(action:{
            dismiss()
        }){
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)
                .frame(width: 36, height: 36)
                .background(Circle().stroke(Color.gray.opacity(0.5)))
        }
    }
}

#Preview {
    TopBar(style: .home)
        
}
