//
//  MyListingsViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import SwiftUI
import FirebaseFirestore

class MyListingsViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    private var db = Firestore.firestore()

    func fetchMyListings(userId: String) {
        db.collection("listings")
            .whereField("sellerId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(" Error fetching listings: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self.listings = documents.compactMap { doc in
                    try? doc.data(as: Listing.self)
                }
                .filter { $0.status.rawValue != "draft" } //  draft 제외
            }
    }
}
