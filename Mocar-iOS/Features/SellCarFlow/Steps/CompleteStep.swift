//
//  CompleteStep.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct CompleteStep: View {
    @ObservedObject var viewModel: SellCarViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
            
            Text("차량 등록이 완료되었습니다!")
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {
                viewModel.step = .carNumber   // 첫 단계로 이동
                viewModel.carNumber = ""
                viewModel.ownerName = ""
                viewModel.mileage = ""
                viewModel.price = ""
                viewModel.additionalInfo = ""
                viewModel.photos = []
            }
            ) {
                Text("처음으로")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}
