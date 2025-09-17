//
//  LeftCategoryView.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct LeftCategoryView: View {
    let categories: [SearchCategory]
    @Binding var selectedCategory: SearchCategory

    var body: some View {
        VStack(spacing: 0) {
            ForEach(categories) { category in
                Button(action: {
                    selectedCategory = category
                }) {
                    Text(category.title)
                        .fontWeight(selectedCategory == category ? .bold : .regular)
                        .foregroundColor(selectedCategory == category ? .black : .gray)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(
                            selectedCategory == category ? Color.white : Color(UIColor.systemGray6)
                        )
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            Spacer()
        }
        .frame(width: 100)
        .background(Color(UIColor.systemGray6))
    }
}
