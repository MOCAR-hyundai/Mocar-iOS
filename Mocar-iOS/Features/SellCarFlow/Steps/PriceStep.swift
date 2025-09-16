//
//  PriceStep.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct PriceStep: View {
    @ObservedObject var viewModel: SellCarViewModel
    
    var body: some View {
        VStack {
            Spacer()
            Text("판매가격을 입력해주세요.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 16)
            TextField("예: 12,000,000(원)", text: $viewModel.price)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 2)
                    )
                .keyboardType(.numberPad)
            
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
                        .background(viewModel.price.isEmpty ? Color.blue.opacity(0.5) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(viewModel.price.isEmpty)
            }
        }
    }
}
