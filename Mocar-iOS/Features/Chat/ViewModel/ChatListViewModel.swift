//
//  ChatListViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import Foundation
import FirebaseFirestore

import Foundation
import FirebaseFirestore

class ChatListViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var unreadCounts: [String: Int] = [:] // chatId -> 안 읽은 개수

    private var db = Firestore.firestore()
    private var chatListener: ListenerRegistration?
    private var messageListeners: [String: ListenerRegistration] = [:]

    func fetchChats(for userId: String) {
        chatListener?.remove()
        chatListener = db.collection("chats")
            .whereField("participants", arrayContains: userId)
            .order(by: "lastAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Failed to fetch chats: \(error)")
                    return
                }
                guard let docs = snapshot?.documents else { return }
                self.chats = docs.compactMap { try? $0.data(as: Chat.self) }

                // 각 채팅방의 안 읽은 메시지 카운트도 구독
                for chat in self.chats {
                    self.listenForUnreadMessages(chatId: chat.id ?? "",
                                                 currentUserId: userId)
                }
            }
    }

    private func listenForUnreadMessages(chatId: String, currentUserId: String) {
        // 중복 리스너 제거
        messageListeners[chatId]?.remove()

        let listener = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .whereField("readBy", arrayContains: currentUserId) // 읽은 건 빼고
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Failed to fetch unread messages: \(error)")
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

    deinit {
        chatListener?.remove()
        messageListeners.values.forEach { $0.remove() }
    }
}
