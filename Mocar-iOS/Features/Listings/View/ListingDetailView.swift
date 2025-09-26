//
//  ListingView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/15/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct ListingDetailView: View {
    @StateObject private var viewModel: ListingViewModel
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    @State private var navigateToLogin = false
    @State private var showLoginModal : Bool = false
    let listingId: String
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) private var dismiss

    
    init(service: ListingService, listingId: String) {
        _viewModel = StateObject(wrappedValue: ListingViewModel(service: service))
        self.listingId = listingId
    }

    // 채팅 관련 상태
    @StateObject private var userStore = UserStore()
    @State private var selectedChat: Chat? = nil
    @State private var isChatActive = false
    
    var body: some View {
        VStack {
            Group {
                if let detailData = viewModel.detailData {
                    content(detailData: detailData)
                } else {
                    loadingView()
                }
            }
            .task {
                if viewModel.detailData == nil {
                    await viewModel.loadListing(id: listingId)
                }
            }
            buyButton
                .padding()
        }

        .background(Color.backgroundGray100)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToLogin){
            LoginView()
        }
        .overlay{
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
                .background(Color.clear) // 배경 투명
                .transition(.opacity) // 부드럽게 등장
                .animation(.easeInOut, value: showLoginModal)
            }
            if showDeleteConfirm {
                Color.black.opacity(0.4).ignoresSafeArea()
                ConfirmModalView(
                    message: "정말 삭제하시겠습니까?",
                    confirmTitle: "삭제",
                    cancelTitle: "취소",
                    onConfirm: {
                        Task {
                            await viewModel.deleteListing()
                            showDeleteConfirm = false
                            dismiss()   // 삭제 후 이전 화면으로
                        }
                    },
                    onCancel: {
                        showDeleteConfirm = false
                    }
                )
                .background(Color.clear)
                .transition(.opacity)
                .animation(.easeInOut, value: showDeleteConfirm)
            }
        }
    }
    
    // MARK: - 본문 UI
    private func content(detailData: ListingDetailData) -> some View {
        VStack {
            TopBar(
                style: .listing(
                    title: detailData.listing.plateNo,
                    status: detailData.listing.status
                )
            )
            .padding()
            .overlay(alignment: .trailing) {
                HStack {
                    if let currentUserId = Auth.auth().currentUser?.uid,
                       currentUserId == detailData.listing.sellerId {
                        Menu {
                            Button("판매중") {
                                Task {
                                    await viewModel.changeStatus(to: .onSale, buyerId: "")
                                }
                            }
                            Button("예약중") {
                                Task {
                                    await viewModel.changeStatus(to: .reserved, buyerId: "")
                                }
                            }
                            Button("판매완료") {
                                if let chat = selectedChat {
                                    Task {
                                        await viewModel.changeStatus(to: .soldOut, buyerId: chat.buyerId)
                                    }
                                } else {
                                    print("ERROR -- 구매자 정보 없음 (chat이 nil)")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .padding(.trailing, 8)
                        }
                    }
                }
            }




            
            
            ScrollView(showsIndicators: false) {
                VStack {
                    // 차량 이미지 + 찜 버튼
                    ZStack(alignment: .topTrailing) {
                        CarImageTabView(images: detailData.listing.images)
                        FavoriteButton(
                            isFavorite: favoritesVM.isFavorite(detailData.listing),
                            onToggle: {
                                if let _ = Auth.auth().currentUser {   // 로그인 되어 있으면
                                    Task {
                                        await favoritesVM.toggleFavorite(detailData.listing)
                                    }
                                } else {   //  로그인 안 되어 있으면 모달 띄우기
                                    withAnimation {
                                        showLoginModal = true
                                    }
                                }
                            }
                        )
                    }
                    
                    basicInfo(detailData.listing)
                    
                    ProfileInfoView(seller: detailData.seller)
                        .padding(.horizontal)
                    
                    vehicleInfo(detailData.listing)
                    
                    descriptionView(detailData.listing)
                    
                    priceView(detailData)
                }
                .padding(.bottom, 90)
            }
            .background(Color.backgroundGray100)
        }
    }
    
    // MARK: - 하단 구매 문의 바
//    private var buyButton: some View {
//        HStack {
//            if let currentUserId = Auth.auth().currentUser?.uid,
//                let listing = viewModel.detailData?.listing{
//                
//            }else {
//                
//            }
//            Button(action: { createOrFetchChat() }) {
//                Text("구매 문의")
//                    .foregroundStyle(.white)
//                    .fontWeight(.bold)
//            }
//            .frame(maxWidth: .infinity, minHeight: 50)
//            .background(
//                RoundedRectangle(cornerRadius: 8).fill(Color.blue)
//            )
//            
//            NavigationLink(
//                destination: Group {
//                    if let chat = selectedChat,
//                       let currentUserId = Auth.auth().currentUser?.uid {
//                        ChatDetailView(
//                            chat: chat,
//                            currentUserId: currentUserId,
//                            userStore: userStore
//                        )
//                    } else {
//                        EmptyView()
//                    }
//                },
//                isActive: $isChatActive
//            ) {
//                EmptyView()
//            }
//            .hidden()
//        }
//        .padding(.vertical, 8) // 버튼 위/아래 여백
//        .background(Color.backgroundGray100) // 버튼 바 배경 (스크롤과 구분)
//    }
    
    // MARK: - 하단 구매/수정 버튼
    private var buyButton: some View {
        HStack {
            if let currentUserId = Auth.auth().currentUser?.uid,
               let listing = viewModel.detailData?.listing {
                
                if currentUserId == listing.sellerId {
                    //  판매자일 때 → 수정하기 버튼
                    NavigationLink(
                        destination: ListingEditView(listing: listing, viewModel: viewModel)
                    ) {
                        Text("수정하기")
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
                        Button {
                            showDeleteConfirm = true
                        } label: {
                            Text("삭제하기")
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.lineGray))
                        }
                    }
                } else {
                    //  구매자일 때 → 구매 문의 버튼
                    Button {
                        if Auth.auth().currentUser != nil {
                            createOrFetchChat()
                        } else {
                            withAnimation { showLoginModal = true }
                        }
                    } label: {
                        Text("구매 문의")
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
                    }
                }
                
            }
            
            //  NavigationLink for ChatDetailView
            NavigationLink(
                destination: Group {
                    if let chat = selectedChat,
                       let currentUserId = Auth.auth().currentUser?.uid {
                        ChatDetailView(
                            chat: chat,
                            currentUserId: currentUserId,
                            userStore: userStore,
                            listingId: chat.listingId //2509
                        )
                    } else {
                        EmptyView()
                    }
                },
                isActive: $isChatActive
            ) {
                EmptyView()
            }
            .hidden()
        }
        //.padding(.vertical, 8)
        .background(Color.backgroundGray100)
    }

    
    // MARK: - Subviews
    private func basicInfo(_ listing: Listing) -> some View {
        VStack(alignment: .leading) {
            Text(listing.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("\(String(listing.year))년")
                .padding(.leading, 8)
                .foregroundStyle(.gray)
            
            
            Text("\(NumberFormatter.koreanPriceString(from:listing.price))")
            
                .padding(.leading, 8)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.keyColorBlue)
        }
        .padding(.horizontal)
    }
    
    private func vehicleInfo(_ listing: Listing) -> some View {
        VStack(alignment: .leading) {
            Text("기본 정보")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 10) {
                InfoRow(label: "차량 번호", value: listing.plateNo)
                InfoRow(label: "연식", value: "\(listing.year)")
                InfoRow(label: "변속기", value: listing.transmission ?? "-")
                InfoRow(label: "차종", value: listing.carType)
                InfoRow(label: "주행거리", value: "\(listing.mileage)km")
                InfoRow(label: "연료", value: listing.fuel)
            }
            .padding()
            .background(Color.pureWhite)
            .cornerRadius(12)
        }
        .padding()
    }
    
    private func descriptionView(_ listing: Listing) -> some View {
        VStack(alignment: .leading) {
            Text("이 차의 상태")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.bottom, 3)
            
            Text(listing.description)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
        }
        .padding()
    }
    
    private func priceView(_ detailData: ListingDetailData) -> some View {
        VStack(alignment: .leading) {
            Text("시세")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.bottom, 8)
            
            VStack {
                if detailData.minPrice == 0 && detailData.maxPrice == 0 {
                    //  시세 데이터 없음 처리
                    Text("시세 정보 없음")
                        .foregroundStyle(.gray)
                        .padding(.bottom, 15)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    //  정상 데이터 출력
                    Text("시세구간")
                        .foregroundStyle(.gray)
                    Text("\(NumberFormatter.koreanPriceString(from: Int(detailData.safeMin))) ~ \(NumberFormatter.koreanPriceString(from: Int(detailData.safeMax)))")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.bottom, 15)
                    PriceRangeView(viewModel: viewModel)
                }
                
            }
        }
        .padding()
    }
    
    // MARK: - 채팅방 연결
    private func createOrFetchChat() {
        guard let currentUserId = Auth.auth().currentUser?.uid,
              let listing = viewModel.detailData?.listing else { return }
        
        let db = Firestore.firestore()
        db.collection("chats")
            .whereField("buyerId", isEqualTo: currentUserId)
            .whereField("sellerId", isEqualTo: listing.sellerId)
            .whereField("listingId", isEqualTo: listing.id ?? "")
            .getDocuments { snapshot, error in
                if let doc = snapshot?.documents.first,
                   let existingChat = try? doc.data(as: Chat.self) {
                    self.selectedChat = existingChat
                    self.isChatActive = true
                } else {
//                    let newChat = Chat(
//                        id: nil,
//                        buyerId: currentUserId,
//                        sellerId: listing.sellerId,
//                        listingId: listing.id ?? "",
//                        lastMessage: nil,
//                        listingTitle: listing.title,
//                        lastAt: Date()
//                    )
//                    self.selectedChat = newChat
//                    self.isChatActive = true
                    // ✅ 새로운 채팅방 Firestore에 저장
                    let chatRef = db.collection("chats").document()
                    let newChat = Chat(
                        id: chatRef.documentID,
                        buyerId: currentUserId,
                        sellerId: listing.sellerId,
                        listingId: listing.id ?? "",
                        lastMessage: nil,
                        listingTitle: listing.title,
                        lastAt: Date()
                    )
                    

                    do {
                        try chatRef.setData(from: newChat) { err in
                            if let err = err {
                                print("🔥 채팅방 생성 실패: \(err)")
                            } else {
                                print("✅ 채팅방 생성 성공: \(chatRef.documentID)")
                                self.selectedChat = newChat
                                self.isChatActive = true
                            }
                        }
                    } catch {
                        print("🔥 채팅방 인코딩 실패: \(error)")
                    }
                }
            }
        
    }
}

// MARK: - 재사용 InfoRow
struct InfoRow: View{
    let label: String
    let value: String
    
    var body:some View{
        HStack {
            Text(label)
            Spacer()
            Text(value)
        }
    }
}



