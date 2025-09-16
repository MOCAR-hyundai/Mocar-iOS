//
//  SellStep.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import Foundation

enum SellStep: Int, CaseIterable {
    case carNumber
    case ownerName
    case carInfo
    case mileage
    case price
    case additional
    case photos
    case review
    case complete

    var title: String {
        switch self {
        case .carNumber: return "차량 번호 입력"
        case .ownerName: return "소유자명 입력"
        case .carInfo: return "차량 정보 확인"
        case .mileage: return "주행 거리 입력"
        case .price: return "희망 가격 입력"
        case .additional: return "추가 정보 입력"
        case .photos: return "차량 사진 등록"
        case .review: return "입력 내용 검토"
        case .complete: return "완료"
        }
    }
}
