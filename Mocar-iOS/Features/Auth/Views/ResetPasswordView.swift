//
//  ResetPasswordView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/23/25.
//

import SwiftUI
import FirebaseAuth


struct ResetPasswordView: View {
    @State private var email: String = ""
    @State private var message: String?
    @Environment(\.dismiss) private var dismiss   // 뒤로가기용

    var body: some View {
        ZStack {
          // 전체 배경색
          Color.backgroundGray100
              .ignoresSafeArea()

          VStack(spacing: 20) {
              TopBar(style: .RestPwd)
                  .padding(.top)   // 안전 영역 고려해서 위쪽 붙이기
                  .padding(.leading, 5)
              Spacer().frame(height: 10)

              // 본문
              Text("비밀번호 재설정")
                  .font(.system(size: 30, weight: .semibold))
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding(.horizontal)

              
              Spacer().frame(height: 30)
              
              TextField("이메일 주소 입력", text: $email)
                  .keyboardType(.emailAddress)
                  .textInputAutocapitalization(.never)
                  .padding()
                  .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                  )
                  .background(Color(.white))
                  .padding(.horizontal)
              
              
              Button(action: resetPassword) {
                  Text("비밀번호 재설정 메일 보내기")
                      .frame(maxWidth: .infinity)
                      .padding()
                      .background(Color.keyColorBlue)
                      .foregroundColor(.white)
                      .cornerRadius(8)
                      .padding(.horizontal)
              }

              if let message = message {
                  Text(message)
                      .foregroundColor(.gray)
                      .padding()
              }

              Spacer()
          }
      }
      .navigationBarBackButtonHidden(true) // 기본 back 버튼 숨기기
  }

    private func resetPassword() {
        guard !email.isEmpty else {
            message = "이메일을 입력해주세요."
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                message = "에러: \(error.localizedDescription)"
            } else {
                message = "비밀번호 재설정 메일을 보냈습니다."
            }
        }
    }
}

#Preview {
    ResetPasswordView()
}
