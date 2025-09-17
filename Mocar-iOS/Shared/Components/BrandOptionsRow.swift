//
//  BrandOptionsRow.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct BrandOptionsRow: View {
    let brand: SearchViewModel.BrandInfo
    let count: Int
    let isSelected: Bool
    let isExpanded: Bool
    let onToggleSelection: () -> Void
    let onToggleExpansion: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggleSelection) {
                HStack(spacing: 12) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? Color.accentColor : Color(.systemGray3))

                    if let imageName = brand.imageName {
                        Image(imageName)
                            .resizable()
                            .frame(width: 28, height: 28)
                    }

                    Text(brand.displayName)
                        .foregroundColor(.black)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Text("\(count)")
                .foregroundColor(.gray)
                .font(.subheadline)

            Button(action: onToggleExpansion) {
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .foregroundColor(.gray)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 50)
    }
}
