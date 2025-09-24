//
//  CarImageTabView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/19/25.
//

import SwiftUI

struct CarImageTabView: View {
    let images: [String]
    
    var body: some View {
        GeometryReader { geo in
            TabView {
                ForEach(images, id: \.self) { urlString in
                    if let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: geo.size.width, height: geo.size.width * 3/4) // 3/4 비율
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geo.size.width, height: geo.size.width * 3/4)
                                    .clipped()
                            case .failure:
                                Image(systemName: "이미지없음icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80) // 아이콘 크기 (작게)
                                    .frame(width: 170, height: 125) // 이미지 영역 크기 강제
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .edgesIgnoringSafeArea(.horizontal)
        }
        .frame(height: UIScreen.main.bounds.width * 3/4)
    }
}
