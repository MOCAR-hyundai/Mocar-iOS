//
//  ReviewStep.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct ReviewStep: View {
    @ObservedObject var viewModel: SellCarViewModel
    
    var body: some View {
        VStack {
            Text("입력하신 내용을 확인해주세요.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 16)
            
            // 수정 필요
            Image("car-img")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
            
            Spacer()
            VStack(spacing: 12) {
                CarInfoRow(label: "차량 번호", value: viewModel.carNumber)
                CarInfoRow(label: "소유자명", value: viewModel.ownerName)
                CarInfoRow(label: "주행거리", value: viewModel.mileage)
                CarInfoRow(label: "희망가격", value: viewModel.price)
                CarInfoRow(label: "추가정보", value: viewModel.additionalInfo)}
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.photos, id: \.self) { img in
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(8)
                    }
                }
            }
            
            Spacer()
            
            HStack {
                Button(action: { viewModel.goBack() }
                ) {
                    Text("이전")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                
                Button(action: { viewModel.goNext() }
                ) {
                    Text("등록")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }
}

