//
//  ChatDetailView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct ChatDetailView: View {
//    let chat: Chat
    @State var chat: Chat   // let → @State 로 변경
    let currentUserId: String
    @ObservedObject var userStore: UserStore
    
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var messages: [Message] = []
    @State private var messageText: String = ""
    
    
    @State private var isImagePickerPresented = false
    @State private var selectedImages: [UIImage] = []

    
    private let db = Firestore.firestore()
    @State private var messagesListener: ListenerRegistration? // 리스너 저장
    
    var otherUserId: String {
        chat.buyerId == currentUserId ? chat.sellerId : chat.buyerId
    }
    
    //  프리뷰용 init
      init(chat: Chat, currentUserId: String, userStore: UserStore, previewMessages: [Message] = []) {
          self.chat = chat
          self.currentUserId = currentUserId
          self.userStore = userStore
          _messages = State(initialValue: previewMessages)
      }
    
    var body: some View {
        VStack {
            // 탑 바
            HStack(spacing: 10) {
                        TopBar(style: .chat) // BackButton만 들어감

                        AsyncImage(url: URL(string: userStore.users[otherUserId]?.photoUrl ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()   // 프레임을 꽉 채움
                                .frame(width: 40, height: 40) // 정사각형 지정
                                .clipShape(Circle())          // 동그랗게 자르기
                                
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 40)
                        }
                        .frame(width: 40, height: 40)
                        
                        .clipShape(Circle())

                        Text(userStore.users[otherUserId]?.name ?? "Unknown")
                            .font(.system(size: 18, weight: .bold))

                        Spacer()
                    }
                    .padding(6)
                    .background(Color.backgroundGray100)
//            HStack {
//                Button(action: {
//                    // 뒤로가기 액션
//                    dismiss()
//                }) {
//                    Image(systemName: "chevron.left")
//                        .frame(width: 20, height: 20)
//                        .padding(12) // 아이콘 주변 여백
//                        .foregroundColor(.black)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 50) // 충분히 큰 값이면 원처럼 둥글게
//                                .stroke(Color.lineGray, lineWidth: 1) // 테두리 색과 두께
//                        )
//                }
//                
//                // 현재 유저의 프로필 이미지 실제 이미지 불러와 지는 지  db에 값 올리고 확인
//                AsyncImage(url: URL(string: userStore.users[otherUserId]?.photoUrl ?? "")) { image in
//                    image.resizable()
//                } placeholder: {
//                    Circle().fill(Color.gray.opacity(0.3))
//                }
//                .frame(width: 45, height: 45)
//                .clipShape(Circle())
//                
////                            Text("Chats")
//                Text(userStore.users[otherUserId]?.name ?? "Unknown")
//                    .font(.system(size: 18, weight: .bold, design: .default))
//                
//                Spacer()
//                
//                Image(systemName: "phone")
//                        .resizable()               // 이미지 크기 조절 가능하게
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 20, height: 20) // 원하는 크기로 설정
//                        .foregroundColor(.iconGray)
//                
//                
//                Button(action: {
//                    // 점 세개 액션
//                }) {
//                    Image("3Dot")
//                        .renderingMode(.template)        // 색 변경 가능하게
//                        .frame(width: 20, height: 20)
//                        .rotationEffect(.degrees(90)) // 90도 회전
//                        .padding(12) // 아이콘 주변 여백
//                        .foregroundColor(.iconGray)
//                }
//            }
//            .padding(.horizontal)
//            .padding(3)
//            .padding(.vertical, 6)
//            .padding(.bottom, 10)
//            .background(Color.backgroundGray100) // <- F8F8F8 배경


            
            
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 8) {
                        
//                        ForEach(messages) { message in
                        ForEach(messages.indices, id: \.self) { index in
                                     let message = messages[index]
                                     let previousMessage: Message? = index > 0 ? messages[index - 1] : nil
                                     
                                     // 날짜가 바뀌면 Separator 표시
                                     if let prev = previousMessage {
                                         if !isSameDay(prev.createdAt, message.createdAt) {
                                             DateSeparator(date: message.createdAt)
                                         }
                                     } else {
                                         // 첫 메시지일 때도 날짜 표시
                                         DateSeparator(date: message.createdAt)
                                     }
                            HStack(alignment: .bottom) {
                                if message.senderId == currentUserId {
                                    Spacer()
                                    MessageBubble(message: message, isCurrentUser: true)
                                } else {
                                    MessageBubble(message: message, isCurrentUser: false)
                                    Spacer()
                                }
                            }
                            .id(message.id ?? UUID().uuidString)
                        }
                    }
                    .padding()
                    .onChange(of: messages.count) { _ in
                        // 새 메시지 생기면 스크롤
                        if let lastId = messages.last?.id {
                            withAnimation {
                                scrollProxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                        markMessagesAsRead() // 뷰가 열려있을 때만 읽음 처리
                    }
                }
            }
            
            // 입력 영역
            
            // 선택 이미지 미리보기
                if !selectedImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(selectedImages.indices, id: \.self) { index in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: selectedImages[index])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)

                                    Button(action: {
                                        selectedImages.remove(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .offset(x: 5, y: -5)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            
            // 입력 바
               HStack(spacing: 8) {
                   Button(action: { isImagePickerPresented = true }) {
                       Image(systemName: "paperclip")
                           .resizable()
                           .frame(width: 23, height: 23)
                           .foregroundColor(.blue)
                   }
                   .sheet(isPresented: $isImagePickerPresented) {
                       PhotoPicker(images: $selectedImages) { images in
                           selectedImages.append(contentsOf: images)
                       }
                   }
                   
                   TextField("메시지를 입력하세요...", text: $messageText)
                       .padding(10)
                       .background(Color.gray.opacity(0.2))
                       .cornerRadius(10)

                   
                   Button(action: {
                       if !messageText.trimmingCharacters(in: .whitespaces).isEmpty {
                              sendMessage(text: messageText)
                          }

                       for img in selectedImages {
                           sendImageMessage(img)
                       }
                       selectedImages.removeAll()
                   }) {
                       Text("전송")
                           .bold()
                           .padding(.horizontal, 12)
                           .padding(.vertical, 8)
                           .background(Color.blue)
                           .foregroundColor(.white)
                           .cornerRadius(8)
                   }
       
                   
//                   Button(action: sendCombinedMessage) {
//                       Text("전송")
//                           .bold()
//                           .padding(.horizontal, 12)
//                           .padding(.vertical, 8)
//                           .background(Color.blue)
//                           .foregroundColor(.white)
//                           .cornerRadius(8)
//                   }
               }
               .padding()
            
            
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            userStore.fetchUser(userId: otherUserId)
            startListeningMessages()   //  리스너 시작
            
            // chat의 listingId로 리스팅 불러오기
//            listingVM.fetchListing(by: chat.listingId)
        }
        .onDisappear {
            stopListeningMessages()    //  리스너 해제
        }
        
    }
    
    // MARK: - 메시지 리스너
     private func startListeningMessages() {
         guard let chatId = chat.id else { return }
         
         // 혹시 기존 리스너 있으면 제거
         stopListeningMessages()
         
         messagesListener = db.collection("chats")
             .document(chatId)
             .collection("messages")
             .order(by: "createdAt", descending: false)
             .addSnapshotListener { snapshot, error in
                 guard let documents = snapshot?.documents else { return }
                 messages = documents.compactMap { doc -> Message? in
                     try? doc.data(as: Message.self)
                 }
             }
     }
     
     private func stopListeningMessages() {
         messagesListener?.remove()
         messagesListener = nil
     }

    // MARK: - Firestore 메시지 전송
//    private func sendMessage(text: String? = nil, imageUrl: String? = nil) {
//        guard let chatId = chat.id else { return }
//
//        let newMessage = Message(
//            id: nil,
//            senderId: currentUserId,
//            text: text ?? messageText,
//            imageUrl: imageUrl,
//            createdAt: Date(),
//            readBy: [currentUserId]
//        )
//
//        let messageTextToSave = newMessage.text ?? ""
//
//        do {
//            _ = try db.collection("chats")
//                .document(chatId)
//                .collection("messages")
//                .addDocument(from: newMessage) { error in
//                    if error == nil {
//                        // Chat 마지막 메시지 업데이트
//                        db.collection("chats").document(chatId).updateData([
//                            "lastMessage": messageTextToSave,
//                            "lastAt": newMessage.createdAt
//                        ])
//                    }
//                }
//
//            messageText = ""
//        } catch {
//            print("메시지 전송 실패: \(error.localizedDescription)")
//        }
//    }
    
    private func sendMessage(text: String? = nil, imageUrl: String? = nil) {
        let db = Firestore.firestore()
        
        // 메시지 내용 없으면 return
        let content = text ?? messageText
        guard !content.trimmingCharacters(in: .whitespaces).isEmpty || imageUrl != nil else { return }
        
        if let chatId = chat.id {
            //  기존 채팅방 있으면 그대로 메시지 전송
            saveMessage(chatId: chatId, text: content, imageUrl: imageUrl)
        } else {
            //  채팅방 없으면 새로 생성 후 첫 메시지 전송
            let chatRef = db.collection("chats").document()
            chat.id = chatRef.documentID   // @State라서 이제 업데이트 가능

            do {
                try chatRef.setData(from: chat)
                //  새 채팅방 만들자마자 리스너 시작
//                startListeningMessages()
            } catch {
                print("채팅방 생성 실패: \(error.localizedDescription)")
                return
            }
            
            saveMessage(chatId: chatRef.documentID, text: content, imageUrl: imageUrl)
        }
        
        messageText = ""
    }

    private func saveMessage(chatId: String, text: String?, imageUrl: String?) {
        let db = Firestore.firestore()
        
        let newMessage = Message(
            id: nil,
            senderId: currentUserId,
            text: text,
            imageUrl: imageUrl,
            createdAt: Date(),
            readBy: [currentUserId]
        )
        let messageTextToSave = newMessage.text ?? ""
        
        do {
            _ = try db.collection("chats")
                .document(chatId)
                .collection("messages")
                .addDocument(from: newMessage) { error in
                    if error == nil {
                        db.collection("chats").document(chatId).updateData([
                            "lastMessage": messageTextToSave,
                            "lastAt": newMessage.createdAt
                        ])
                    }
                }
            //  로컬에서도 바로 반영
            DispatchQueue.main.async {
                self.messages.append(newMessage)
            }
        } catch {
            print("메시지 저장 실패: \(error.localizedDescription)")
        }
    }


    // MARK: - 이미지 업로드 (Firebase Storage 예시)
    private func uploadImage(_ image: UIImage, completion: @escaping (String) -> Void) {
        let storageRef = Storage.storage().reference()
        let imageName = UUID().uuidString + ".jpg"
        let imageRef = storageRef.child("chatImages/\(imageName)")
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }

        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("이미지 업로드 실패: \(error.localizedDescription)")
                return
            }
            imageRef.downloadURL { url, error in
                if let url = url {
                    completion(url.absoluteString)
                }
            }
        }
    }
    
    // 이미지 전송
    private func sendImageMessage(_ image: UIImage) {
        guard let chatId = chat.id else { return }

        uploadImage(image) { imageUrl in
            let newMessage = Message(
                id: nil,
                senderId: currentUserId,
                text: nil,
                imageUrl: imageUrl,
                createdAt: Date(),
                readBy: [currentUserId]
            )

            do {
                _ = try db.collection("chats")
                    .document(chatId)
                    .collection("messages")
                    .addDocument(from: newMessage) { error in
                        if error == nil {
                            // lastMessage는 빈 문자열 처리
                            db.collection("chats").document(chatId).updateData([
                                "lastMessage": "",
                                "lastAt": newMessage.createdAt
                            ])
                        }
                    }
            } catch {
                print("이미지 전송 실패: \(error.localizedDescription)")
            }
        }
    }
    // MARK: - Firebase 메시지 불러오기
    private func fetchMessages() {
        guard let chatId = chat.id else { return }
        db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                messages = documents.compactMap { doc -> Message? in
                    try? doc.data(as: Message.self)
                }
                //markMessagesAsRead() // 불러오자마자 읽음 처리
            }
    }
    
    // MARK: - 메시지 전송
    /***
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty,
              let chatId = chat.id else { return }

        
        let newMessage = Message(
            id: nil,
            senderId: currentUserId,
            text: messageText,
            imageUrl: nil,
            createdAt: Date(),
            readBy: [currentUserId]
        )
        
        let messageTextToSave = newMessage.text ?? ""
        
        do {
            // 1) 메시지 저장
            _ = try db.collection("chats")
                .document(chatId)
                .collection("messages")
                .addDocument(from: newMessage){ error in
                    if error == nil {
                        // 2) Chat 컬렉션 lastMessage / lastAt 업데이트
                        db.collection("chats")
                            .document(chatId)
                            .updateData([
                                "lastMessage": messageTextToSave,
                                "lastAt": newMessage.createdAt
                            ])
                    }
                }
            
            messageText = ""
        } catch {
            print("메시지 전송 실패: \(error.localizedDescription)")
        }
    }
    */
    // MARK: - 상대방 메세지 읽음 처리
    private func markMessagesAsRead() {
        guard let chatId = chat.id else { return }
        
        for message in messages {
            // 상대방 메시지이고, 아직 내 UID가 없으면 업데이트
            if message.senderId != currentUserId,
               !(message.readBy.contains(currentUserId)),
               let messageId = message.id {
                
                db.collection("chats")
                    .document(chatId)
                    .collection("messages")
                    .document(messageId)
                    .updateData([
                        "readBy": FieldValue.arrayUnion([currentUserId])
                    ])
            }
        }
    }
}

