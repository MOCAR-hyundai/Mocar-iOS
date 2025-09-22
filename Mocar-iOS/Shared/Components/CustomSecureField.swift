//
//  CustomSecureField.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import SwiftUI
import Foundation


struct CustomSecureField: View {
    @Binding var text: String
    @Binding var isSecured: Bool
    var placeholder: String

    // 부모 뷰의 @FocusState<FocusedField?> 바인딩을 받음
    var focusedField: FocusState<FocusedField?>.Binding
    var fieldType: FocusedField

    var body: some View {
        ZStack {
            if isSecured {
                SecureField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(.vertical, 10)   // 🔽 높이 줄이기
                    .padding(.horizontal, 12) // 좌우 패딩
                    .padding(.trailing, 40)   // 아이콘 공간
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(focusedField.wrappedValue == fieldType ? Color.blue : Color.gray, lineWidth: 1)
                    )
                    .focused(focusedField, equals: fieldType)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(.vertical, 10)   // 🔽 높이 줄이기
                    .padding(.horizontal, 12) // 좌우 패딩
                    .padding(.trailing, 40)   // 아이콘 공간
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(focusedField.wrappedValue == fieldType ? Color.blue : Color.gray, lineWidth: 1)
                    )
                    .focused(focusedField, equals: fieldType)
            }

            HStack {
                Spacer()
                Button(action: {
                    isSecured.toggle()
                }) {
                    if isSecured {
                        Image("closedeye")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(.trailing)
                    } else {
                        Image(systemName: "eye")
                            .frame(width: 20, height: 20)
                            .padding(.trailing)
                    }
                }
                .padding(.vertical, 10)   // 🔽 높이 줄이기
            }
        }
    }
}
