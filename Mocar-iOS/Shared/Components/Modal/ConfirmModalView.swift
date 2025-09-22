//
//  ConfirmModalView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct ConfirmModalView: View {
    let message: String
    let confirmTitle: String
    let cancelTitle: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20){
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(30)
            HStack(spacing: 12) {
                Button(action: {onCancel()}){
                    Text(cancelTitle)
                        .foregroundColor(.pureWhite)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.borderGray)
                        .cornerRadius(8)
                }
                Button(action: {onConfirm()}){
                    Text(confirmTitle)
                        .foregroundColor(.pureWhite)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.keyColorBlue)
                        .cornerRadius(8)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 40)
        
        
    }
}

#Preview {
    ZStack{
        Color.keyColorDarkGray
        .ignoresSafeArea()
        ConfirmModalView(
            message: "로그인 이후 사용가능합니다.", confirmTitle: "로그인", cancelTitle: "취소", onConfirm: {print("로그인 버튼 눌림")}, onCancel: {print("취소 버튼 눌림")}
        )
    }
    
}
