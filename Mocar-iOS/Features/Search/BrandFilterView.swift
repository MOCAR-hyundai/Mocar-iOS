//
//  BrandView.swift
//  Mocar-iOS
//
//  Created by wj on 9/17/25.
//

import SwiftUI

struct BrandView: View {
    struct Maker: Identifiable {
        let id: UUID
        let name: String
        let count: Int
        let imageName: String

        init(summary: SearchViewModel.MakerSummary) {
            id = summary.id
            name = summary.name
            count = summary.count
            imageName = summary.imageName
        }
    }

    @ObservedObject var viewModel: SearchViewModel
    @State private var presentingMaker: Maker?
    @State private var isModelSheetPresented = false
    @State private var isMakerSheetPresented = false
    
    private var makers: [Maker] {
        viewModel.makerSummaries.map(Maker.init)
    }

    private var shouldHideMakerList: Bool {
        viewModel.selectedMaker != nil || viewModel.selectedModel != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if shouldHideMakerList {
                selectionPanel
                    .padding(.top, 16)
                    .padding(.horizontal)
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("제조사")
                            .font(.headline)
                            .padding(.bottom, 12)
                        VStack(spacing: 0) {
                                ForEach(makers) { maker in
                                    let isDisabled = maker.count == 0
                                    Button(action: {
                                        if isDisabled { return }
                                        handleMakerSelection(maker)
                                    }) {
                                        BrandOptionsRow(maker: maker)
                                            .opacity(isDisabled ? 0.5 : 1.0)
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(isDisabled)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
            }
        }
        .sheet(isPresented: $isMakerSheetPresented) {
            MakerSelectionView(
                makers: makers,
                onSelect: { maker in
                    handleMakerSelection(maker)
                }
            )
        }
        .sheet(isPresented: $isModelSheetPresented) {
            if let maker = presentingMaker {
                ModelSelectionView(viewModel: viewModel, maker: maker)
            }
        }
    }

    private var selectionPanel: some View {
        VStack(spacing: 0) {
            selectionRow(
                title: "제조사",
                value: viewModel.selectedMaker,
                placeholder: "선택해 주세요.",
                onClear: viewModel.clearMaker,
                onTap: { isMakerSheetPresented = true }
            )
            Divider()
                .padding(.leading, 16)
            selectionRow(
                title: "모델",
                value: viewModel.selectedModel,
                placeholder: viewModel.selectedMaker == nil ? "제조사를 먼저 선택해 주세요." : "선택해 주세요.",
                onClear: viewModel.clearModel,
                onTap: {
                    guard let makerName = viewModel.selectedMaker,
                          let maker = makers.first(where: { $0.name == makerName }) else {
                        isMakerSheetPresented = true
                        return
                    }
                    presentingMaker = maker
                    isModelSheetPresented = true
                }
            )
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
        )
    }

    private func selectionRow(
        title: String,
        value: String?,
        placeholder: String,
        onClear: @escaping () -> Void,
        onTap: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 16) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
            Spacer()
            if let value = value {
                selectionChip(text: value, onClear: onClear)
            } else {
                Text(placeholder)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }

    private func selectionChip(text: String, onClear: @escaping () -> Void) -> some View {
        Button(action: onClear) {
            HStack(spacing: 4) {
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                Image(systemName: "xmark")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(UIColor.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }

    private func handleMakerSelection(_ maker: Maker) {
        viewModel.selectMaker(maker.name)
        presentingMaker = maker
        isMakerSheetPresented = false
        DispatchQueue.main.async {
            isModelSheetPresented = true
        }
    }
}

struct MakerSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    let makers: [BrandView.Maker]
    let onSelect: (BrandView.Maker) -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("제조사")
                        .font(.headline)
                        .padding(.top, 8)
                    VStack(spacing: 0) {
                        ForEach(makers) { maker in
                            let isDisabled = maker.count == 0
                            Button(action: {
                                if isDisabled { return }
                                onSelect(maker)
                                dismiss()
                            }) {
                                BrandOptionsRow(maker: maker)
                                    .opacity(isDisabled ? 0.5 : 1.0)
                            }
                            .buttonStyle(.plain)
                            .disabled(isDisabled)
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
                .padding(.horizontal)
                .padding(.vertical, 20)
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
                    Text("제조사 선택")
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
    }
}
