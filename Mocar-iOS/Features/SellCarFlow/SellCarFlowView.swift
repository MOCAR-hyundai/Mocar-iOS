//
//  SellCarFlowView.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

struct SellCarFlowView: View {
    @StateObject private var viewModel = SellCarViewModel()
    
    var body: some View {
        VStack {
            ProgressView(value: Double(viewModel.step.rawValue + 1),
                         total: Double(SellStep.allCases.count))
                .padding()
                .animation(.easeInOut, value: viewModel.step)
            
            Text(viewModel.step.title)
                .font(.headline)
                .padding(.bottom, 8)
            
            Spacer()
            
            switch viewModel.step {
            case .carNumber: CarNumberStep(viewModel: viewModel)
            case .ownerName: OwnerNameStep(viewModel: viewModel)
            case .carInfo: CarInfoStep(viewModel: viewModel)
            case .mileage: MileageStep(viewModel: viewModel)
            case .price: PriceStep(viewModel: viewModel)
            case .additional: AdditionalStep(viewModel: viewModel)
            case .photos: PhotosStep(viewModel: viewModel)
            case .review: ReviewStep(viewModel: viewModel)
            case .complete: CompleteStep(viewModel: viewModel)
            }
            
            Spacer()
        }
        .padding()
    }
}
