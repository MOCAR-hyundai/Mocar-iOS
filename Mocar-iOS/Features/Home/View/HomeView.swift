//
//  HomeView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/16/25.
//

import SwiftUI


struct HomeView: View {
//    @StateObject private var homeViewModel: HomeViewModel
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    @StateObject private var userSession = UserSession()
    @State private var showLoginModal = false
    @State private var navigateToLogin = false
    
    @State private var showLogin = false
    @State private var showSearch = false
    @State private var showFilter = false

    
//    init() {
//        let listingRepo = ListingRepository()
//        
//        _homeViewModel = StateObject(
//            wrappedValue: HomeViewModel(
//                service: HomeServiceImpl(listingRepository: listingRepo)
//            )
//        )
//    }
    @StateObject private var homeViewModel = HomeViewModel(
        service: HomeServiceImpl(listingRepository: ListingRepository())
    )
    
    var onSearchTap: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: - TopBar + 로그인 이동
                TopBar(
                    style: .home(isLoggedIn: userSession.user != nil),
                    onLoginTap: { showLogin = true }
                )
                .padding(12)
                
                NavigationLink(
                    destination: LoginView()
                        .navigationBarHidden(true)
                        .navigationBarBackButtonHidden(true),
                    isActive: $showLogin
                ) { EmptyView() }
                
                // MARK: - 검색창 + 필터 버튼
                HStack {
                    // 검색창
                    Button {
//                        showSearch = true
                        onSearchTap?()
                    } label: {
                        HStack {
                            Image("Search")
                                .padding(.leading, 8)

                            Text("Search")
                                .foregroundColor(.gray)
                                .padding(.leading, 8)

                            Spacer()
                        }
                        .padding()
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }

                    // 필터 버튼
                    Button {
//                        showFilter = true
                        onSearchTap?()
                    } label: {
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
                .padding(.horizontal)
                .padding(.bottom, 8)

                //  네비게이션 전환
                .navigationDestination(isPresented: $showSearch) {
                    SearchView(viewModel: SearchDetailViewModel())
                }
                .navigationDestination(isPresented: $showFilter) {
                    SearchView(viewModel: SearchDetailViewModel())
                }

                
                // MARK: - 본문
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // 찜한 매물 섹션
                        if !favoritesVM.favoriteListings.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("찜한 목록")
                                    .font(.headline)
                                Text("Available")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(favoritesVM.favoriteListings, id: \.safeId) { listing in
                                            NavigationLink(
                                                destination: ListingDetailView(
                                                    service: ListingServiceImpl(repository: ListingRepository(),                         userStore: UserStore()                         ),
                                                    listingId: listing.id ?? ""
                                                )
                                            ) {
                                                FavoriteCardView(
                                                    listing: listing,
                                                    isFavorite: favoritesVM.isFavorite(listing),
                                                    onToggleFavorite: {
                                                        if let _ = userSession.user {
                                                            Task { await favoritesVM.toggleFavorite(listing) }
                                                        } else {
                                                            withAnimation { showLoginModal = true }
                                                        }
                                                    }
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                        }
                        
                        //  브랜드 섹션
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
                                                service: ListingServiceImpl(repository: ListingRepository(),
                                                     userStore: UserStore()),
                                                listingId: listing.id ?? ""
                                            )
                                        ) {
                                            VerticalListingCardView(
                                                listing: listing,
                                                isFavorite: favoritesVM.isFavorite(listing),
                                                onToggleFavorite: {
                                                    if let _ = userSession.user {
                                                        Task { await favoritesVM.toggleFavorite(listing) }
                                                    } else {
                                                        withAnimation { showLoginModal = true }
                                                    }
                                                }
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.backgroundGray100)
                    .onAppear {
                        if homeViewModel.brands.isEmpty {
                            Task { await homeViewModel.loadBrands() }
                        }
                    }
                }
                .navigationBarHidden(true)
                .background(Color.backgroundGray100)
                .overlay {
                    if showLoginModal {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        ConfirmModalView(
                            message: "로그인 이후 사용 가능합니다.",
                            confirmTitle: "로그인",
                            cancelTitle: "취소",
                            onConfirm: {
                                showLoginModal = false
                                navigateToLogin = true
                            },
                            onCancel: {
                                showLoginModal = false
                            }
                        )
                    }
                }
                .background(Color.clear) // 배경 투명
                .transition(.opacity) // 부드럽게 등장
                .animation(.easeInOut, value: showLoginModal)
                .navigationDestination(isPresented: $navigateToLogin){
                    LoginView()
                }
            }

        }
        .background(Color.backgroundGray100)
        
    }
}
