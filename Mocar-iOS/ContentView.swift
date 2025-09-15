//
//  ContentView.swift
//  Mocar-iOS
//
//  Created by wj on 9/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("내 차,\n시세를 알아볼까요?")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 16)
            TextField("12가 1234", text: .constant(""))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 2)
                )
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    ContentView()
}
