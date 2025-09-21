//
//  Userstore.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import Foundation
import FirebaseFirestore

class UserStore: ObservableObject {
    @Published var users: [String: User] = [:]   // [userId: User]
    private var db = Firestore.firestore()

    func fetchUser(userId: String) {
        if users[userId] != nil { return } // 이미 있으면 패스

        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("❌ Failed to fetch user: \(error)")
                return
            }
            if let user = try? snapshot?.data(as: User.self) {
                DispatchQueue.main.async {
                    self.users[userId] = user
                }
            }
        }
    }
    
    func getUser(userId: String) -> User? {
        return users[userId]
    }
}
