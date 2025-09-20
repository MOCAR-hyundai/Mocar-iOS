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
    
    @State private var showSearchBar = false  // 검색창 표시 여부

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
                    // 탑 바
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
                    
                    // 현재 유저의 프로필 이미지 실제 이미지 불러와 지는 지  db에 값 올리고 확인
                    AsyncImage(url: URL(string: userStore.users[currentUserId]?.photoUrl ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        Circle().fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
                    
                    Text("Chats")
                        .font(.system(size: 18, weight: .bold, design: .default))
                    
                    Spacer()
                    
                    // 🔍 버튼
                   Button {
                       withAnimation {
                           showSearchBar.toggle()
                       }
                   } label: {
                       Image("Search")
                           .foregroundColor(.gray)
                           .padding(8)
                   }
                    
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
                
                Divider()
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                
                // 검색 바 (조건부 표시)
              if showSearchBar {
                  HStack {
                      Image("Search")
                          .foregroundColor(.gray)
                          .padding(.leading, 15)

                      TextField("Search your dream car...", text: $searchText)
                          .padding(.vertical, 10)
                  }
                  .frame(height: 48)
                  .background(
                      RoundedRectangle(cornerRadius: 8)
                          .stroke(Color.gray, lineWidth: 1)
                          .background(Color.white.cornerRadius(8))
                  )
                  .padding(.horizontal)
                  .padding(.top, 10)
                  .transition(.move(edge: .top).combined(with: .opacity)) // 애니메이션 효과
              }


                // 채팅방 리스트
//                List {
//                    ForEach(filteredChats) { chat in
//                        ChatRow(chat: chat,
//                                currentUserId: currentUserId,
//                                userStore: userStore,
//                                vm: vm)
//                    }
//                }
//                .listStyle(PlainListStyle())
                
                List {
                    ForEach(filteredChats) { chat in
                        ZStack {
                            // 커스텀 리스트 요소
                            ChatRow(
                                chat: chat,
                                currentUserId: currentUserId,
                                userStore: userStore,
                                vm: vm
                            )
                            
                            // 실제 NavigationLink는 숨김
                            NavigationLink(
                                destination: ChatDetailView(
                                    chat: chat,
                                    currentUserId: currentUserId,
                                    userStore: userStore
                                )
                            ) {
                                EmptyView()
                            }
                            .opacity(0) // 꺽새 포함 전체를 투명화
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.top, 10)


                
                
//                List {
//                    ForEach(filteredChats) { chat in
//                        NavigationLink(
//                            destination: ChatDetailView(
//                                chat: chat,
//                                currentUserId: currentUserId,
//                                userStore: userStore
//                            )
//                        ) {
//                            ChatRow(
//                                chat: chat,
//                                currentUserId: currentUserId,
//                                userStore: userStore,
//                                vm: vm
//                            )
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//                .listStyle(PlainListStyle())
//                .padding(.top, 10)

                
            }
            .background(Color.backgroundGray100)
            .onAppear {                               // 나중에 살려야 한다!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
                let listingTitle = chat.listingTitle.lowercased()
                let query = searchText.lowercased()

                return otherName.lowercased().contains(query) || listingTitle.contains(query)
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
            // MARK: -프로필
            // 프로필 이미지
            // 실제 이미지 불러와 지는 지  db에 값 올리고 확인
            AsyncImage(url: URL(string: userStore.users[otherUserId]?.photoUrl ?? "")) { image in
                image
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: 45, height: 45)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 45, height: 45)
            }
            .background(Color.clear) // 배경 투명
            .padding(.trailing, 3)
            
//            VStack(alignment: .leading) {
//                Text(userStore.users[otherUserId]?.name ?? "Unknown")
//                    .font(.headline)
//                Text(chat.lastMessage ?? "")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .lineLimit(1)
//            }
            VStack(alignment: .leading, spacing: 4) {
                
               // 이름 + 차량 타이틀
               HStack {
                   Text(userStore.users[otherUserId]?.name ?? "Unknown")
                       .font(.headline)
                       .lineLimit(1)
                   Spacer()
                   
                   // listing 제목
                   Text(chat.listingTitle)
                       .font(.subheadline)
                       .foregroundColor(.gray)
                       .lineLimit(1)                   // 한 줄로 제한
                       .allowsTightening(true)         // 글자 단위로 줄이기
                       .truncationMode(.tail)          // 공간 부족하면 끝에서 ... 표시
//                       .frame(maxWidth: .infinity, alignment: .trailing)  // 오른쪽 끝 고정
               }
                
                

               // 마지막 메시지
               Text(chat.lastMessage ?? "")
                   .font(.subheadline)
                   .foregroundColor(.gray)
                   .lineLimit(1)
           }
            
            

//            Spacer()
//
//            VStack(alignment: .trailing) {
//                Text(chat.lastAt, style: .time)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//
//                if let unread = vm.unreadCounts[chat.id ?? ""], unread > 0 {
//                    Text("\(unread)")
//                        .font(.caption2)
//                        .padding(6)
//                        .background(Circle().fill(Color.blue))
//                        .foregroundColor(.white)
//                }
//            }

            // 시간 + 안 읽은 메시지
             VStack(alignment: .trailing, spacing: 4) {
                 Text(formattedDate(chat.lastAt))
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
             .fixedSize() // ❗ 오른쪽 공간 최소화
            
//            VStack(alignment: .trailing, spacing: 4) {
//                Text(formattedDate(chat.lastAt))
//                    .font(.caption)
//                    .foregroundColor(.gray)
//
//                if let unread = vm.unreadCounts[chat.id ?? ""], unread > 0 {
//                    Text("\(unread)")
//                        .font(.caption2)
//                        .padding(6)
//                        .background(Circle().fill(Color.blue))
//                        .foregroundColor(.white)
//                } else {
//                    // 빈 공간 확보 (안 읽은 메시지 없을 때도 위치 유지)
//                    Color.clear
//                        .frame(height: 20)
//                }
//            }

        }
        .padding(.vertical, 8)
        .onAppear {                                             // ui 디자인 용
            userStore.fetchUser(userId: otherUserId)            // 활성화 하면 프리뷰는 안나오게 됨   -> 실제 앱에선 꼭 사용!!!!!!!!!!
        }
    }
}

// lastAt 날짜 포맷
func formattedDate(_ date: Date) -> String {
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    if calendar.isDateInToday(date) {
        formatter.dateFormat = "HH:mm"
    } else if calendar.isDate(date, equalTo: Date(), toGranularity: .year) {
        formatter.dateFormat = "M월 d일"
    } else {
        formatter.dateFormat = "yyyy년"
    }
    return formatter.string(from: date)
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
                listingTitle: "현대 더 뉴 그랜저 2.5 가솔린",
                lastAt: Date()
            ),
            Chat(
                id: "chat_002",
                buyerId: "user_001",
                sellerId: "user_003",
                listingId: "listing_xyz",
                lastMessage: "구매 가능한가요?",
                listingTitle: "현대 팰리세이드 2.2 디젤 7인승 익스클루시브",
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
