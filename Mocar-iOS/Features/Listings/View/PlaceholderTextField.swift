//
//  PlaceholderTextField.swift
//  Mocar-iOS
//
//  Created by Admin on 9/24/25.
//

import SwiftUI

enum ValidationType {
    case any
    case numbersOnly
}

struct PlaceholderTextField: View {
    var label: String
    var placeholder: String   // DB에서 가져온 값
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var validation: ValidationType = .any
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.black)
            
            Spacer()
            
            ZStack(alignment: .trailing) {
                // 실제 입력 필드
                TextField("", text: $text)
                    .focused($isFocused)
                    .keyboardType(keyboardType)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.black) // 입력한 값은 검정색
                    .onChange(of: text) { newValue in
                        print(" Focus changed: \(focused)")
                        switch validation {
                        case .numbersOnly:
                            text = newValue.filter { $0.isNumber }

                        case .any:
                            break
                        }
                    }
                
                // placeholder (포커스 없고 입력값 없을 때만)
                if !isFocused && text.isEmpty {
                    HStack{
                        Text(placeholder)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Image("icons8-연필")
                            .resizable()
                            .frame(width: 17, height: 17)
                    }
                    
                }
            }
            .frame(height: 20)
        }
        .padding(.vertical, 10)
    }
}
