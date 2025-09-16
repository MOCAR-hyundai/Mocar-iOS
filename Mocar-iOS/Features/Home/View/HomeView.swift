//
//  HomeView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import SwiftUI

let brandData: [Brand] = [
    Brand(name: "Ferrari", logo: "ferrari"),
    Brand(name: "Tesla", logo: "tesla"),
    Brand(name: "BMW", logo: "BMW"),
    Brand(name: "Kia", logo: "kia")
]

struct Brand : Identifiable {
    var id = UUID()
    var name: String
    var logo: String
}



struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    let listings: [Listing] = Listing.listingData
    

    var body: some View {
        NavigationStack{
            TopBar(style: .home)
            VStack {
                HStack{
                    ZStack(alignment: .leading){
                        Image("Search")
                            .padding(.leading,15)
                        TextField("Search", text: .constant(""))
                            .padding(.leading, 30)
                            .padding()
                            .frame(height: 50)
                            .background(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    Button(action:{
                        
                    }){
                        Image("iconfilter")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20) // 아이콘 크기
                            .foregroundColor(.white)
                            .padding()
                    }
                    .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                            )
                }
                .padding(.bottom,16)
                
                ScrollView(){
                    //찜한 목록
                    VStack(alignment: .leading, spacing: 8){
                        Text("찜한 목록")
                            .font(.headline)
                        Text("Available")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 16) {
                                ForEach(listings) { item in
                                    FavoriteCardView(listing: item, isFavorite: true)
                                        
                                }
                            }
                        }
                        
                        
                    }
                    .padding(.bottom,16)
                    
                    VStack(alignment: .leading, spacing: 8){
                        Text("Brands")
                            .font(.headline)
                            .padding(.bottom,8)
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 40) {
                                ForEach(brandData) { brand in
                                    BrandsIconView(
                                        brand: brand,
                                        isSelected: homeViewModel.selectedBrand == brand.name,   // 선택 여부
                                        onSelect: {
                                            homeViewModel.selectBrand(brand)
                                            print("\(brand.name) selected")
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.bottom,16)
                        
                        LazyVGrid(columns: [
                                GridItem(.flexible()), // 첫 번째 열
                                GridItem(.flexible())  // 두 번째 열
                            ], spacing: 16) {
                                ForEach(homeViewModel.filteredListings) { listing in
                                    ListingCardView(listing: listing, isFavorite: false)
                                }
                            }
                    }
                }
                
            }
            .padding()
        }
        
        
    }
}


struct FavoriteCardView: View{
    let listing: Listing
    let isFavorite: Bool
    
    var body: some View {
        VStack(alignment: .leading,spacing: 6) {
             ZStack(alignment: .topTrailing){
                Image("hyundai")
                 .resizable()
                 
                 Button(action: {
                    print("하트 클릭")
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                        .padding(8)
                }
             }
            
            Text(listing.model)
                .fontWeight(.semibold)
            HStack{
                Text("\(listing.mileage)Km")
                   .foregroundStyle(.gray)
                Image("iconlocation")
                    .resizable()
                    .frame(width: 13, height: 15)
                Text(listing.region)
                    .foregroundStyle(.gray)
            }
            Text("\(listing.price)만원")
                .padding(.top,4)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#3058EF"))
             
        }
        .padding(10)
         .overlay(
             RoundedRectangle(cornerRadius: 12)
                 .stroke(Color.gray, lineWidth: 1)
         )
         .cornerRadius(12)
         .frame(width: 170, height: 223)
         
    }
}

struct ListingCardView: View{
    let listing: Listing
    let isFavorite: Bool
    
    var body: some View {
        VStack(alignment: .leading,spacing: 6) {
             ZStack(alignment: .topTrailing){
                Image("hyundai")
                 .resizable()
                 
                 Button(action: {
                    print("하트 클릭")
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                        .padding(8)
                }
             }
            
            Text(listing.model)
                .fontWeight(.semibold)
            HStack{
                Text("\(listing.mileage)Km")
                   .foregroundStyle(.gray)
                Image("iconlocation")
                    .resizable()
                    .frame(width: 13, height: 15)
                Text(listing.region)
                    .foregroundStyle(.gray)
            }
            Text("\(listing.price)만원")
                .padding(.top,4)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#3058EF"))
             
        }
        .padding(10)
         .overlay(
             RoundedRectangle(cornerRadius: 12)
                 .stroke(Color.gray, lineWidth: 1)
         )
         .cornerRadius(12)
         .frame(width: 170, height: 223)
         
    }
}


struct BrandsIconView: View {
    let brand: Brand
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action:{
            onSelect()
        }){
            VStack{
                Image(brand.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                Text(brand.name)
                    .foregroundColor(Color(hex: "#7F7F7F"))
            }
        }
    }
}
#Preview {
    HomeView()
    //ListingCardView()
    //BrandsIconView(brand: brandData[0])
}
