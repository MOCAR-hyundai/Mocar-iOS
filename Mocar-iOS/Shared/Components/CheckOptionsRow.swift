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
    var count: Int? = nil
    var onToggle: ((CheckableItem) -> Void)? = nil
    
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    private var isDisabled: Bool {
        if let count, count == 0, item.checked == false {
            return true
        }
        return false
    }
    
    var body: some View {
        Button(action: {
            item.checked.toggle() // 클릭하면 체크 상태 토글
            onToggle?(item)
        }) {
            HStack {
                // 체크 아이콘
                Image(systemName: item.checked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.checked ? Color.accentColor : Color(.systemGray3))
                
                // 항목 이름
                Text(item.name)
                    .foregroundColor(isDisabled ? .gray : .black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let count = count {
                    Text(Self.formattedCount(count))
                        .foregroundColor(count == 0 ? .gray : .secondary)
                        .font(.footnote)
                }
            }
            .frame(height: 50)
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
    }

    private static func formattedCount(_ count: Int) -> String {
        numberFormatter.string(from: NSNumber(value: count)) ?? "\(count)"
    }
}
