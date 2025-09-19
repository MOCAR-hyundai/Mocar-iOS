//
//  SearchViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import Foundation

class SearchViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    
    init() {
        //loadDummyData()
    }
    
//    func loadDummyData() {
//        listings = [
//            Listing(
//                id: "11",
//                sellerId: "user_001",
//                plateNumber :"12가1233",
//                title: "Ferrari-FF",
//                brand: "Ferrari",
//                model: "FF",
//                trim: "",
//                year: 2023,
//                mileage: 23214,
//                fuel: "하이브리드",
//                transmission: "AT",
//                price: 138600000,
//                region: "경기",
//                description: "23년식, 하이브리드, 무사고 차량",
//                images: ["Carresult2"],
//                status: "on_sale",
//                createdAt: Date(),
//                updatedAt: Date()
//            ),
//            Listing(
//                id: "12",
//                sellerId: "user_002",
//                plateNumber :"12가1233",
//                title: "현대 더 올 뉴 그랜저 2.5 가솔린",
//                brand: "Hyundai",
//                model: "Grandeur",
//                trim: "2.5 Premium",
//                year: 2023,
//                mileage: 23214,
//                fuel: "가솔린",
//                transmission: "AT",
//                price: 43530000,
//                region: "경기",
//                description: "무사고, 1인 신조, 실주행거리 2만km",
//                images: ["Carresult1"],
//                status: "on_sale",
//                createdAt: Date(),
//                updatedAt: Date()
//            ),
//            Listing(
//                id: "13",
//                sellerId: "user_003",
//                plateNumber :"12가1233",
//                title: "현대 더 올 뉴 그랜저 2.5 가솔린",
//                brand: "Hyundai",
//                model: "Grandeur",
//                trim: "2.5 Premium",
//                year: 2023,
//                mileage: 23214,
//                fuel: "가솔린",
//                transmission: "AT",
//                price: 43530000,
//                region: "경기",
//                description: "실내 상태 우수, 정기점검 완료",
//                images: ["Carresult1"],
//                status: "on_sale",
//                createdAt: Date(),
//                updatedAt: Date()
//            )
//        ]
//    }
}
