//
//  CarOwnerNameView.swift
//  Mocar-iOS
//
//  Created by wj on 9/15/25.
//

import SwiftUI

struct CarOwnerNameView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Text("소유자명을 입력해주세요!")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 16)
                TextField("홍길동", text: .constant(""))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 2)
                    )
                
                HStack(spacing: 16) {
                    Button(action: {
                        dismiss()
                    }
                    ) {
                        Text("이전")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                    
                    NavigationLink (destination: CarInfoView()) {
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
    CarOwnerNameView()
}
