//
//  OrdersCardView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import SwiftUI


struct OrdersCardView: View {
    let order: Order
    let listing: Listing
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        BaseListingCardView(
            listing: listing,
            isFavorite: isFavorite,
            onToggleFavorite: onToggleFavorite
        ) {
            statusSection()
        }
    }
    
    @ViewBuilder
    private func statusSection() -> some View {
        switch order.status {
        case .sold:
            VStack(alignment: .leading, spacing: 2) {
                if let soldAt = order.soldAt {
                    Text("판매일: \(formatDateString(soldAt))")
                        .foregroundColor(.green)
                        .font(.system(size: 11))
                }
                if let contractPrice = order.contractPrice {
                    Text("구입가 : \(NumberFormatter.koreanPriceString(from: contractPrice))")
                        .foregroundColor(.keyColorBlue)
                        .font(.system(size: 11, weight: .semibold))
                }
            }
            
        case .reserved:
            VStack(alignment: .leading, spacing: 2) {
                if let reservedAt = order.reservedAt {
                    Text("예약일: \(formatDateString(reservedAt))")
                        .foregroundColor(.orange)
                        .font(.system(size: 11))
                }
                Text("판매가 : \(NumberFormatter.koreanPriceString(from: listing.price))")
                    .foregroundColor(.keyColorBlue)
                    .font(.system(size: 11, weight: .semibold))
            }
        }
    }
}

