//
//  OptionsRow.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct BrandOptionsRow: View {
    @ObservedObject var viewModel: SearchDetailViewModel
    let maker: BrandFilterView.Maker
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                if let uiImage = viewModel.makerImages[maker.name] {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Color.gray.opacity(0.3)
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(maker.name)
                        .foregroundColor(.black)
                    Text(maker.countryType) // 국산차/수입차 표시
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("\(maker.count)")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            Divider()
        }
        .contentShape(Rectangle())
    }
}
