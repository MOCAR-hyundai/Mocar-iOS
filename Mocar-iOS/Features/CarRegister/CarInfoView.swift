//
//  CarInfoView.swift
//  Mocar-iOS
//
//  Created by wj on 9/15/25.
//

import SwiftUI

struct CarInfoView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Text("차량 정보")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 16)
                
                Image("car-img")
                
                Text("현대 싼타페 CM 2WD(2.0 VGT) CLX 고급형")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("차량 번호")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("12가1234")
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("모델명")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("현대 싼타페 CM 2WD(2.0 VGT) CLX 고급형")
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("연식")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("2015년식")
                            .font(.caption)
                    }
                    
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
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
                    
                    NavigationLink(destination: ContentView()) {
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
    CarInfoView()
}
