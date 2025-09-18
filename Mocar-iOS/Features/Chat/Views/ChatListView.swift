//
//  ChatListView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct ChatListView: View {
    @StateObject private var vm = ChatListViewModel()
    @StateObject private var userStore = UserStore()
    @Environment(\.dismiss) private var dismiss

    let currentUserId: String   // 로그인한 사용자 UID
    @State private var searchText: String = "" // 검색 기능용

    //목업데이터 불러옴
    init(currentUserId: String, vm: ChatListViewModel = ChatListViewModel(), userStore: UserStore = UserStore()) {
        self.currentUserId = currentUserId
        _vm = StateObject(wrappedValue: vm)
        _userStore = StateObject(wrappedValue: userStore)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        // 뒤로가기 액션
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .frame(width: 20, height: 20)
                            .padding(12) // 아이콘 주변 여백
                            .foregroundColor(.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50) // 충분히 큰 값이면 원처럼 둥글게
                                    .stroke(Color.lineGray, lineWidth: 1) // 테두리 색과 두께
                            )
                    }
                    Spacer()
                    Text("Chats")
                        .font(.system(size: 18, weight: .bold, design: .default))
                    
                    
                    Spacer()
                    
                    Button(action: {
                        // 점 세개 액션
                    }) {
                        Image("3Dot")
                            .frame(width: 20, height: 20)
                            .padding(12) // 아이콘 주변 여백
                            .overlay(
                                RoundedRectangle(cornerRadius: 50) // 충분히 큰 값이면 원처럼 둥글게
                                    .stroke(Color.lineGray, lineWidth: 1) // 테두리 색과 두께
                            )
                    }
                }
                .padding(.horizontal)
                .padding(3)
                .padding(.vertical, 6)
                .padding(.bottom, 5)
                .background(Color.backgroundGray100) // <- F8F8F8 배경
                
                // 검색 바
                TextField("Search your dream car...", text: $searchText)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                // 채팅방 리스트
                List {
                    ForEach(filteredChats) { chat in
                        ChatRow(chat: chat,
                                currentUserId: currentUserId,
                                userStore: userStore,
                                vm: vm)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .onAppear {
                vm.fetchChats(for: currentUserId)
            }
        }
    }

    // 검색 텍스트 기반 필터링
    private var filteredChats: [Chat] {
        if searchText.isEmpty {
            return vm.chats
        } else {
            return vm.chats.filter { chat in
                let otherId = chat.buyerId == currentUserId ? chat.sellerId : chat.buyerId
                let otherName = userStore.users[otherId]?.name ?? ""
                return otherName.lowercased().contains(searchText.lowercased())
            }
        }
    }
}


struct ChatRow: View {
    let chat: Chat
    let currentUserId: String
    @ObservedObject var userStore: UserStore
    @ObservedObject var vm: ChatListViewModel  // EnvironmentObject → ObservedObject

    var otherUserId: String {
        chat.buyerId == currentUserId ? chat.sellerId : chat.buyerId
    }

    var body: some View {
        HStack {
            // 실제 이미지 불러올 경우 다시 살림
            AsyncImage(url: URL(string: userStore.users[otherUserId]?.photoUrl ?? "")) { image in
                image.resizable()
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.3))
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // 테스트 용 이미지
//            Image("user2sample")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 50, height: 50)
//                .clipShape(Circle())

            
            VStack(alignment: .leading) {
                Text(userStore.users[otherUserId]?.name ?? "Unknown")
                    .font(.headline)
                Text(chat.lastMessage ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(chat.lastAt, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)

                if let unread = vm.unreadCounts[chat.id ?? ""], unread > 0 {
                    Text("\(unread)")
                        .font(.caption2)
                        .padding(6)
                        .background(Circle().fill(Color.blue))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            userStore.fetchUser(userId: otherUserId)
        }
    }
}


// MARK: - 목업 프리뷰



struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        // 1️⃣ ChatListViewModel 목업
        let vm = ChatListViewModel()
        vm.chats = [
            Chat(
                id: "chat_001",
                buyerId: "user_001",
                sellerId: "user_002",
                listingId: "listing_abc",
                lastMessage: "안녕하세요!",
                lastAt: Date()
            ),
            Chat(
                id: "chat_002",
                buyerId: "user_001",
                sellerId: "user_003",
                listingId: "listing_xyz",
                lastMessage: "구매 가능한가요?",
                lastAt: Date().addingTimeInterval(-3600)
            )
        ]
        // 목업 미확인 메시지 수
        vm.unreadCounts = [
            "chat_001": 3,
            "chat_002": 0
        ]

        // 2️⃣ UserStore 목업
        let userStore = UserStore()
        userStore.users = [
            "user_001": User(
                id: "user_001",
                email: "hong@test.com",
                name: "홍길동",
                photoUrl: "https://via.placeholder.com/150",
                phone: "010-1234-5678",
                rating: 4.8,
                ratingCount: 15,
                createdAt: Date(),
                updatedAt: Date()
            ),
            "user_002": User(
                id: "user_002",
                email: "kim@test.com",
                name: "김철수",
                photoUrl: "https://via.placeholder.com/150",
                phone: "010-9876-5432",
                rating: 4.5,
                ratingCount: 8,
                createdAt: Date(),
                updatedAt: Date()
            ),
            "user_003": User(
                id: "user_003",
                email: "lee@test.com",
                name: "이영희",
                photoUrl: "https://via.placeholder.com/150",
                phone: "010-5555-6666",
                rating: 4.9,
                ratingCount: 12,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]

        // 3️⃣ ChatListView에 주입
        return ChatListView(
            currentUserId: "user_001",
            vm: vm,
            userStore: userStore
        )
    }
}

