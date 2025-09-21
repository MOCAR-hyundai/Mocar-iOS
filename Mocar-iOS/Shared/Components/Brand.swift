//
//  Brand.swift
//  Mocar-iOS
//
//  Created by Admin on 9/19/25.
//

import Foundation

struct Brand: Identifiable {
    var id = UUID()
    var name: String
    var logo: String
}

let brandLogoMap: [String: String] = [
    "BMW": "bmw",
    "현대": "hyundai 1",
    "르노코리아(삼성)": "renault",
    "기아": "kia",
    "테슬라": "tesla",
    "아우디": "audi",
    "지프": "jeep",
    "랜드로버": "landrover",
    "폭스바겐": "volkswagen",
    "미니": "mini",
    "쉐보레(GM대우)" :"chevrolet",
    "KG모빌리티(쌍용)" :"KG_Mobility",
    "제네시스": "genesis",
    "벤츠": "benz",
    "포르쉐": "porsche"
    
]
