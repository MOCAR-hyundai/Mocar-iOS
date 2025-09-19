//
//  AreaFilterView.swift
//  Mocar-iOS
//
//  Created by wj on 9/18/25.
//

import Foundation

struct SearchCar: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let maker: String
    let model: String
    let trim: String
    let category: String
    let fuel: String
    let area: String
    let year: Int
    let price: Int
    let mileage: Int
}

enum SearchMockData {
    private struct CarSeed {
        let maker: String
        let model: String
        let category: String
        let fuels: [String]
        let basePrice: Int
        let priceStep: Int
        let baseMileage: Int
        let mileageStep: Int
    }
    
    private static let variantYears = [2024, 2023, 2022, 2021, 2020]
    private static let areas = [
        "서울", "부산", "인천", "대구", "대전", "광주", "울산", "세종",
        "경기", "강원", "경남", "경북", "전남", "전북", "충남", "충북", "제주"
    ]
    
    private static let seeds: [CarSeed] = [
        CarSeed(maker: "현대", model: "그랜저", category: "대형", fuels: ["가솔린(휘발유)", "하이브리드", "LPG"], basePrice: 5200, priceStep: 220, baseMileage: 15000, mileageStep: 17000),
        CarSeed(maker: "현대", model: "쏘나타", category: "중형", fuels: ["가솔린(휘발유)", "하이브리드"], basePrice: 3600, priceStep: 180, baseMileage: 12000, mileageStep: 15000),
        CarSeed(maker: "현대", model: "아반떼", category: "준중형", fuels: ["가솔린(휘발유)", "LPG"], basePrice: 2800, priceStep: 160, baseMileage: 9000, mileageStep: 14000),
        CarSeed(maker: "현대", model: "팰리세이드", category: "SUV", fuels: ["가솔린(휘발유)", "디젤(경유)", "하이브리드"], basePrice: 6400, priceStep: 260, baseMileage: 18000, mileageStep: 16000),
        CarSeed(maker: "현대", model: "투싼", category: "SUV", fuels: ["디젤(경유)", "가솔린(휘발유)", "하이브리드"], basePrice: 4200, priceStep: 200, baseMileage: 14000, mileageStep: 15000),
        CarSeed(maker: "기아", model: "K5", category: "중형", fuels: ["가솔린(휘발유)", "하이브리드"], basePrice: 3500, priceStep: 170, baseMileage: 11000, mileageStep: 14000),
        CarSeed(maker: "기아", model: "쏘렌토", category: "SUV", fuels: ["디젤(경유)", "가솔린(휘발유)", "하이브리드"], basePrice: 5400, priceStep: 210, baseMileage: 16000, mileageStep: 18000),
        CarSeed(maker: "기아", model: "모닝", category: "경차", fuels: ["가솔린(휘발유)", "LPG"], basePrice: 1900, priceStep: 140, baseMileage: 8000, mileageStep: 12000),
        CarSeed(maker: "기아", model: "카니발", category: "RV", fuels: ["디젤(경유)", "가솔린(휘발유)", "하이브리드"], basePrice: 5800, priceStep: 240, baseMileage: 17000, mileageStep: 19000),
        CarSeed(maker: "기아", model: "EV6", category: "SUV", fuels: ["전기"], basePrice: 6200, priceStep: 200, baseMileage: 5000, mileageStep: 12000),
        CarSeed(maker: "제네시스", model: "G80", category: "대형", fuels: ["가솔린(휘발유)", "하이브리드"], basePrice: 6800, priceStep: 240, baseMileage: 13000, mileageStep: 16000),
        CarSeed(maker: "제네시스", model: "G70", category: "스포츠카", fuels: ["가솔린(휘발유)", "디젤(경유)"], basePrice: 5400, priceStep: 220, baseMileage: 12000, mileageStep: 15000),
        CarSeed(maker: "제네시스", model: "GV70", category: "SUV", fuels: ["가솔린(휘발유)", "디젤(경유)", "하이브리드"], basePrice: 6600, priceStep: 230, baseMileage: 15000, mileageStep: 17000),
        CarSeed(maker: "르노코리아", model: "QM6", category: "SUV", fuels: ["디젤(경유)", "가솔린(휘발유)", "LPG"], basePrice: 3600, priceStep: 170, baseMileage: 13000, mileageStep: 16000),
        CarSeed(maker: "르노코리아", model: "SM6", category: "중형", fuels: ["가솔린(휘발유)", "LPG"], basePrice: 3100, priceStep: 160, baseMileage: 11000, mileageStep: 15000),
        CarSeed(maker: "르노코리아", model: "XM3", category: "소형", fuels: ["가솔린(휘발유)", "하이브리드"], basePrice: 2800, priceStep: 150, baseMileage: 9000, mileageStep: 13000),
        CarSeed(maker: "쉐보레", model: "트래버스", category: "SUV", fuels: ["가솔린(휘발유)", "하이브리드"], basePrice: 5600, priceStep: 220, baseMileage: 16000, mileageStep: 19000),
        CarSeed(maker: "쉐보레", model: "이쿼녹스", category: "SUV", fuels: ["디젤(경유)", "가솔린(휘발유)"], basePrice: 4200, priceStep: 180, baseMileage: 14000, mileageStep: 16000),
        CarSeed(maker: "쉐보레", model: "스파크", category: "경차", fuels: ["가솔린(휘발유)", "LPG"], basePrice: 1800, priceStep: 130, baseMileage: 7000, mileageStep: 11000),
        CarSeed(maker: "쉐보레", model: "말리부", category: "중형", fuels: ["가솔린(휘발유)", "디젤(경유)"], basePrice: 3300, priceStep: 170, baseMileage: 12000, mileageStep: 15000),
        CarSeed(maker: "벤츠", model: "E-클래스", category: "중형", fuels: ["가솔린(휘발유)", "디젤(경유)", "하이브리드"], basePrice: 7200, priceStep: 260, baseMileage: 14000, mileageStep: 17000),
        CarSeed(maker: "벤츠", model: "S-클래스", category: "대형", fuels: ["가솔린(휘발유)", "하이브리드"], basePrice: 9200, priceStep: 320, baseMileage: 12000, mileageStep: 16000),
        CarSeed(maker: "벤츠", model: "GLC", category: "SUV", fuels: ["가솔린(휘발유)", "디젤(경유)", "하이브리드"], basePrice: 7800, priceStep: 240, baseMileage: 15000, mileageStep: 18000),
        CarSeed(maker: "벤츠", model: "GLE", category: "SUV", fuels: ["가솔린(휘발유)", "하이브리드"], basePrice: 8800, priceStep: 280, baseMileage: 16000, mileageStep: 19000),
        CarSeed(maker: "BMW", model: "5시리즈", category: "중형", fuels: ["가솔린(휘발유)", "디젤(경유)", "하이브리드"], basePrice: 7100, priceStep: 250, baseMileage: 13000, mileageStep: 16000),
        CarSeed(maker: "BMW", model: "3시리즈", category: "준중형", fuels: ["가솔린(휘발유)", "디젤(경유)"], basePrice: 5700, priceStep: 210, baseMileage: 12000, mileageStep: 15000),
        CarSeed(maker: "BMW", model: "X3", category: "SUV", fuels: ["가솔린(휘발유)", "디젤(경유)", "하이브리드"], basePrice: 6600, priceStep: 230, baseMileage: 14000, mileageStep: 17000),
        CarSeed(maker: "BMW", model: "X5", category: "SUV", fuels: ["가솔린(휘발유)", "하이브리드"], basePrice: 8400, priceStep: 260, baseMileage: 15000, mileageStep: 18000),
        CarSeed(maker: "아우디", model: "A6", category: "중형", fuels: ["가솔린(휘발유)", "디젤(경유)", "하이브리드"], basePrice: 6800, priceStep: 220, baseMileage: 13000, mileageStep: 16000),
        CarSeed(maker: "아우디", model: "Q5", category: "SUV", fuels: ["가솔린(휘발유)", "디젤(경유)", "하이브리드"], basePrice: 7200, priceStep: 230, baseMileage: 14000, mileageStep: 17000),
        CarSeed(maker: "아우디", model: "A4", category: "준중형", fuels: ["가솔린(휘발유)", "디젤(경유)", "하이브리드"], basePrice: 5900, priceStep: 200, baseMileage: 12000, mileageStep: 15000),
        CarSeed(maker: "아우디", model: "Q7", category: "SUV", fuels: ["가솔린(휘발유)", "하이브리드"], basePrice: 8800, priceStep: 280, baseMileage: 15000, mileageStep: 19000),
        CarSeed(maker: "테슬라", model: "모델 3", category: "중형", fuels: ["전기"], basePrice: 6500, priceStep: 210, baseMileage: 6000, mileageStep: 12000),
        CarSeed(maker: "테슬라", model: "모델 Y", category: "SUV", fuels: ["전기"], basePrice: 7000, priceStep: 220, baseMileage: 7000, mileageStep: 13000),
        CarSeed(maker: "테슬라", model: "모델 S", category: "대형", fuels: ["전기"], basePrice: 9000, priceStep: 260, baseMileage: 8000, mileageStep: 14000),
        CarSeed(maker: "페라리", model: "458 이탈리아", category: "스포츠카", fuels: ["가솔린(휘발유)", "하이브리드"], basePrice: 9900, priceStep: 330, baseMileage: 8000, mileageStep: 12000),
        CarSeed(maker: "페라리", model: "캘리포니아 T", category: "스포츠카", fuels: ["가솔린(휘발유)", "하이브리드"], basePrice: 9700, priceStep: 310, baseMileage: 8500, mileageStep: 13000),
        CarSeed(maker: "페라리", model: "812 슈퍼패스트", category: "스포츠카", fuels: ["가솔린(휘발유)"], basePrice: 9950, priceStep: 340, baseMileage: 7800, mileageStep: 11000)
    ]
    
    static let cars: [SearchCar] = {
        var entries: [SearchCar] = []
        var areaIndex = 0
        for seed in seeds {
            for (offset, year) in variantYears.enumerated() {
                let price = max(500, seed.basePrice - offset * seed.priceStep)
                let mileage = seed.baseMileage + offset * seed.mileageStep
                let area = areas[areaIndex % areas.count]
                areaIndex += 1
                let fuel = seed.fuels[offset % seed.fuels.count]
//                entries.append(
//                    SearchCar(
//                        maker: seed.maker,
//                        model: seed.model,
//                        category: seed.category,
//                        fuel: fuel,
//                        area: area,
//                        year: year,
//                        price: price,
//                        mileage: mileage
//                    )
//                )
            }
        }
        return entries
    }()
}
