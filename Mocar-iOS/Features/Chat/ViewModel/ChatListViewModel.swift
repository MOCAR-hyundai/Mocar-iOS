//
//  ChatListViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import Foundation
import FirebaseFirestore

class ChatListViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var unreadCounts: [String: Int] = [:] // chatId -> 안 읽은 개수
    
    @Published var currentUserPhotoUrl: String? = nil   // 사용자 프로필 이미지

    private var db = Firestore.firestore()
    private var chatListener: ListenerRegistration?
    private var messageListeners: [String: ListenerRegistration] = [:]
    
    func fetchChats(for userId: String) {
        
        //확인용
        print("🔹 fetchChats called for userId: \(userId)")
        
        // 먼저 로그인한 사용자 프로필 가져오기
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("❌ Failed to fetch user profile: \(error)")
                return
            }
            if let data = snapshot?.data(),
               let photoUrl = data["photoUrl"] as? String {
                DispatchQueue.main.async {
                    self.currentUserPhotoUrl = photoUrl
                }
            }
        }
        
        chatListener?.remove()
        chatListener = db.collection("chats")
            .order(by: "lastAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Failed to fetch chats: \(error)")
                    return
                }
                guard let docs = snapshot?.documents else { return }
                let allChats = docs.compactMap { try? $0.data(as: Chat.self) }

                // 🔥 buyerId나 sellerId 중 내가 포함된 것만 필터링
                self.chats = allChats.filter { chat in
                    chat.buyerId == userId || chat.sellerId == userId
                }

                // 각 채팅방 안 읽은 메시지 리스너 등록
                for chat in self.chats {
                    self.listenForUnreadMessages(chatId: chat.id ?? "",
                                                 currentUserId: userId)
                }
            }
    }



    private func listenForUnreadMessages(chatId: String, currentUserId: String) {
        // 기존 리스너 제거
        messageListeners[chatId]?.remove()
        
        let listener = db.collection("chats")
            .document(chatId)
            .collection("messages")
           // .order(by: "createdAt", descending: false) // 메시지 순서 보장
            .addSnapshotListener { snapshot, error in
                if let error = error {
                         print("❌ Failed to fetch messages: \(error)")
                         return
                     }
                     
                     guard let docs = snapshot?.documents else { return }
                     
//                     // 안 읽은 메시지 카운트 계산
//                     let unreadCount = docs.reduce(0) { count, doc in
//                         let readBy = doc["readBy"] as? [String] ?? []
//                         return readBy.contains(currentUserId) ? count : count + 1
//                     }
//
                    // 안 읽은 메시지 카운트
                   var unreadCount = 0
                   for doc in docs {
                       let data = doc.data()
                       let senderId = data["senderId"] as? String ?? ""
                       let readBy = data["readBy"] as? [String] ?? []
                       
                       //  내가 보낸 건 제외 + 내가 아직 안 읽은 것만 카운트
                       if senderId != currentUserId && !readBy.contains(currentUserId) {
                           unreadCount += 1
                       }
                   }
                
                     DispatchQueue.main.async {
                         self.unreadCounts[chatId] = unreadCount
                     }
                 }
//                if let error = error {
//                    print(" Failed to fetch messages for chat \(chatId): \(error)")
//                    return
//                }
//                
//                guard let docs = snapshot?.documents else {
//                    DispatchQueue.main.async {
//                        self.unreadCounts[chatId] = 0
//                    }
//                    return
//                }
//                
//                // 안 읽은 메시지 카운트 계산
//                let unreadCount = docs.reduce(0) { count, doc in
//                    let readBy = doc["readBy"] as? [String] ?? []
//                    return count + (readBy.contains(currentUserId) ? 0 : 1)
//                }
//                
//                // 메인 스레드에서 업데이트
//                DispatchQueue.main.async {
//                    self.unreadCounts[chatId] = unreadCount
//                }
//            }
        
        messageListeners[chatId] = listener
    }

    
//    private func listenForUnreadMessages(chatId: String, currentUserId: String) {
//        // 중복 리스너 제거
//        messageListeners[chatId]?.remove()
//
//        let listener = db.collection("chats")
//            .document(chatId)
//            .collection("messages")
//            .addSnapshotListener { snapshot, error in
//                if let error = error {
//                    print(" Failed to fetch messages: \(error)")
//                    return
//                }
//                guard let docs = snapshot?.documents else { return }
//
//                // 내가 안 읽은 메시지만 필터링
//                let unreadMessages = docs.filter { doc in
//                    let readBy = doc["readBy"] as? [String] ?? []
//                    return !readBy.contains(currentUserId)
//                }
//
//                DispatchQueue.main.async {
//                    self.unreadCounts[chatId] = unreadMessages.count
//                }
//            }
//
//        messageListeners[chatId] = listener
//    }

/**
    private func listenForUnreadMessages(chatId: String, currentUserId: String) {
        // 중복 리스너 제거
        messageListeners[chatId]?.remove()

        let listener = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .whereField("readBy", arrayContains: currentUserId) // 읽은 건 빼고
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print(" Failed to fetch unread messages: \(error)")
                    return
                }

                let totalMessages = snapshot?.count ?? 0
                let unreadCount = max(0, totalMessages - (snapshot?.documents.count ?? 0))
                DispatchQueue.main.async {
                    self.unreadCounts[chatId] = unreadCount
                }
            }

        messageListeners[chatId] = listener
    }
 */
    
    deinit {
        chatListener?.remove()
        messageListeners.values.forEach { $0.remove() }
    }
}
