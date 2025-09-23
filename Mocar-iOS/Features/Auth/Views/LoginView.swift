//
//  LoginView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordSecured: Bool = true
    @State private var keepLoggedIn: Bool = false
    
    @State private var loginErrorMessage: String? = nil
    @State private var isLoading: Bool = false

    //@State private var navigateToHome = false

    
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss

    enum Field {
        case email
        case password
    }
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 20) {
              
                TopBar(style: .login)
                    .padding(.bottom, 70)
                    .padding(.leading,5)
                    .background(Color.backgroundGray100)
                

                Text("로그인")
                    .font(.system(size: 30, weight: .semibold, design: .default))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Spacer().frame(height: 10)
                
                VStack(alignment: .leading, spacing: 7) {
                    // 이메일
                    Text("이메일")
                        .font(.system(size: 14))
                    

                    TextField("abc@example.com", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(focusedField == .email ? Color.keyColorBlue : Color.gray, lineWidth: 1)
                        )
                        .focused($focusedField, equals: .email)
                        .background(Color.white)
                    // 비밀번호
                    Text("비밀번호")
                        .font(.system(size: 14))
                        .padding(.top, 6)
                    
                    ZStack {
                        if isPasswordSecured {
                            SecureField("8자 이상의 비밀번호", text: $password)
                                .autocapitalization(.none)   // 자동 대문자 방지
                                .textInputAutocapitalization(.never) // 자동 대문자 방지: iOS 15 이상
                                .disableAutocorrection(true) // 자동 수정 방지
                                .padding()
                                .padding(.trailing, 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(focusedField == .password ? Color.keyColorBlue : Color.gray, lineWidth: 1)
                                )
                                .focused($focusedField, equals: .password)
                                .background(Color.white)
                        } else {
                            TextField("8자 이상의 비밀번호", text: $password)
                                .autocapitalization(.none)   // 자동 대문자 방지
                                .textInputAutocapitalization(.never) // 자동 대문자 방지: iOS 15 이상
                                .disableAutocorrection(true) // 자동 수정 방지
                                .padding()
                                .padding(.trailing, 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .background(Color.white)
                        }
                        HStack {
                            Spacer()
                            Button(action: {
                                isPasswordSecured.toggle()
                            }) {
                                ZStack {
                                    if isPasswordSecured {
                                        Image("closedeye")   // Assets에 넣은 커스텀 이미지
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .padding(.trailing)
                                    } else {
                                        Image(systemName: "eye")   // SF Symbols
                                            .foregroundStyle(.black)
                                            .frame(width: 20, height: 20)
                                            .padding(.trailing)
                                    }
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Toggle("로그인 상태 유지", isOn: $keepLoggedIn)
                            .toggleStyle(CheckboxToggleStyle())
                        Spacer()
                        
                        NavigationLink("비밀번호를 잃어버리셨나요? ", destination: ResetPasswordView())
                            .foregroundColor(.blue)
                        
                    }
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .padding(.top, 6)
                }
                .padding(.horizontal)
                
                Spacer().frame(height: 20)
                
                if let errorMessage = loginErrorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                }
                
                // 로그인 버튼
                Button(action: {
                    // 로그인 액션
                    login()
                }) {
                    if isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity, maxHeight: 30)
                            .padding()
                            .background(Color.keyColorDarkGray)
                            .cornerRadius(62)
                    } else {
                        Text("로그인")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: 30)
                            .padding()
                            .background(Color.keyColorDarkGray)
                            .cornerRadius(62)
                    }
                }
                .padding(.horizontal)
                .font(.system(size: 18, weight: .bold, design: .default))
                
                Spacer()
                
                HStack {
                    Text("계정이 없으신가요?")
                    NavigationLink("회원가입", destination: SignUpView())
                        .foregroundColor(.blue)
                }
                .font(.footnote)
                .padding(.bottom, 50)
            }
            .padding(.top)
//            .navigationDestination(isPresented: $navigateToHome) {
//                HomeView()
//            }
            .background(Color.backgroundGray100)
            
        }
        .background(Color.backgroundGray100)
        .navigationBarBackButtonHidden(true)
 
    }
    
    // MARK: - Firebase 로그인 함수
    @MainActor
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            loginErrorMessage = "이메일과 비밀번호를 입력해주세요."
            return
        }
        
        isLoading = true
        loginErrorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                loginErrorMessage = "로그인 실패: \(error.localizedDescription)"
                return
            }
            
            // 로그인 성공 시
            if let user = result?.user {
                // uid 확인용, 나중에 삭제
                print("로그인 성공, uid: \(user.uid)")
                // keepLoggedIn 처리
                if keepLoggedIn {
                    UserDefaults.standard.set(true, forKey: "keepLoggedIn")
                }
                // 다음 화면으로 이동 처리 가능
//                navigateToHome = true   // ✅ 로그인 성공 시 홈으로 이동
                dismiss()

            }
        }
    }
    
}

// Checkbox toggle style
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()                   // 이미지 크기 조절 가능
                .frame(width: 19, height: 19)  // 원하는 크기
                .foregroundColor(Color.textGray200)    // 체크 색상 지정 가능
                .onTapGesture { configuration.isOn.toggle() }
            configuration.label
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

#Preview {
    LoginView()
}
