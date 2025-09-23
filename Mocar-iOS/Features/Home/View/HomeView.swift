//
//  HomeView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import SwiftUI

//struct HomeView: View {
//    //@StateObject private var favoritesViewModel = DIContainer.shared.favoritesVM
//    @StateObject private var homeViewModel =  DIContainer.shared.homeVM
//    @StateObject private var brandViewModel = CarBrandViewModel()
//    @StateObject private var userSession = UserSession()
//    //@State private var selectedBrand: CarBrand? = nil
//    @State private var showLogin = false
//    
//    init(){
//        //FavoritesviewModel을 먼저 만들고 HomeViewModel에 주입
//        //let favVM = FavoritesViewModel()
//        let repository = ListingRepository()
//        let service = HomeServiceImpl(repository: repository)
//        //_favoritesViewModel = StateObject(wrappedValue: favVM)
//        _homeViewModel = StateObject(wrappedValue: HomeViewModel(service: service/*, favoritesViewModel: favVM*/))
//   }
//
//    var body: some View {
//        NavigationStack{
//            VStack {
//                TopBar(
//                    style: .home(isLoggedIn: userSession.user != nil),
//                    onLoginTap:{showLogin = true}
//                )
//                NavigationLink(
//                    destination: LoginView()
//                        .navigationBarHidden(true)       // 기본 네비게이션 바 숨김
//                        .navigationBarBackButtonHidden(true),
//                    isActive: $showLogin
//                ) {
//                    EmptyView()
//                }
//                
//                HStack{
//                    //검색 창
//                    ZStack(alignment: .leading){
//                        Image("Search")
//                            .padding(.leading,15)
//                        TextField("Search", text: .constant(""))
//                            .padding(.leading, 30)
//                            .padding()
//                            .frame(height: 50)
//                            .background(RoundedRectangle(cornerRadius: 8)
//                                .stroke(Color.gray, lineWidth: 1)
//                            )
//                    }
//                    //검색 필터 버튼
//                    Button(action:{
//                        
//                    }){
//                        Image("iconfilter")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 20, height: 20) // 아이콘 크기
//                            .foregroundColor(.white)
//                            .padding()
//                    }
//                    .frame(height: 50)
//                    .background(
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color.blue)
//                    )
//                }
//                .padding(.vertical,16)
//                
//                ScrollView(showsIndicators: false){
//                    //찜한 목록
//                    VStack(alignment: .leading, spacing: 8){
//                        Text("찜한 목록")
//                            .font(.headline)
//                        Text("Available")
//                            .foregroundColor(.gray)
//                            .font(.subheadline)
//                        
//                        //리스트
//                        ScrollView(.horizontal, showsIndicators: false){
////                            HStack(spacing: 16) {
////                                ForEach(favoritesViewModel.favorites,id: \.safeId) { favorite in
////                                    if let listing = homeViewModel.listings.first(where: {$0.id == favorite.listingId}){
////                                        NavigationLink(
////                                            destination: ListingDetailView(
////                                                    viewModel: ListingDetailViewModel(
////                                                        service: ListingServiceImpl(repository: ListingRepository()),
////                                                        favoritesViewModel: favoritesViewModel
////                                                    ),
////                                                    listingId: listing.id ?? ""
////                                                )
////                                        ) {
////                                            FavoriteCardView(
////                                                listing: listing,
////                                                isFavorite: favoritesViewModel.isFavorite(listing),
////                                                onToggleFavorite:{
////                                                    favoritesViewModel.toggleFavorite(listing)
////                                                }
////                                            )
////                                        }
////                                         .buttonStyle(PlainButtonStyle())
////                                    }
////                                    
////                                }
////                            }
//                        }
//                    }
//                    .padding(.bottom,16)
//                    
//                    //브랜드 스크롤
//                    VStack(alignment: .leading, spacing: 8){
//                        Text("Brands")
//                            .font(.headline)
//                            .padding(.bottom,8)
//                        ScrollView(.horizontal, showsIndicators: false){
//                            HStack(spacing: 16) {
//                                ForEach(brandViewModel.brands) { brand in
//                                    BrandIconView(
//                                        brand: brand,
//                                        isSelected: homeViewModel.selectedBrand?.id == brand.id,  // 선택 여부
//                                        onSelect: {
//                                            homeViewModel.selectedBrand = brand
//                                            print("\(brand) selected")
//                                        }
//                                    )
//                                }
//                            }
//                        }
//                        .task {
//                            await brandViewModel.loadBrands()
//                        }
//                        .padding(.bottom,16)
//                        //브랜드 필터링 리스트
//                        LazyVGrid(columns: [
//                            GridItem(.flexible()), // 첫 번째 열
//                            GridItem(.flexible())  // 두 번째 열
//                        ], spacing: 16) {
////                            ForEach(homeViewModel.filteredListings, id: \.safeId) { listing in
////                                let detailView = ListingDetailView(
////                                    listingId: listing.id ?? "",
////                                    favoritesViewModel: homeViewModel.favoritesViewModel,
////                                    service: ListingServiceImpl(repository: ListingRepository())
////                                )
////
////                                NavigationLink(destination: detailView) {
////                                    VerticalListingCardView(
////                                        listing: listing,
////                                        isFavorite: favoritesViewModel.isFavorite(listing),
////                                        onToggleFavorite: {
////                                            favoritesViewModel.toggleFavorite(listing)
////                                        }
////                                    )
////                                }
////                                .buttonStyle(PlainButtonStyle())
////                            }
//                            
//                            
//                            
//
//                            ForEach(homeViewModel.filteredListings, id: \.safeId) { listing in
//                                NavigationLink(
//                                    destination: ListingDetailView(
//                                        service: ListingServiceImpl(repository: ListingRepository()),
//                                        listingId: listing.id ?? ""
//                                    )
//                                ){
//                                    ListingCardView(
//                                        listing: listing,
//                                        isFavorite:false,
//                                        onToggleFavorite:{
//                                            print("하트눌림")
//                                        }
//                                    )
//                                }
//                                .buttonStyle(PlainButtonStyle())
//                            }
//                        }
//                    }
//                }
//                
//            }
//            .padding()
//            .background(Color.backgroundGray100)
//            .task {
//                await homeViewModel.fetchListings()
//            }
//        }
//        .navigationBarHidden(true)
//        .background(Color.backgroundGray100)
//        
//    }
//   
//}

