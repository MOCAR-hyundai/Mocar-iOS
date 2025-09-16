//
//  BottomBar.swift
//  Mocar-iOS
//
//  Created by wj on 9/15/25.
//

import SwiftUI

struct BottomBar: View {
    
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image("Home")
                    Text("내차사기")
                }
//            CarNumberView()
            SellCarFlowView()
                .tabItem {
                    Image("Car")
                    Text("내차팔기")
                }
            ContentView()
                .tabItem {
                    Image("Search")
                    Text("검색")
                }
            ContentView()
                .tabItem {
                    Image("Chat")
                    Text("채팅")
                }
            ContentView()
                .tabItem {
                    Image("User")
                    Text("마이페이지")
                }
        }
    }
}

#Preview {
    BottomBar()
}
