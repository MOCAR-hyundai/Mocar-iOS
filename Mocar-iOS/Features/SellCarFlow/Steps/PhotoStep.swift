//
//  PhotoStep.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct PhotosStep: View {
    @ObservedObject var viewModel: SellCarViewModel
    @State private var showPicker = false
    
    var body: some View {
        VStack {
            Text("차량사진을 등록해주세요.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 16)
            
            // 사진 스크롤 영역
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.photos, id: \.self) { img in
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    }
                    
                    // 사진 추가 버튼
                    Button(action: { showPicker = true }) {
                        VStack {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.blue)
                            Text("추가")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .frame(width: 100, height: 100)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
            .sheet(isPresented: $showPicker) {
                PhotoPicker(images: $viewModel.photos)
            }
            
            Spacer() 
            
            HStack {
                Button(action: { viewModel.goBack() }) {
                    Text("이전")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                
                Button(action: { viewModel.goNext() }) {
                    Text("다음")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.photos.isEmpty ? Color.blue.opacity(0.5) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(viewModel.photos.isEmpty)
            }
        }
    }
}
