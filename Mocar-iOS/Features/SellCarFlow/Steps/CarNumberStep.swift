//
//  CarNumberStep.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct CarNumberStep: View {
    @ObservedObject var viewModel: SellCarViewModel
    
    var body: some View {
        VStack {
            Spacer()
            Text("내 차,\n시세를 알아볼까요?")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 16)
            TextField("12가 1234", text: $viewModel.carNumber)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 2)
                )
            
            Spacer()
            
            Button(action: { viewModel.goNext() }) {
                Text("다음")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.carNumber.isEmpty ? Color.blue.opacity(0.5) : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(viewModel.carNumber.isEmpty)
        }
    }
}
