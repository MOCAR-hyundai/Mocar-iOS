//
//  DescriptionStep.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct AdditionalStep: View {
    @ObservedObject var viewModel: SellCarViewModel
    
    var body: some View {
        VStack {
            Spacer()
            Text("추가정보를 입력해주세요.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 16)
            TextEditor(text: $viewModel.additionalInfo)
                .padding(8) // 내부 여백
                .frame(height: 150) // 원하는 높이
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 2)
                )
                .multilineTextAlignment(.leading)
            
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
                .disabled(viewModel.additionalInfo.isEmpty)
            }
        }
    }
}

