//
//  SearchBar.swift
//  Mocar-iOS
//
//  Created by wj on 9/25/25.
//

import SwiftUI

enum SearchBarStyle {
    case placeholder(text: String)
    case button(text: String, action: () -> ()) // 버튼 스타일
    case textField(query: Binding<String>)  // 텍스트 입력 필드
}

struct SearchBar: View {
    let style: SearchBarStyle
    var icon: String = "Search"
    
    var body: some View {
        HStack {
            Image(icon)
                .padding(.leading, 8)
            
            switch style {
                
            case .placeholder(let text):
                HStack {
                    Text(text)
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .contentShape(Rectangle())
                
            case .button(let text, let action):
                Button(action: action) {
                    HStack {
                        Text(text)
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
            case .textField(let query):
                TextField("모델명을 입력하세요", text: query)
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.default)
                
                if !query.wrappedValue.isEmpty {
                    Button {
                        query.wrappedValue = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}
