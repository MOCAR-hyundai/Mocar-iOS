//
//  CarSizeFilterView.swift
//  Mocar-iOS
//
//  Created by wj on 9/17/25.
//

import SwiftUI

struct CarSizeFilterView: View {
    @Binding var options: [CheckableItem]
    var countProvider: (String) -> Int
    var onToggle: ((CheckableItem) -> Void)? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("차종")
                    .font(.footnote)
                    .fontWeight(.semibold)
                
                    .padding(.bottom, 10)
                ForEach(options.indices, id: \.self) { index in
                    let optionName = options[index].name
                    CheckOptionsRow(item: $options[index], count: countProvider(optionName), onToggle: { updated in
                        onToggle?(updated)
                    })
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
