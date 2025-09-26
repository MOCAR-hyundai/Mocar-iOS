//
//  ProfileInfoView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct ProfileInfoView: View {
    let seller: User?
    
    init(seller: User?) {
        self.seller = seller
        if let seller = seller {
            print(" ProfileInfoView photoUrl:", seller.photoUrl)
        } else {
            print("seller is nil")
        }
    }
    
    var body: some View {
        VStack{
            HStack(spacing: 12){
                if let seller = seller {
                    // 프로필 이미지
                    AsyncImage(url: URL(string: seller.photoUrl)) { img in
                        img.resizable()
                            .clipShape(Circle())
                            .scaledToFill()
                        
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 42, height: 42)
                    
                    // 이름
                    Text(seller.name)
                        .font(.headline)
                } else {
                    // 데이터가 없을 경우 (로딩/에러)
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 42, height: 42)
                    Text("알 수 없음")
                        .foregroundColor(.gray)
                }
                Spacer()
                
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background(Color.white) // 배경색
            .cornerRadius(12) // 모서리 둥글게
        }
    }
}

