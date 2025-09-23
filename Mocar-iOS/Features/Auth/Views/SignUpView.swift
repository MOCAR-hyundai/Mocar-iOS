//
//  SignUpView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @EnvironmentObject var session: UserSession
    @Environment(\.dismiss) private var dismiss   // 현재 화면 닫기 위한 dismiss
    
    // FocusState enum 정의
    enum Field {
        case email, password, confirmPassword, birthDate, name
    }
    
    @FocusState private var focusedField: Field?   // 현재 포커싱된 필드
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var birthDate: String = ""
    @State private var name: String = ""
    
    @State private var isPasswordSecured: Bool = true
    @State private var isConfirmPasswordSecured: Bool = true
    
    
    var body: some View {
        ScrollView{
            VStack (spacing: 20) {
                
            TopBar(style: .singup)
                .padding(.bottom, 30)
                .background(Color.backgroundGray100)
                
               // 제목
               Text("회원가입")
                    .font(.system(size: 30, weight: .semibold, design: .default))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Spacer().frame(height: 1)
                
                
                    // 입력 폼
                    VStack(alignment: .leading, spacing: 3) {
                        
                        VStack(alignment: .leading, spacing: 6) {
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
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(focusedField == .email ? Color.keyColorBlue : Color.gray, lineWidth: 1)
                                )
                                .focused($focusedField, equals: .email) // 포커스 상태 연결
                        }
                        
                        // 비밀번호
                        VStack(alignment: .leading, spacing: 6) {
                            Text("비밀번호")
                                .font(.system(size: 14))
                                .padding(.top, 6)
                            
                            ZStack {
                                if isPasswordSecured {
                                    SecureField("비밀번호", text: $password)
                                        .autocapitalization(.none)   // 자동 대문자 방지
                                        .textInputAutocapitalization(.never) // 자동 대문자 방지: iOS 15 이상
                                        .disableAutocorrection(true) // 자동 수정 방지
                                        .padding()
                                        .padding(.trailing, 50)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(focusedField == .password ? Color.keyColorBlue : Color.gray, lineWidth: 1)
                                        )
                                        .focused($focusedField, equals: .password)
                                } else {
                                    TextField("비밀번호", text: $password)
                                        .autocapitalization(.none)   // 자동 대문자 방지
                                        .textInputAutocapitalization(.never) // 자동 대문자 방지: iOS 15 이상
                                        .disableAutocorrection(true) // 자동 수정 방지
                                        .padding()
                                        .padding(.trailing, 50)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(focusedField == .password ? Color.keyColorBlue : Color.gray, lineWidth: 1)
                                        )
                                        .focused($focusedField, equals: .password)
                                }
                                HStack {
                                    Spacer()
                                    Button(action: { isPasswordSecured.toggle() }) {
    //                                    Image(systemName: isPasswordSecured ? "eye.slash" : "eye")
    //                                        .foregroundColor(.gray)
    //                                        .padding(.trailing, 12)
                                        
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
                        }
                        
                        // 비밀번호 확인
                        VStack(alignment: .leading, spacing: 6) {
                            Text("비밀번호 확인")
                                .font(.system(size: 14))
                                .padding(.top, 6)
                            
                            ZStack {
                                if isConfirmPasswordSecured {
                                    SecureField("비밀번호 확인", text: $confirmPassword)
                                        .autocapitalization(.none)   // 자동 대문자 방지
                                        .textInputAutocapitalization(.never) // 자동 대문자 방지: iOS 15 이상
                                        .disableAutocorrection(true) // 자동 수정 방지
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(focusedField == .confirmPassword ? Color.keyColorBlue : Color.gray, lineWidth: 1)
                                        )
                                        .focused($focusedField, equals: .confirmPassword)
                                } else {
                                    TextField("비밀번호 확인", text: $confirmPassword)
                                        .autocapitalization(.none)   // 자동 대문자 방지
                                        .textInputAutocapitalization(.never) // 자동 대문자 방지: iOS 15 이상
                                        .disableAutocorrection(true) // 자동 수정 방지
                                        .padding()
                                        .padding(.trailing, 50)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(focusedField == .confirmPassword ? Color.keyColorBlue : Color.gray, lineWidth: 1)
                                        )
                                        .focused($focusedField, equals: .confirmPassword)
                                }
                                HStack {
                                    Spacer()
                                    Button(action: { isConfirmPasswordSecured.toggle() }) {
                                        ZStack {
                                            if isConfirmPasswordSecured {
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
                        }
                        
                        // 생년월일
                        VStack(alignment: .leading, spacing: 6) {
                            Text("생년월일")
                                .font(.system(size: 14))
                                .padding(.top, 6)
                            
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                                TextField("YYYY-MM-DD", text: $birthDate)
                                    .keyboardType(.numbersAndPunctuation)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(focusedField == .birthDate ? Color.keyColorBlue : Color.gray, lineWidth: 1)
                            )
                            .focused($focusedField, equals: .birthDate)
                        }
                        
                        // 이름
                        VStack(alignment: .leading, spacing: 6) {
                            Text("이름")
                                .font(.system(size: 14))
                                .padding(.top, 6)
                            TextField("이름", text: $name)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(focusedField == .name ? Color.keyColorBlue : Color.gray, lineWidth: 1)
                                )
                                .focused($focusedField, equals: .name)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 15)
                    
                    // 회원가입 버튼
                    Button(action: {
                        // 회원가입 액션
                        signUp()
                        
                    }) {
                        Text("회원가입")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 28) // 버튼 높이 설정
                            .padding()
                            .background(Color.keyColorDarkGray)
                            .cornerRadius(62)
                    }
                    .padding(.horizontal)
                    .font(.system(size: 18, weight: .bold, design: .default))
                    
                    Spacer()
                    
                    // 하단 안내
                    HStack {
                        Text("이미 계정이 있으신가요?")
                        Button("로그인") {
                            dismiss()
                        }
                        .foregroundColor(.keyColorBlue)
                    }
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)
                }
                .padding(.leading, 5)
                .background(Color.backgroundGray100)
                .navigationBarBackButtonHidden(true)
        }
        .background(Color.backgroundGray100)
        .ignoresSafeArea(.keyboard, edges: .bottom) // 키보드가 올라와도 전체가 안 밀리게
     
    }
    
    
    
    // MARK: - 회원가입 함수
    func signUp() {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty, !name.isEmpty, !birthDate.isEmpty else {
            print("모든 필드를 입력해주세요.")
            return
        }
        
        guard password == confirmPassword else {
            print("비밀번호와 비밀번호 확인이 일치하지 않습니다.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("회원가입 실패:", error.localizedDescription)
                return
            }
            
            guard let authUser = result?.user else { return }
            
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "email": email,
                "name": name,
                "dob": birthDate,         // 생년월일
                "photoUrl": "",
                "phone": "",
                "rating": 0.0,
                "ratingCount": 0,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ]
            
            db.collection("users").document(authUser.uid).setData(userData) { error in
                if let error = error {
                    print("Firestore 저장 실패:", error.localizedDescription)
                } else {
                    print("회원가입 성공 및 Firestore 저장 완료")
                    dismiss()  // 회원가입 완료 후 화면 닫기
                }
            }
        }
    }
    
}

#Preview {
    SignUpView()
}
