//
//  FuelFilterView.swift
//  Mocar-iOS
//
//  Created by wj on 9/17/25.
//

import SwiftUI

struct FuelFilterView: View {
    @State private var fuels: [CheckableItem] = [
        CheckableItem(name: "가솔린(휘발유)", checked: false),
        CheckableItem(name: "디젤(경유)", checked: false),
        CheckableItem(name: "전기", checked: false),
        CheckableItem(name: "LPG", checked: false),
        CheckableItem(name: "하이브리드", checked: false)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("연료")
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
