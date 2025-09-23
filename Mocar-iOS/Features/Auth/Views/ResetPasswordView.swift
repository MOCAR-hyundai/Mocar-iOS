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
              TopBar(style: .login)
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
                  .padding(.vertical, 13)   // 높이 줄임
                  .padding(.horizontal, 15)  // 좌우는 살짝 유지
                  .background(
                      RoundedRectangle(cornerRadius: 10)
                          .fill(Color.white)   // 배경 흰색
                  )
                  .overlay(
                      RoundedRectangle(cornerRadius: 10)
                          .stroke(Color.lineGray, lineWidth: 1)
                  )
                  .padding(.horizontal)
              
              
              Button(action: resetPassword) {
                  Text("비밀번호 재설정 메일 보내기")
//                      .frame(maxWidth: .infinity)
                      .frame(maxWidth: .infinity, maxHeight: 24)
                      .padding()
                      .background(Color.keyColorDarkGray)
                      .foregroundColor(.white)
                      .cornerRadius(62)
                      .padding(.horizontal)
                      .font(.system(size: 16, weight: .bold, design: .default))
              }
              .padding(.top, 7)

              if let message = message {
                  Text(message)
                      .foregroundColor(.gray)
                      .padding()
              }

              Spacer()
             
              
              Button(action: {
                  dismiss()
              }) {
                  Text("로그인 화면으로 돌아가기")
                      .frame(maxWidth: .infinity)
                      .foregroundColor(.textGray200)
                      .padding(.horizontal)
                      .font(.footnote)
                      .padding(.bottom, 50)
              }
              
              
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