import SwiftUI

struct HomeView: View {
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var userSession = UserSession()
    @State private var showLogin = false
    
    init() {
        let repository = ListingRepository()
        let service = HomeServiceImpl(listingRepository: repository)
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(service: service))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TopBar(
                    style: .home(isLoggedIn: userSession.user != nil),
                    onLoginTap: { showLogin = true }
                )
                NavigationLink(
                    destination: LoginView()
                        .navigationBarHidden(true)
                        .navigationBarBackButtonHidden(true),
                    isActive: $showLogin
                ) { EmptyView() }
                
                //검색창 + 필터 버튼
                HStack {
                    ZStack(alignment: .leading) {
                        Image("Search")
                            .padding(.leading, 15)
                        TextField("Search", text: .constant(""))
                            .padding(.leading, 30)
                            .padding()
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    
                    Button(action: {
                        // TODO: 필터 기능 구현
                    }) {
                        Image("iconfilter")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(Color.blue)
                    )
                }
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    // 브랜드 선택
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Brands")
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(homeViewModel.brands) { brand in
                                    BrandIconView(
                                        brand: brand,
                                        isSelected: homeViewModel.selectedBrand?.id == brand.id,
                                        onSelect: {
                                            Task { await homeViewModel.loadListings(for: brand) }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.bottom, 16)
                        
                        // 브랜드별 매물 리스트
                        if homeViewModel.isLoading {
                            ProgressView("불러오는 중...")
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ],
                                spacing: 16
                            ) {
                                ForEach(homeViewModel.brandListings, id: \.safeId) { listing in
                                    NavigationLink(
                                        destination: ListingDetailView(
                                            service: ListingServiceImpl(repository: ListingRepository()),
                                            listingId: listing.id ?? ""
                                        )
                                    ) {
                                        ListingCardView(
                                            listing: listing,
                                            isFavorite: false,   // 아직 찜하기 미구현
                                            onToggleFavorite: {
                                                print("찜 버튼 눌림: \(listing.title)")
                                            }
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.backgroundGray100)
            .task {
                await homeViewModel.loadBrands()   // 앱 시작 시 브랜드와 첫 브랜드 매물 로드
            }
        }
        .navigationBarHidden(true)
        .background(Color.backgroundGray100)
    }
}