// MARK: - 메시지 버블
struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
            // 텍스트 또는 이미지 + 시간
                HStack(alignment: .bottom, spacing: 1) {
                    if isCurrentUser {
                        Spacer()
                        // 내 메시지: 시간 왼쪽
                        Text(message.createdAt, style: .time) // Date를 바로 표시
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(.trailing, 2)

                        if let text = message.text {
                            Text(text)
                                .padding(10)
                                .background(Color.keyColorBlue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        } else if let imageUrl = message.imageUrl,
                                  let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7)
                                    .cornerRadius(12)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 100, height: 100)
                            }
                        }
                        
                    } else {

                        if let text = message.text {
                            Text(text)
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        } else if let imageUrl = message.imageUrl,
                                  let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7)
                                    .cornerRadius(12)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 100, height: 100)
                            }
                        }

                        // 상대방 메시지: 시간 오른쪽
                        Text(message.createdAt, style: .time)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(.leading, 2)
                        
                        Spacer()
                        
                    }
                }
            
            // 읽음 표시
            if isCurrentUser {
                HStack(spacing: 4) {
                    Image(systemName: message.readBy.count > 1 ? "checkmark.seal.fill" : "checkmark")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(message.readBy.count > 1 ? .green : .gray)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}


//MARK: -날짜 구분선
struct DateSeparator: View {
    let date: Date
    
    var body: some View {
        Text(date, formatter: dateFormatter)
            .font(.system(size: 14, weight: .semibold)) // 날짜 크기 조금 키움
            .foregroundColor(.gray)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            // 배경 투명으로 변경
            //.background(Color.gray.opacity(0.2))
            //.cornerRadius(8)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR") // 한국어
        formatter.dateFormat = "yyyy년 M월 d일" // 2025년 9월 19일
        return formatter
    }
}

// Helper: 같은 날인지 비교
private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
    let calendar = Calendar.current
    return calendar.isDate(date1, inSameDayAs: date2)
}






