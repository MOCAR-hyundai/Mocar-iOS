//
//  BrandFilterView.swift
//  Mocar-iOS
//
//  Created by wj on 9/17/25.
//

import SwiftUI

struct BrandView: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("제조사")
                    .font(.headline)
                    .padding(.bottom, 10)

                ForEach(viewModel.brands) { brand in
                    VStack(spacing: 0) {
                        BrandOptionsRow(
                            brand: brand,
                            count: viewModel.count(for: brand.key),
                            isSelected: viewModel.isBrandSelected(brand.key),
                            isExpanded: viewModel.expandedBrandKey == brand.key,
                            onToggleSelection: {
                                viewModel.toggleBrandSelection(brand.key)
                            },
                            onToggleExpansion: {
                                viewModel.toggleBrandExpansion(brand.key)
                            }
                        )

                        if viewModel.expandedBrandKey == brand.key {
                            let models = viewModel.models(for: brand.key)
                            if models.isEmpty {
                                Text("등록된 차종이 없습니다.")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 8)
                                    .padding(.leading, 44)
                            } else {
                                ForEach(models, id: \.self) { model in
                                    BrandModelRow(
                                        model: model,
                                        isSelected: viewModel.isModelSelected(model, for: brand.key),
                                        onToggle: {
                                            viewModel.toggleModelSelection(model, for: brand.key)
                                        }
                                    )
                                }
                            }
                        }

                        Divider()
                    }
                }
            }
            .padding(.top, 20)
            .padding(.horizontal)
        }
    }
}

private struct BrandModelRow: View {
    let model: String
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color.accentColor : Color(.systemGray3))
                Text(model)
                    .foregroundColor(.black)
                Spacer()
            }
            .frame(height: 44)
            .padding(.leading, 32)
        }
        .buttonStyle(.plain)
    }
}
