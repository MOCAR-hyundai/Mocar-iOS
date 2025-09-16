//
//  UserSession.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class UserSession: ObservableObject {

    @Published var user: User? = nil   // Firestore User
      
      private var handle: AuthStateDidChangeListenerHandle?
      
      init() {
          handle = Auth.auth().addStateDidChangeListener { [weak self] _, authUser in
              guard let self = self else { return }
              if let authUser = authUser {
                  Task {
                      await self.loadFirestoreUser(uid: authUser.uid)
                  }
              } else {
                  self.user = nil
              }
          }
      }
      
      func loadFirestoreUser(uid: String) async {
          let db = Firestore.firestore()
          do {
              let doc = try await db.collection("users").document(uid).getDocument()
              let firestoreUser = try doc.data(as: User.self)  // 옵셔널 바인딩 제거
              self.user = firestoreUser
          } catch {
              print("Firestore 유저 불러오기 실패:", error.localizedDescription)
          }
      }

      
      func signOut() {
          try? Auth.auth().signOut()
          user = nil
      }
}
