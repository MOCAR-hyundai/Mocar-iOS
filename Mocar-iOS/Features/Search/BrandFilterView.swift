//
//  BrandView.swift
//  Mocar-iOS
//
//  Created by wj on 9/17/25.
//

import SwiftUI

struct BrandView: View {
    
    struct Maker: Identifiable {
        let id = UUID()
        let name: String
        let count: Int
        let imageName: String
    }
    
    private let makers: [Maker] = [
        Maker(name: "현대", count: 49355, imageName: "hyundai 1"),
        Maker(name: "제네시스", count: 7381, imageName: "genesis"),
        Maker(name: "기아", count: 41936, imageName: "kia"),
        Maker(name: "르노코리아", count: 7728, imageName: "renault"),
        Maker(name: "쉐보레", count: 8362, imageName: "chevrolet"),
        Maker(name: "벤츠", count: 8413, imageName: "benz"),
        Maker(name: "BMW", count: 8362, imageName: "bmw"),
        Maker(name: "아우디", count: 8362, imageName: "audi"),
        Maker(name: "테슬라", count: 8362, imageName: "tesla"),
        Maker(name: "페라리", count: 8362, imageName: "ferrari"),
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("제조사")
                    .font(.headline)
                    .padding(.bottom, 10)
                ForEach(makers) { maker in
                    BrandOptionsRow(maker: maker)
                }
            }
            .padding(.top, 20)
            .padding(.horizontal)
        }
    }
}
