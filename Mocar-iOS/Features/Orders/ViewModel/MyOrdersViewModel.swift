//
//  MyOrdersViewModel.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import Foundation
import FirebaseFirestore

struct OrderWithListing: Identifiable {
    var id: String { order.orderId }
    let order: Order
    let listing: Listing
}

class MyOrdersViewModel: ObservableObject {
    @Published var myOrders: [OrderWithListing] = []
    
    private let db = Firestore.firestore()
    
    func fetchMyOrders(for uid: String) {
        db.collection("orders")
            .whereField("buyerId", isEqualTo: uid)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching orders: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let orders: [Order] = documents.compactMap { doc in
                    try? doc.data(as: Order.self)
                }
                
                self.fetchListings(for: orders)
            }
    }
    
    private func fetchListings(for orders: [Order]) {
        let group = DispatchGroup()
        var temp: [OrderWithListing] = []
        
        for order in orders {
            group.enter()
            db.collection("listings").document(order.listingId)
                .getDocument { snapshot, error in
                    defer { group.leave() }
                    if let data = try? snapshot?.data(as: Listing.self) {
                        temp.append(OrderWithListing(order: order, listing: data))
                    }
                }
        }
        
        group.notify(queue: .main) {
            self.myOrders = temp
        }
    }
}
