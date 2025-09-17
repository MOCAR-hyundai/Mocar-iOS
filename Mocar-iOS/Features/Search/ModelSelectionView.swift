//
//  ModelSelectionView.swift
//  Mocar-iOS
//
//  Created by Codex on 9/19/25.
//

import SwiftUI

struct ModelSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SearchViewModel
    let maker: BrandView.Maker
    
    private var models: [SearchViewModel.ModelSummary] {
        viewModel.models(for: maker.name)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        breadcrumb
                        modelSection(title: "모델", models: models)
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
                    .padding(.bottom, 12)
                }
                Divider()
                Button(action: {
                    viewModel.selectMaker(maker.name)
                    dismiss()
                }) {
                    Text("선택")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black)
                        )
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(maker.name)
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .onAppear {
            viewModel.selectMaker(maker.name)
        }
    }
    
    private var breadcrumb: some View {
        HStack(spacing: 8) {
            breadcrumbChip("제조사", isActive: true)
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(.gray)
            breadcrumbChip("모델", isActive: viewModel.selectedModel != nil)
        }
    }
    
    private func breadcrumbChip(_ title: String, isActive: Bool) -> some View {
        Text(title)
            .font(.footnote)
            .foregroundColor(isActive ? .black : .gray)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                Capsule()
                    .fill(isActive ? Color(UIColor.systemGray5) : Color(UIColor.systemGray6))
            )
    }
    
    private func modelSection(title: String, models: [SearchViewModel.ModelSummary]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title)
            if models.isEmpty {
                Text("선택 가능한 모델이 없습니다.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.vertical, 24)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(models.enumerated()), id: \.element.id) { index, model in
                        let isSelected = viewModel.selectedModel == model.name
                        let isDisabled = model.count == 0
                        Button(action: {
                            if isDisabled { return }
                            viewModel.selectModel(model.name, for: maker.name)
                        }) {
                            HStack(spacing: 12) {
                                Text(model.name)
                                    .foregroundColor(isDisabled ? .gray : .black)
                                    .font(.body)
                                Spacer()
                                Text(formattedCount(model.count))
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(isSelected ? Color(UIColor.systemGray6) : Color.white)
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                        .disabled(isDisabled)
                        .opacity(isDisabled ? 0.5 : 1.0)
                        if index < models.count - 1 {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                )
            }
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.gray)
            .padding(.vertical, 4)
    }
    
    private func formattedCount(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
