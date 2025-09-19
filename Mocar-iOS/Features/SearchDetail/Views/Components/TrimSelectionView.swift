//
//  TrimSelectionView.swift
//  Mocar-iOS
//
//  Created by wj on 9/19/25.
//

import SwiftUI

struct TrimSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SearchDetailViewModel
    let makerName: String
    let modelName: String
    
    private var trims: [String] {
        viewModel.trims(for: makerName, model: modelName)
    }
    
    @State private var tempSelectedTrim: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                Text(modelName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding()
            .background(Color.white)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 0) {
                    if trims.isEmpty {
                        Text("등록된 트림이 없습니다.")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(trims, id: \.self) { trim in
                            Button(action: {
                                tempSelectedTrim = (tempSelectedTrim == trim ? nil : trim)
                            }) {
                                HStack {
                                    if tempSelectedTrim == trim || viewModel.selectedTrim == trim {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.accentColor)
                                    } else {
                                        Image(systemName: "checkmark")
                                            .opacity(0)
                                    }
                                    
                                    Text(trim)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Text("\(viewModel.countForTrim(maker: makerName, model: modelName, trim: trim))")
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                }
            }
            
            Button(action: {
                viewModel.selectedTrim = tempSelectedTrim
                dismiss()
            }) {
                Text("선택 완료")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            .padding(.vertical, 12)
            .background(Color(UIColor.systemBackground))
        }
        .onAppear {
            if viewModel.selectedModel != modelName {
                viewModel.selectModel(modelName, for: makerName)
                viewModel.clearTrims()
            }
            tempSelectedTrim = viewModel.selectedTrim
        }
        .navigationBarBackButtonHidden(true)
    }
}
