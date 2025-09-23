//
//  DiContainer.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

//import Foundation
//final class DIContainer {
//    static let shared = DIContainer()   // 싱글톤으로 앱 전역에서 사용
//    
//    private init() {}
//    
//    // Repository
//    private let listingRepository = ListingRepository()
//    private let favoriteRepository = FavoriteRepository()
//    
//    // ViewModels
//    lazy var favoritesVM: FavoritesViewModel = {
//        FavoritesViewModel(
//            listingRepository: listingRepository,
//            favoriteRepository: favoriteRepository
//        )
//    }()
//    
//    lazy var homeVM: HomeViewModel = {
//        let homeService = HomeServiceImpl(repository: listingRepository)
//        return HomeViewModel(
//            service: homeService,
//           // favoritesViewModel: favoritesVM
//        )
//    }()
//}
