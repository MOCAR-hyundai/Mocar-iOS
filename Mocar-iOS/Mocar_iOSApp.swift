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
    

    
    // 앱 시작 시 Firebase 초기화
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {

            BottomBar()
                .environmentObject(userSession)
        }
    }

}
