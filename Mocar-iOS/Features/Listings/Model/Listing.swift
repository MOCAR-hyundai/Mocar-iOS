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
    var plateNumber: String
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
    
    init(id: String, sellerId: String, plateNumber: String, title: String, brand: String, model: String, trim: String, year: Int, mileage: Int, fuel: String, transmission: String, price: Int, region: String, description: String, images: [String], status: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.sellerId = sellerId
        self.plateNumber = plateNumber
        self.title = title
        self.brand = brand
        self.model = model
        self.trim = trim
        self.year = year
        self.mileage = mileage
        self.fuel = fuel
        self.transmission = transmission
        self.price = price
        self.region = region
        self.description = description
        self.images = images
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Listing {
    static let placeholder = Listing(
        id: "1",
        sellerId: "",
        plateNumber: "",
        title: "로딩중...",
        brand: "",
        model: "",
        trim: "",
        year: 0,
        mileage: 0,
        fuel: "",
        transmission: "",
        price: 0,
        region: "",
        description: "",
        images: [],
        status: "loading",
        createdAt: Date(),
        updatedAt: Date()
    )
}

//Mock
extension Listing {
    static let listingData: [Listing] = [
        Listing(
            id: "11",
            sellerId: "user123",
            plateNumber :"12가1233",
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
            id: "12",
            sellerId: "user456",
            plateNumber :"13바1323",
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
            id: "13",
            sellerId: "user789",
            plateNumber :"42카1928",
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
            id: "14",
            sellerId: "user234",
            plateNumber :"81나1233",
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
            id: "15",
            sellerId: "user567",
            plateNumber :"73아7213",
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
            id: "16",
            sellerId: "user567",
            plateNumber :"34가1133",
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
            id: "17",
            sellerId: "user000",
            plateNumber :"99가4233",
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
        ),
        Listing(
            id: "18",
            sellerId: "user1234",
            plateNumber :"12나0133",
            title: "Ferrari 488 GTB",
            brand: "Ferrari",
            model: "488 GTB",
            trim: "Base",
            year: 2018,
            mileage: 171614,
            fuel: "Gasoline",
            transmission: "Automatic",
            price: 4200,
            region: "서울",
            description: "관리 잘된 페라리 488 GTB 판매합니다.",
            images: ["ferrari1.jpg", "ferrari2.jpg"],
            status: "판매중",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Listing(
            id: "19",
            sellerId: "user4556",
            plateNumber :"02하2233",
            title: "Ferrari 488 GTB",
            brand: "Ferrari",
            model: "488 GTB",
            trim: "Base",
            year: 2018,
            mileage: 171614,
            fuel: "Gasoline",
            transmission: "Automatic",
            price: 5100,
            region: "서울",
            description: "관리 잘된 페라리 488 GTB 판매합니다.",
            images: ["ferrari1.jpg", "ferrari2.jpg"],
            status: "판매중",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Listing(
            id: "20",
            sellerId: "user6789",
            plateNumber :"52차2345",
            title: "Ferrari 488 GTB",
            brand: "Ferrari",
            model: "488 GTB",
            trim: "Base",
            year: 2018,
            mileage: 171614,
            fuel: "Gasoline",
            transmission: "Automatic",
            price: 4000,
            region: "서울",
            description: "관리 잘된 페라리 488 GTB 판매합니다.",
            images: ["ferrari1.jpg", "ferrari2.jpg"],
            status: "판매중",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Listing(
            id: "21",
            sellerId: "user6089",
            plateNumber :"56자2345",
            title: "Ferrari 488 GTB",
            brand: "Ferrari",
            model: "488 GTB",
            trim: "Base",
            year: 2018,
            mileage: 171614,
            fuel: "Gasoline",
            transmission: "Automatic",
            price: 4600,
            region: "서울",
            description: "관리 잘된 페라리 488 GTB 판매합니다.",
            images: ["ferrari1.jpg", "ferrari2.jpg"],
            status: "판매중",
            createdAt: Date(),
            updatedAt: Date()
        )
        
    ]
}
