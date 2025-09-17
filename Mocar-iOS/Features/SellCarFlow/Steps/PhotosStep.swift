//
//  PhotoStep.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI
import PhotosUI

struct PhotosStep: View {
    @ObservedObject var viewModel: SellCarViewModel
    @State private var showPicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        VStack {
            Text("차량사진을 등록해주세요.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 16)
            
            // 상단 큰 프리뷰
            if let selected = selectedImage ?? viewModel.photos.first {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: selected)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(height: 250) // 고정 크기
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .clipped()
                }
                .padding(.bottom, 16)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .overlay(Text("사진을 추가해주세요").foregroundColor(.gray))
                    .padding(.bottom, 16)
            }
            
            // 하단 사진 스크롤 영역
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.photos.enumerated()), id: \.element) { index, img in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(8)
                                .onTapGesture {
                                    selectedImage = img
                                }
                            
                            // 삭제 버튼
                            Button(action: {
                                let removed = viewModel.photos[index]
                                viewModel.photos.remove(at: index)
                                
                                // 프리뷰 이미지가 삭제된 경우 처리
                                if selectedImage == removed {
                                    if let first = viewModel.photos.first {
                                        selectedImage = first
                                    } else {
                                        selectedImage = nil
                                    }
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            .offset(x: -5, y: 5)
                        }
                    }
                    
                    // 사진 추가 버튼 (최대 5장)
                    if viewModel.photos.count < 5 {
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
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
            .sheet(isPresented: $showPicker) {
                PhotoPicker(images: $viewModel.photos) { newImages in
                    let total = viewModel.photos + newImages
                    if total.count > 5 {
                        alertMessage = "사진은 최대 5장까지 첨부 가능합니다."
                        showAlert = true
                    } else {
                        viewModel.photos = total
                        // 새로 추가된 사진 중 첫 번째를 선택
                        selectedImage = newImages.first ?? selectedImage
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("사진 제한"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
            }
            
            Spacer()
            
            // 이전 / 다음 버튼
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
