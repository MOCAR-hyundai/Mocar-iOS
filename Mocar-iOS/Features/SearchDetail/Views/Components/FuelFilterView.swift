//
//  FuelFilterView.swift
//  Mocar-iOS
//
//  Created by wj on 9/17/25.
//

import SwiftUI

struct FuelFilterView: View {
    @Binding var options: [CheckableItem]
    var countProvider: (String) -> Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("연료")
                    .font(.headline)
                    .padding(.bottom, 10)
                ForEach(options.indices, id: \.self) { index in
                    let optionName = options[index].name
                    CheckOptionsRow(item: $options[index], count: countProvider(optionName))
                    if index < options.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(.top, 20)
            .padding(.horizontal)
        }
    }
}
