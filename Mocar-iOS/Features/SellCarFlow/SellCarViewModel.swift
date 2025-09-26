//
//  SellCarViewModel.swift
//  Mocar-iOS
//
//  Created by wj on 9/16/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth


final class SellCarViewModel: ObservableObject {
    @Published var step: SellStep = .carNumber
    
    // 입력 데이터
    @Published var carNumber: String = ""
    @Published var ownerName: String = ""
    @Published var mileage: String = ""
    @Published var price: String = ""
    @Published var additionalInfo: String = ""
    @Published var photos: [UIImage] = []
    
    // Firestore에서 가져온 차량 정보
   @Published var listingId: String? = nil
   @Published var title: String = ""
   @Published var year: String = ""
   @Published var firstImageUrl: String = ""
    
    private let db = Firestore.firestore()
    
    
    // Step 이동
    func goNext() {
        if step.rawValue < SellStep.allCases.count - 1 {
            step = SellStep(rawValue: step.rawValue + 1) ?? step
        }
    }
    
    func goBack() {
        if step.rawValue > 0 {
            step = SellStep(rawValue: step.rawValue - 1) ?? step
        }
    }
    
    
    // MARK: - 차량 조회
    // 1) 차량번호로 Firestore에서 차량 정보 조회
        func fetchCarInfo() {
            db.collection("listings")
                .whereField("plateNo", isEqualTo: carNumber)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("차량 조회 실패: \(error)")
                        return
                    }
                    guard let doc = snapshot?.documents.first else {
                        print("해당 차량 없음")
                        return
                    }
                    self.listingId = doc.documentID
                    let data = doc.data()
                    self.title = data["title"] as? String ?? ""
//                    self.year = data["year"] as? String ?? ""
                    // 🔹 숫자/문자 모두 대응
                   if let yearNumber = data["year"] as? Int {
                       self.year = String(yearNumber)
                   } else if let yearDouble = data["year"] as? Double {
                       self.year = String(Int(yearDouble))
                   } else if let yearString = data["year"] as? String {
                       self.year = yearString
                   } else {
                       self.year = ""
                   }
                    
                    if let images = data["images"] as? [String], let first = images.first {
                        self.firstImageUrl = first
                    }
                }
        }
    

    // MARK: - 차량 등록
    func registerCar(completion: @escaping (Bool) -> Void) {
        guard let listingId = listingId,
              let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        //let now = ISO8601DateFormatter().string(from: Date())
        
        // 1) Storage 업로드 (photos가 비어있지 않을 때만)
        if !photos.isEmpty {
            let group = DispatchGroup()
            var uploadedURLs: [String] = []
            
            for image in photos {
                group.enter()
                uploadImageToStorage(image) { url in
                    if let url = url {
                        uploadedURLs.append(url)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                // 2) Firestore 업데이트
                let updateData: [String: Any] = [
                    "ownerName": self.ownerName,
                    "mileage": Int(self.mileage) ?? 0,
                    "price": Int(self.price) ?? 0,
                    "description": self.additionalInfo,
                    "sellerId": userId,
                    "status": "on_sale",
                    "createdAt": Date().toISO8601String(),
                    "updatedAt": Date().toISO8601String(),
                    "images": uploadedURLs   // ✅ 업로드된 URL 배열 저장
                ]
                
                self.db.collection("listings").document(listingId).updateData(updateData) { error in
                    if let error = error {
                        print("업데이트 실패: \(error)")
                        completion(false)
                    } else {
                        print("업데이트 성공")
                        completion(true)
                    }
                }
            }
        } else {
            // 사진 없으면 그냥 기존 로직
            let updateData: [String: Any] = [
                "ownerName": ownerName,
                "mileage": Int(mileage) ?? 0,
                "price": Int(price) ?? 0,
                "description": additionalInfo,
                "sellerId": userId,
                "status": "on_sale",
                "createdAt": Date().toISO8601String(),
                "updatedAt": Date().toISO8601String(),
            ]
            
            db.collection("listings").document(listingId).updateData(updateData) { error in
                if let error = error {
                    print("업데이트 실패: \(error)")
                    completion(false)
                } else {
                    print("업데이트 성공")
                    completion(true)
                }
            }
        }
    }
    
    // MARK: - 이미지 업로드 (Storage)
    private func uploadImageToStorage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        let filename = UUID().uuidString + ".jpg"
        let ref = Storage.storage().reference().child("listings/\(filename)")
        
        ref.putData(data, metadata: nil) { _, error in
            if let error = error {
                print("업로드 실패:", error.localizedDescription)
                completion(nil)
                return
            }
            ref.downloadURL { url, _ in
                completion(url?.absoluteString)
            }
        }
    }

    
    
}
