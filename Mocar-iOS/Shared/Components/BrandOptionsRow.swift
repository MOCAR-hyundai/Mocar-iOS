//
//  OptionsRow.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct BrandOptionsRow: View {
    let maker: BrandView.Maker
    
    var body: some View {
        HStack {
            Image(maker.imageName)
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(.gray)
            
            Text(maker.name)
                .foregroundColor(.black)
            
            Spacer()
            
            Text("\(maker.count)")
                .foregroundColor(.gray)
                .font(.subheadline)
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .frame(height: 50)
        Divider()
    }
}
