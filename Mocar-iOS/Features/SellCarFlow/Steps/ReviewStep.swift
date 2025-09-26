//
//  ReviewStep.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct ReviewStep: View {
    @ObservedObject var viewModel: SellCarViewModel
    @State private var isUploading = false   // 업로드 상태 표시
    
    var body: some View {
        VStack {
            Text("입력하신 내용을 확인해주세요.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 16)
            
            // 대표 이미지 (첫 번째 사진이 있으면 그것을 표시)
            if let firstPhoto = viewModel.photos.first {
                Image(uiImage: firstPhoto)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(8)
            } else {
                Image("car-img")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
            }

            
            Spacer()
            VStack(spacing: 12) {
                CarInfoRow(label: "차량 번호", value: viewModel.carNumber)
                CarInfoRow(label: "소유자명", value: viewModel.ownerName)
                CarInfoRow(label: "주행거리", value: viewModel.mileage)
                CarInfoRow(label: "희망가격", value: viewModel.price)
                CarInfoRow(label: "추가정보", value: viewModel.additionalInfo)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            

            // 사진 미리보기
              if !viewModel.photos.isEmpty {
                  ScrollView(.horizontal, showsIndicators: false) {
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
                  .padding(.vertical)
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
                
                Button(action: {
                    isUploading = true
                    viewModel.registerCar { success in
                        isUploading = false
                        if success {
                            viewModel.goNext()  // Complete 화면으로 이동
                        }
                    }
                }) {
                    if isUploading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    } else {
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
        .padding()
    }
}

