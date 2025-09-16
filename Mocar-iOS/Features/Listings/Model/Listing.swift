//
//  Listing.swift
//  Mocar-iOS
//
//  Created by Admin on 9/15/25.
//

import Foundation

struct ListingStats: Codable {
    //var viewCount: Int
    var favoriteCount: Int      //찜 횟수
}

struct Listing : Identifiable, Codable{
    var id: String
    var sellerId: String
    var title: String
    var brand: String
    var model: String
    var trim: String
    var year: Int
    var mileage: Int
    var fuel: String
    var transmission: String
    var price: Int
    var region: String
    var description: String
    var images: [String]
    var status: String
    //var stats: ListingStats
    var createdAt: Date
    var updatedAt: Date
}

//Mock
extension Listing {
    static let listingData: [Listing] = [
        Listing(
            id: "1",
            sellerId: "user123",
            title: "Ferrari 488 GTB",
            brand: "Ferrari",
            model: "488 GTB",
            trim: "Base",
            year: 2018,
            mileage: 171614,
            fuel: "Gasoline",
            transmission: "Automatic",
            price: 4700,
            region: "서울",
            description: "관리 잘된 페라리 488 GTB 판매합니다.",
            images: ["ferrari1.jpg", "ferrari2.jpg"],
            status: "판매중",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Listing(
            id: "2",
            sellerId: "user456",
            title: "BMW M3",
            brand: "BMW",
            model: "M3",
            trim: "Competition",
            year: 2020,
            mileage: 85000,
            fuel: "Gasoline",
            transmission: "Manual",
            price: 3200,
            region: "부산",
            description: "부산에서 판매중인 BMW M3. 주행거리 짧고 상태 좋습니다.",
            images: ["bmw1.jpg"],
            status: "예약중",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Listing(
            id: "3",
            sellerId: "user789",
            title: "Hyundai Sonata",
            brand: "Hyundai",
            model: "Sonata",
            trim: "Premium",
            year: 2019,
            mileage: 42000,
            fuel: "Gasoline",
            transmission: "Automatic",
            price: 1800,
            region: "인천",
            description: "실내/외관 깨끗한 소나타. 첫 차로 적합합니다.",
            images: ["sonata1.jpg"],
            status: "판매중",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Listing(
            id: "4",
            sellerId: "user234",
            title: "Audi A6",
            brand: "Audi",
            model: "A6",
            trim: "Luxury",
            year: 2021,
            mileage: 30000,
            fuel: "Diesel",
            transmission: "Automatic",
            price: 550,
            region: "대구",
            description: "신차급 아우디 A6 디젤 차량. 실매물 보장.",
            images: ["audi1.jpg", "audi2.jpg"],
            status: "판매중",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Listing(
            id: "5",
            sellerId: "user567",
            title: "Tesla Model 3",
            brand: "Tesla",
            model: "Model 3",
            trim: "Long Range",
            year: 2022,
            mileage: 12000,
            fuel: "Electric",
            transmission: "Automatic",
            price: 6800,
            region: "광주",
            description: "테슬라 모델 3 롱레인지. 완전 무사고 차량.",
            images: ["tesla1.jpg"],
            status: "판매완료",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Listing(
            id: "6",
            sellerId: "user567",
            title: "Tesla Model 1",
            brand: "Tesla",
            model: "Model 3",
            trim: "Long Range",
            year: 2020,
            mileage: 12000,
            fuel: "Electric",
            transmission: "Automatic",
            price: 8800,
            region: "광주",
            description: "테슬라 모델 1 롱레인지. 완전 무사고 차량.",
            images: ["tesla1.jpg"],
            status: "판매완료",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Listing(
            id: "7",
            sellerId: "user567",
            title: "Tesla Model 3",
            brand: "Tesla",
            model: "Model 3",
            trim: "Long Range",
            year: 2021,
            mileage: 12000,
            fuel: "Electric",
            transmission: "Automatic",
            price: 6800,
            region: "광주",
            description: "테슬라 모델 3 롱레인지. 완전 무사고 차량.",
            images: ["tesla1.jpg"],
            status: "판매완료",
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
}
