//
//  OptionsRow.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct BrandOptionsRow: View {
    let maker: BrandFilterView.Maker
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(maker.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                
                Text(maker.name)
                    .foregroundColor(.black)
                
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
