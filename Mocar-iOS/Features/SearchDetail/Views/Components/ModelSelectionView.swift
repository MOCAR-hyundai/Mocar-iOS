//
//  ModelSelectionView.swift
//  Mocar-iOS
//
//  Created by wj on 9/19/25.
//

import SwiftUI

struct ModelSelectionView: View {
    @ObservedObject var viewModel: SearchDetailViewModel
    let makerName: String
    var onCancel: (() -> Void)? = nil   // BrandFilter로 직행 콜백

    private var models: [SearchDetailViewModel.ModelSummary] {
        viewModel.models(for: makerName)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    viewModel.selectedMaker = makerName
                    onCancel?()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }

                Text(makerName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)

                Spacer()

                Button(action: {
                    viewModel.selectedMaker = makerName
                    onCancel?()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
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
                            let isDisabled = model.count == 0
                            let textColor: Color = isDisabled ? .gray : .black

                            NavigationLink(
                                value: SearchDestination.trim(
                                    makerName: makerName,
                                    modelName: model.name
                                )
                            ) {
                                HStack {
                                    Text(model.name)
                                        .foregroundColor(textColor)
                                        .padding(.vertical, 16)
                                    Spacer()
                                    Text("\(model.count)대")
                                        .foregroundColor(.gray)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
                            }
                            .disabled(isDisabled)
                            Divider()
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // ViewModel.selectedMaker가 nil이면 현재 makerName으로 초기화
            if viewModel.selectedMaker == nil {
                viewModel.selectedMaker = makerName
            }
        }
    }
}
