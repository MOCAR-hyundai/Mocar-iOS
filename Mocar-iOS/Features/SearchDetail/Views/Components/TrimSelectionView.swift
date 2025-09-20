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
    
    private var results: [SearchCar] {
        viewModel.searchCarsTrim(maker: makerName, model: modelName)
    }
    
    private var groupedResults: [String: [SearchCar]] {
        Dictionary(grouping: results, by: { $0.title })
    }
    
    @State private var tempSelectedTrims: Set<String> = []
    
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
                    if results.isEmpty {
                        Text("등록된 트림이 없습니다.")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(groupedResults.keys.sorted(), id: \.self) { title in
                            if let cars = groupedResults[title], let car = cars.first {
                                Button(action: {
                                    if tempSelectedTrims.contains(title) {
                                        tempSelectedTrims.remove(title)
                                    } else {
                                        tempSelectedTrims.insert(title)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: tempSelectedTrims.contains(title) ? "checkmark.square.fill" : "square")
                                            .foregroundColor(tempSelectedTrims.contains(title) ? .blue : .gray)
                                        VStack(alignment: .leading , spacing: 4) {
                                            Text(title)
                                                .foregroundColor(.black)
                                            
                                            Text("연식 \(car.year)년")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Text("\(cars.count)대")
                                        
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
            }
            
            Button(action: {
                viewModel.selectedTrims = tempSelectedTrims
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
            tempSelectedTrims = Set(viewModel.selectedTrims)
        }
        .navigationBarBackButtonHidden(true)
    }
}
