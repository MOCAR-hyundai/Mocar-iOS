//
//  MyPageViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class MyPageViewModel: ObservableObject {
    @Published var displayName: String = "로그인하세요"
    @Published var email: String = ""
    @Published var photoURL: String? = nil
    
    func fetchUser() {
        guard let user = Auth.auth().currentUser else {
            // 로그인 안 된 상태
            self.displayName = "로그인하세요"
            self.email = ""
            self.photoURL = nil
            return
        }
        
        self.email = user.email ?? ""
        
        // Firestore에서 사용자 정보 가져오기
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else { return }
            
            if let name = data["name"] as? String, !name.isEmpty {
                self.displayName = name
            }
            
            if let photoString = data["photoUrl"] as? String, !photoString.isEmpty {
                self.photoURL = photoString
            }
        }
    }
    
    
    func logout() {
          do {
              try Auth.auth().signOut()
              // 로그아웃 후 상태 초기화
              displayName = "로그인하세요"
              email = ""
              photoURL = nil
          } catch {
              print("로그아웃 실패: \(error.localizedDescription)")
          }
      }
    
}
