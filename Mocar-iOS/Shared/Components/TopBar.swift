//
//  TopBar.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import SwiftUI

struct TopBar: View {
    var title: String
    var onBack: () -> Void
    var onMenu: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 36, height: 36)
                    .background(Circle().stroke(Color.gray.opacity(0.5)))
            }

            Spacer()

            Text(title)
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            Button(action: onMenu) {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 36, height: 36)
                    .background(Circle().stroke(Color.gray.opacity(0.5)))
            }
        }
        .padding(.horizontal)
        .frame(height: 44)
    }
}

#Preview {
    VStack(spacing: 0) {
        TopBar(
            title: "21나 4817",
            onBack: { print("뒤로가기 눌림") },
            onMenu: { print("메뉴 눌림") }
        )
        Spacer()
   }
}
