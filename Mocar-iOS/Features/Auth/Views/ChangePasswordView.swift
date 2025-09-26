//
//  ChangePasswordView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//
import SwiftUI
import FirebaseAuth

// 포커스 필드 열거형 (필요한 케이스들)
enum FocusedField: Hashable {
    case currentPassword
    case newPassword
    case confirmPassword
}

struct ChangePasswordView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var isCurrentSecured = true
    @State private var isNewSecured = true
    @State private var isConfirmSecured = true
    
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    @FocusState private var focusedField: FocusedField?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        ZStack {
              // 전체 배경색
            Color(Color.backgroundGray100)
                  .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                
                TopBar(style: .Mylistings(title: "비밀번호 변경"))
                    .padding(.bottom)
                    .background(Color.backgroundGray100)
                
                VStack(alignment: .leading, spacing: 7){
                    // 현재 비밀번호
                    Text("현재 비밀번호 입력")
                        .font(.system(size: 14))
                        .padding(.top, 20)
                    CustomSecureField(
                        text: $currentPassword,
                        isSecured: $isCurrentSecured,
                        placeholder: "현재 비밀번호 입력",
                        focusedField: $focusedField,
                        fieldType: .currentPassword
                    )
                    
                    // 새 비밀번호
                    Text("새 비밀번호 입력")
                        .font(.system(size: 14))
                        .padding(.top, 10)
                    CustomSecureField(
                        text: $newPassword,
                        isSecured: $isNewSecured,
                        placeholder: "새 비밀번호 입력 (8자 이상)",
                        focusedField: $focusedField,
                        fieldType: .newPassword
                    )
                    
                    // 새 비밀번호 확인
                    Text("새 비밀번호 확인")
                        .font(.system(size: 14))
                        .padding(.top, 10)
                    CustomSecureField(
                        text: $confirmPassword,
                        isSecured: $isConfirmSecured,
                        placeholder: "새 비밀번호 확인",
                        focusedField: $focusedField,
                        fieldType: .confirmPassword
                    )
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                    if !successMessage.isEmpty {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .font(.footnote)
                    }
                    
                    HStack() {
                        Button(action: {
                            // 취소 동작 (예: dismiss)
                            dismiss()
                        }) {
                            Text("취소")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)   // 높이 줄임 (기본 16 → 10)
                                .padding(.horizontal, 8)  // 좌우는 살짝 유지
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: changePassword) {
                            Text("확인")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)   // 높이 줄임 (기본 16 → 10)
                                .padding(.horizontal, 8)  // 좌우는 살짝 유지
                                .background(Color.keyColorBlue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top, 13)
                    
                    Spacer()
                }
                .padding(50)
                .padding(.top, 40)
                
            }
            .background(Color.backgroundGray100)
            
        }
    }
    
    private func changePassword() {
        errorMessage = ""
        successMessage = ""
        
        guard !currentPassword.isEmpty,
              !newPassword.isEmpty,
              !confirmPassword.isEmpty else {
            errorMessage = "모든 필드를 입력해주세요."
            return
        }
        guard newPassword == confirmPassword else {
            errorMessage = "새 비밀번호가 일치하지 않습니다."
            return
        }
        guard newPassword.count >= 8 else {
            errorMessage = "새 비밀번호는 8자 이상이어야 합니다."
            return
        }
        
        guard let user = Auth.auth().currentUser, let email = user.email else {
            errorMessage = "사용자 정보를 가져올 수 없습니다."
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                errorMessage = "현재 비밀번호가 올바르지 않습니다. \(error.localizedDescription)"
                return
            }
            
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    errorMessage = "비밀번호 변경 실패: \(error.localizedDescription)"
                } else {
//                    successMessage = "비밀번호가 성공적으로 변경되었습니다."
                    currentPassword = ""
                    newPassword = ""
                    confirmPassword = ""
                    
                    DispatchQueue.main.async {
                        successMessage = "비밀번호가 성공적으로 변경되었습니다."
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }

                }
            }
        }
    }
}
