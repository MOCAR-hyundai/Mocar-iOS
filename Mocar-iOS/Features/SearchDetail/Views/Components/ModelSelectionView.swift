//
//  ModelSelectionView.swift
//  Mocar-iOS
//
//  Created by wj on 9/19/25.
//

import SwiftUI

struct ModelSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SearchDetailViewModel
    let maker: BrandFilterView.Maker

    private var models: [SearchDetailViewModel.ModelSummary] {
        viewModel.models(for: maker.name)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                Text(maker.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding()
            .background(Color.white)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 0) {
                    if models.isEmpty {
                        Text("등록된 모델이 없습니다.")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(models) { model in
                            NavigationLink {
                                TrimSelectionView(viewModel: viewModel, makerName: maker.name, modelName: model.name)
                            } label: {
                                HStack {
                                    Text(model.name)
                                        .foregroundColor(.black)
                                        .padding(.vertical, 12)
                                    Spacer()
                                    Text("\(model.count)")
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
                            }
                            Divider()
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
