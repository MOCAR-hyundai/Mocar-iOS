//
//  LeftCategoryView.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct LeftCategoryView: View {
    let categories: [String]
    @Binding var selectedCategory: String?
    var hasSelection: (String) -> Bool = { _ in false }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(categories, id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                }) {
                    ZStack {
                        Text(category)
                            .fontWeight(selectedCategory == category ? .bold : .regular)
                            .foregroundColor(selectedCategory == category ? .black : .gray)
                            .frame(maxWidth: .infinity)
                        HStack {
                            Spacer(minLength: 4)
                            if hasSelection(category) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.footnote)
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                        selectedCategory == category ? Color.white : Color(UIColor.systemGray6)
                    )
                }
                .contentShape(Rectangle())
            }
            Spacer()
        }
        .frame(width: 100)
        .background(Color(UIColor.systemGray6))
    }
}
