//
//  CarInfoStep.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct CarInfoStep: View {
    @ObservedObject var viewModel: SellCarViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("차량 정보")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 16)
            
            if !viewModel.firstImageUrl.isEmpty {
                AsyncImage(url: URL(string: viewModel.firstImageUrl)) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(height: 150)
                } placeholder: {
                    ProgressView()
                }
            }
                        
            Text(viewModel.title)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            VStack {
                CarInfoRow(label: "차량 번호", value: viewModel.carNumber)
                
                CarInfoRow(label: "모델명", value: viewModel.title)
                CarInfoRow(label: "연식", value: viewModel.year)
                // 수정 필요
//                CarInfoRow(label: "모델명", value: "현대 싼타페 CM 2WD(2.0 VGT) CLX 고급형")
//                CarInfoRow(label: "연식", value: "2015년식")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            
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
                    Text("다음")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(viewModel.ownerName.isEmpty)
            }
        }
        .onAppear {
            viewModel.fetchCarInfo()
        }
    }
}
