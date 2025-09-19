//
//  ChatDetailView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import SwiftUI
import FirebaseFirestore

struct ChatDetailView: View {
    let chat: Chat
    let currentUserId: String
    @ObservedObject var userStore: UserStore
    
    @State private var messages: [Message] = []
    @State private var messageText: String = ""
    
    private let db = Firestore.firestore()
    @State private var messagesListener: ListenerRegistration? // 🔥 리스너 저장
    
    var otherUserId: String {
        chat.buyerId == currentUserId ? chat.sellerId : chat.buyerId
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(messages) { message in
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
            HStack {
                TextField("메시지를 입력하세요...", text: $messageText)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Button(action: sendMessage) {
                    Text("전송")
                        .bold()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle(userStore.users[otherUserId]?.name ?? "Unknown")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            userStore.fetchUser(userId: otherUserId)
//            fetchMessages()
            startListeningMessages()   // ✅ 리스너 시작

        }
        .onDisappear {
            stopListeningMessages()    // ✅ 리스너 해제
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
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty,
              let chatId = chat.id else { return }
        
//        // 1️⃣ 메시지 문서 ID 생성
//           let newMessageRef = db.collection("chats")
//               .document(chatId)
//               .collection("messages")
//               .document()
//           
//           let now = Date()
//           
//           let newMessage = Message(
//               id: newMessageRef.documentID,
//               senderId: currentUserId,
//               text: messageText,
//               imageUrl: nil,
//               createdAt: now,
//               readBy: [currentUserId] // 전송한 사람은 이미 읽음
//           )
//        
//            let messageTextToSave = newMessage.text ?? ""
//           
//           do {
//               // 2️⃣ Firestore 저장
//               try newMessageRef.setData(from: newMessage)
//               messageText = ""
//               
//               // 3️⃣ Chat 마지막 메시지 업데이트
//               db.collection("chats").document(chatId).updateData([
//                   "lastMessage": messageTextToSave,
//                   "lastAt": now
//               ])
        
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

//                let messageRef = db.collection("chats")
//                    .document(chatId)
//                    .collection("messages")
//                    .document(messageId)
//                
//                messageRef.updateData([
//                    "readBy": FieldValue.arrayUnion([currentUserId])
//                ])
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
            // 텍스트 또는 이미지
            if let text = message.text {
                Text(text)
                    .padding(10)
                    .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .cornerRadius(12)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: isCurrentUser ? .trailing : .leading)
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