/***
// MARK: - Preview Mock Data
struct MockData {
    static let sampleChat = Chat(
        id: "chat_1",
        buyerId: "user_1",
        sellerId: "user_2",
        listingId: "listing_1",
        lastMessage: "안녕하세요!",
        listingTitle: "현대 아이오닉 5",
        lastAt: Date()
    )

    static let sampleMessages: [Message] = [
        Message(
            id: "msg_1",
            senderId: "user_1",
            text: "안녕하세요 ",
            imageUrl: nil,
            createdAt: Date().addingTimeInterval(-120),
            readBy: ["user_1"]
        ),
        Message(
            id: "msg_2",
            senderId: "user_2",
            text: "네, 반갑습니다 ",
            imageUrl: nil,
            createdAt: Date().addingTimeInterval(-60),
            readBy: ["user_1", "user_2"]
        ),
        Message(
            id: "msg_3",
            senderId: "user_1",
            text: "혹시 내일 시간 되시나요?",
            imageUrl: nil,
            createdAt: Date(),
            readBy: ["user_1"]
        )
    ]
}

// MARK: - Mock UserStore
class MockUserStore: UserStore {
    override init() {
        super.init()
        // 프리뷰용 더미 유저 등록
        self.users["user_1"] = User(id: "user_1", name: "나 (현아)")
        self.users["user_2"] = User(id: "user_2", name: "상대방")
    }

    override func fetchUser(userId: String) {
        // 프리뷰라서 Firestore 호출 안 함
    }
}

// MARK: - Preview Wrapper
struct ChatDetailView_PreviewWrapper: View {
    @StateObject private var mockUserStore = MockUserStore()
    @State private var messages = MockData.sampleMessages

    var body: some View {
        ChatDetailView(
            chat: MockData.sampleChat,
            currentUserId: "user_1",
            userStore: mockUserStore
        )
        .onAppear {
            // 프리뷰용 메시지 강제로 세팅
            // Firestore 리스너 대신
            DispatchQueue.main.async {
                // messages를 ChatDetailView 내부로 전달
                // 여기서는 messages를 @State로 바인딩하려면 View 자체를 수정해야 함
                // 또는 ChatDetailView를 preview 전용으로 messages를 받는 init 추가
            }
        }
    }
}

// MARK: - Preview
struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatDetailView_PreviewWrapper()
        }
    }
}

 */
