//
//  loadingView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/24/25.
//

import SwiftUI

struct loadingView: View {
    var body: some View {
        VStack {
            ProgressView()
            Text("불러오는 중...")
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundGray100)
    }
}
