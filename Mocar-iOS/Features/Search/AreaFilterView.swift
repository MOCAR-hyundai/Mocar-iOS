//
//  AreaFilterView.swift
//  Mocar-iOS
//
//  Created by wj on 9/17/25.
//

import SwiftUI

struct AreaFilterView: View {
    @State private var fuels: [CheckableItem] = [
        CheckableItem(name: "서울", checked: false),
        CheckableItem(name: "인천", checked: false),
        CheckableItem(name: "대전", checked: false),
        CheckableItem(name: "대구", checked: false),
        CheckableItem(name: "광주", checked: false),
        CheckableItem(name: "부산", checked: false),
        CheckableItem(name: "울산", checked: false),
        CheckableItem(name: "세종", checked: false),
        CheckableItem(name: "경기", checked: false),
        CheckableItem(name: "강원", checked: false),
        CheckableItem(name: "경남", checked: false),
        CheckableItem(name: "경북", checked: false),
        CheckableItem(name: "전남", checked: false),
        CheckableItem(name: "전북", checked: false),
        CheckableItem(name: "충남", checked: false),
        CheckableItem(name: "충북", checked: false),
        CheckableItem(name: "제주", checked: false),
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(fuels.indices, id: \.self) { idx in
                    CheckOptionsRow(item: $fuels[idx])
                    Divider()
                }
            }
        }
    }
}
