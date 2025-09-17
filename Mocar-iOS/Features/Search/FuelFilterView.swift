//
//  FuelFilterView.swift
//  Mocar-iOS
//
//  Created by wj on 9/17/25.
//

import SwiftUI

struct FuelFilterView: View {
    @Binding var fuels: [CheckableItem]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("연료")
                    .font(.headline)
                    .padding(.bottom, 10)
                ForEach($fuels) { $item in
                    CheckOptionsRow(item: $item)
                    Divider()
                }
            }
            .padding(.top, 20)
            .padding(.horizontal)
        }
    }
}
