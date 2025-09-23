//
//  MyPageViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

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
    
    func updateProfileImage(_ image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("❌ 업로드 실패: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                storageRef.downloadURL { url, _ in
                    if let url = url {
                        Firestore.firestore().collection("users").document(uid).updateData([
                            "photoUrl": url.absoluteString
                        ])
                        DispatchQueue.main.async {
                            self.photoURL = url.absoluteString
                            completion(true)  // ✅ 성공
                        }
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }

//    func updateProfileImage(_ image: UIImage) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
//        
//        if let imageData = image.jpegData(compressionQuality: 0.8) {
//            storageRef.putData(imageData, metadata: nil) { _, error in
//                if let error = error {
//                    print("❌ 업로드 실패: \(error.localizedDescription)")
//                    return
//                }
//                storageRef.downloadURL { url, _ in
//                    if let url = url {
//                        // Firestore에 photoURL 업데이트
//                        Firestore.firestore().collection("users").document(uid).updateData([
//                            "photoUrl": url.absoluteString
//                        ])
//                        DispatchQueue.main.async {
//                            self.photoURL = url.absoluteString
//                        }
//                    }
//                }
//            }
//        }
//    }
    
}
