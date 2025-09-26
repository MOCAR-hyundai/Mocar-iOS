//
//  Mocar_iOSApp.swift
//  Mocar-iOS
//
//  Created by wj on 9/15/25.
//

import SwiftUI
import FirebaseCore

@main
struct Mocar_iOSApp: App {
    @StateObject var userSession = UserSession() // 로그인 상태 관리
    @State private var isLoading = true // ✅ 인트로 상태

    
    // 앱 시작 시 Firebase 초기화
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            Group {
                if isLoading {
                    IntroView() // ✅ 로고만 보여주는 화면
                } else {
                    BottomBar()
                        .environmentObject(userSession)
                }
            }
            .onAppear {
                Task {
                    try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5초
                    isLoading = false
                }
            }
//            BottomBar()
//                .environmentObject(userSession)
        }
    }

}
