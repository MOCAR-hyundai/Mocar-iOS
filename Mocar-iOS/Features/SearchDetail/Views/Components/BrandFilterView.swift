//
//  BrandFilterView.swift
//  Mocar-iOS
//
//  Created by wj on 9/17/25.
//

import SwiftUI

struct BrandFilterView: View {
    struct Maker: Identifiable, Hashable {
        let id: UUID
        let name: String
        let count: Int
        let imageName: UIImage?
        let countryType: String
        
        init(summary: SearchDetailViewModel.MakerSummary) {
            id = summary.id
            name = summary.name
            count = summary.count
            imageName = summary.imageName
            countryType = summary.countryType
        }
    }
    
    @ObservedObject var viewModel: SearchDetailViewModel
    @Binding var path: [SearchDestination]  // SearchView에서 내려받은 path
    
    private var makers: [Maker] {
        viewModel.makerSummaries.map(Maker.init)
    }
    
    private var domesticMakers: [Maker] { makers.filter { $0.countryType == "국산차" } }
    private var importedMakers: [Maker] { makers.filter { $0.countryType == "수입차" } }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.selectedMaker != nil || viewModel.selectedModel != nil {
                selectionPanel
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // 국산차 섹션
                        if !domesticMakers.isEmpty {
                            SectionHeader(title: "국산차")
                            ForEach(domesticMakers) { maker in
                                let isDisabled = maker.count == 0
                                NavigationLink(
                                    value: SearchDestination.model(makerName: maker.name)
                                ) {
                                    BrandOptionsRow(viewModel: viewModel, maker: maker)
                                        .opacity(isDisabled ? 0.5 : 1.0)
                                }
                                .disabled(isDisabled)
                            }
                        }
                        
                        // 수입차 섹션
                        if !importedMakers.isEmpty {
                            SectionHeader(title: "수입차")
                                .padding(.top)
                            ForEach(importedMakers) { maker in
                                let isDisabled = maker.count == 0
                                NavigationLink(
                                    value: SearchDestination.model(makerName: maker.name)
                                ) {
                                    BrandOptionsRow(viewModel: viewModel, maker: maker)
                                        .opacity(isDisabled ? 0.5 : 1.0)
                                }
                                .disabled(isDisabled)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var selectionPanel: some View {
        VStack(spacing: 0) {
            // 제조사
            selectionRow(
                title: "제조사",
                value: viewModel.selectedMaker,
                placeholder: "선택해 주세요.",
                onClear: viewModel.clearMaker
            )
            
            Divider()
            
            // 모델
            NavigationLink(
                value: viewModel.selectedMaker != nil
                ? SearchDestination.model(makerName: viewModel.selectedMaker!)
                : nil
            ) {
                selectionRow(
                    title: "모델",
                    value: viewModel.selectedModel,
                    placeholder: viewModel.selectedMaker == nil
                    ? "제조사를 먼저 선택해 주세요."
                    : "선택해 주세요.",
                    onClear: viewModel.clearModel
                )
            }
            .disabled(viewModel.selectedMaker == nil)
            
            Divider()
            
            // 트림
            NavigationLink(
                value: (viewModel.selectedMaker != nil && viewModel.selectedModel != nil)
                ? SearchDestination.trim(makerName: viewModel.selectedMaker!, modelName: viewModel.selectedModel!)
                : nil
            ) {
                HStack(spacing: 8) {
                    Text("세부 모델")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    Spacer()
                    
                    if viewModel.selectedTrims.isEmpty {
                        Text(viewModel.selectedMaker == nil
                             ? "제조사를 먼저 선택해 주세요."
                             : "선택해 주세요.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    } else {
                        VStack(spacing: 4) {
                            ForEach(Array(viewModel.selectedTrims), id: \.self) { trim in
                                selectionChip(text: trim) {
                                    viewModel.toggleTrim(
                                        trim,
                                        for: viewModel.selectedMaker!,
                                        model: viewModel.selectedModel!
                                    )
                                }
                            }
                        }
                    }
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .padding(.horizontal, 16)
                .contentShape(Rectangle())
            }
            .disabled(viewModel.selectedModel == nil)
        }
    }
    
    private func selectionRow(
        title: String,
        value: String?,
        placeholder: String,
        onClear: @escaping () -> Void
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
        .frame(maxWidth: .infinity, minHeight: 50)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
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
}

private func SectionHeader(title: String) -> some View {
    HStack {
        Text(title)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .font(.footnote)
            .fontWeight(.semibold)
            .background(
                RoundedRectangle(cornerRadius: 50)
                    .stroke(Color.gray, lineWidth: 1)
            )
        Spacer()
    }
    .padding(.top, 20)
}
