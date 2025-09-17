//
//  CarSizeFilterView.swift
//  Mocar-iOS
//
//  Created by wj on 9/17/25.
//

import SwiftUI

struct CarSizeFilterView: View {
    @Binding var carTypes: [CheckableItem]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("차종")
                    .font(.headline)
                    .padding(.bottom, 10)
                ForEach($carTypes) { $item in
                    CheckOptionsRow(item: $item)
                    Divider()
                }
            }
            .padding(.top, 20)
            .padding(.horizontal)
        }
    }
}
