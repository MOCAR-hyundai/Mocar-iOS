//
//  CheckOptionsRow.swift
//  Mocar-iOS
//
//  Created by wj on 9/17/25.
//

import SwiftUI

/// 모든 체크 가능한 항목을 위한 공통 모델
struct CheckableItem: Identifiable {
    let id = UUID()
    let name: String
    var checked: Bool
}

struct CheckOptionsRow: View {
    @Binding var item: CheckableItem

    var body: some View {
        Button(action: {
            item.checked.toggle() // 클릭하면 체크 상태 토글
        }) {
            HStack {
                // 체크 아이콘
                Image(systemName: item.checked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.checked ? Color.accentColor : Color(.systemGray3))

                // 항목 이름
                Text(item.name)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 50)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}
