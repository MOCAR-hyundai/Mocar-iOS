//
//  OptionsRow.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

import SwiftUI

struct OptionsRow: View {
    let maker: SearchView.Maker
    
    var body: some View {
        HStack {
            Image(systemName: maker.imageName)
                .resizable()
                .frame(width: 24, height: 24)
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
