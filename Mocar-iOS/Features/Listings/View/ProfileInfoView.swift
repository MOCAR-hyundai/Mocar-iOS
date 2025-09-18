//
//  ProfileInfoView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct ProfileInfoView: View {
    var body: some View {
        VStack{
            HStack(spacing: 12){
                Image("짱구")
                    .resizable()
                    .clipShape(Circle())
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                
                Text("Hela Quintin")
                Spacer()
                
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background(Color.white) // 배경색
            .cornerRadius(12) // 모서리 둥글게
        }
    }
}

#Preview {
    ProfileInfoView()
}
