//
//  CarSizeFilterView.swift
//  Mocar-iOS
//
//  Created by wj on 9/17/25.
//

import SwiftUI

struct CarSizeFilterView: View {
    @State private var fuels: [CheckableItem] = [
        CheckableItem(name: "경차", checked: false),
        CheckableItem(name: "소형", checked: false),
        CheckableItem(name: "준중형", checked: false),
        CheckableItem(name: "중형", checked: false),
        CheckableItem(name: "대형", checked: false),
        CheckableItem(name: "스포츠카", checked: false),
        CheckableItem(name: "SUV", checked: false),
        CheckableItem(name: "RV", checked: false),
        CheckableItem(name: "승합", checked: false),
        CheckableItem(name: "트럭", checked: false),
        CheckableItem(name: "버스", checked: false)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("차종")
                    .font(.headline)
                    .padding(.bottom, 10)
                ForEach(fuels.indices, id: \.self) { idx in
                    CheckOptionsRow(item: $fuels[idx])
                    Divider()
                }
            }
            .padding(.top, 20)
            .padding(.horizontal)
        }
    }
}
