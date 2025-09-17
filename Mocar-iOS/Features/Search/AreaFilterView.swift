//
//  AreaFilterView.swift
//  Mocar-iOS
//
//  Created by wj on 9/17/25.
//

import SwiftUI

struct AreaFilterView: View {
    @Binding var regions: [CheckableItem]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("지역")
                    .font(.headline)
                    .padding(.bottom, 10)
                ForEach($regions) { $item in
                    CheckOptionsRow(item: $item)
                    Divider()
                }
            }
            .padding(.top, 20)
            .padding(.horizontal)
        }
    }
}
