//
//  CarInfoView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct CarInfoView: View {
    let listing: Listing
    var body: some View {
        VStack(alignment: .leading,spacing: 4) {
      
            Text(listing.model)
                .fontWeight(.semibold)
                .foregroundColor(.textBlack100)
            HStack{
                Text("\(listing.mileage)Km")
                    .foregroundColor(.textGray100)
                Image("iconlocation")
                    .resizable()
                    .frame(width: 13, height: 15)
                Text(listing.region)
                    .foregroundColor(.textGray100)
            }
            Text("\(listing.priceInManwon)만원")
                .padding(.top,4)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color.keyColorBlue)
            
        }
        .padding(10)
    }
}

#Preview {
    //CarInfoView()
}
