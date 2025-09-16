//
//  CarNumberView.swift
//  Mocar-iOS
//
//  Created by wj on 9/15/25.
//

import SwiftUI

struct CarNumberView: View {
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("내 차,\n시세를 알아볼까요?")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 16)
                TextField("12가1234", text: .constant(""))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 2)
                    )
                
                HStack(spacing: 16) {
                    Button(action: {}
                    ) {
                        Text("이전")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                    
                    
                    NavigationLink(destination: CarOwnerNameView()) {
                        Text("다음")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    CarNumberView()
}
