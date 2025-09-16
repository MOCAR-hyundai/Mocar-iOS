//
//  SellCarViewModel.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI

final class SellCarViewModel: ObservableObject {
    @Published var step: SellStep = .carNumber
    
    // 입력 데이터
    @Published var carNumber: String = ""
    @Published var ownerName: String = ""
    @Published var mileage: String = ""
    @Published var price: String = ""
    @Published var additionalInfo: String = ""
    @Published var photos: [UIImage] = []
    
    // Step 이동
    func goNext() {
        if step.rawValue < SellStep.allCases.count - 1 {
            step = SellStep(rawValue: step.rawValue + 1) ?? step
        }
    }
    
    func goBack() {
        if step.rawValue > 0 {
            step = SellStep(rawValue: step.rawValue - 1) ?? step
        }
    }
}
