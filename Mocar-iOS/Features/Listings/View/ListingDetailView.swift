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
    // ListingDetailViewModel은 FavoritesViewModel을 반드시 필요로 함
    // 따라서 View가 직접 소유(@StateObject)하고, 생성 시 외부에서 FavoritesViewModel을 주입받아야 함
    @StateObject private var viewModel: ListingDetailViewModel
    let listingId: String
    
//    init(viewModel: ListingDetailViewModel, listingId: String) {
//            _viewModel = StateObject(wrappedValue: viewModel)
//            self.listingId = listingId
//        }
    init(service: ListingService, listingId: String) {
            _viewModel = StateObject(
                wrappedValue: ListingDetailViewModel(service: service)
            )
            self.listingId = listingId
        }

    /** 채팅방과 연결  **/
    @StateObject private var userStore = UserStore()
    @State private var selectedChat: Chat? = nil
    @State private var isChatActive = false
    /** 채팅방과 연결  **/
    
    var body: some View {
        NavigationStack{
            if let listing = viewModel.listing {
                VStack{
                    TopBar(style: .listing(title:viewModel.listing?.plateNo ?? ""))
                        .padding()
                    
                    ScrollView{
                        VStack{
                            ZStack(alignment: .topTrailing){
                                CarImageTabView(images: listing.images)
//                                FavoriteButton(
//                                    isFavorite: viewModel.favoritesViewModel.isFavorite(listing),
//                                            onToggle: {
//                                                viewModel.favoritesViewModel.toggleFavorite(listing)
//                                            }
//                                )
                                
                            }
                            
                            
                            //차량 기본 정보
                            VStack(alignment: .leading){
                                Text(listing.model)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading,8)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("\(listing.year)년")
                                    .padding(.leading,8)
                                    .foregroundStyle(.gray)
                                
                                Text("\(listing.priceInManwon)만원")
                                    .padding(.leading,8)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.keyColorBlue)
                            }
                            .padding(.horizontal)
                            
                            ProfileInfoView()
                                .padding(.horizontal)
                            
                            
                            VStack(alignment: .leading){
                                Text("기본 정보")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                VStack(alignment: .leading, spacing: 10){
                                    InfoRow(label: "차량 번호", value: listing.plateNo ?? "번호 없음")
                                    InfoRow(label: "연식", value: "\(listing.year)")
                                    InfoRow(label: "변속기", value: listing.transmission ?? "0cc")
                                    InfoRow(label: "차종", value: listing.carType ?? "-")
                                    InfoRow(label: "주행거리", value: "\(listing.mileage)km")
                                    InfoRow(label: "연료", value: listing.fuel)
                                }
                                .padding()
                                .background(Color.pureWhite)
                                .cornerRadius(12)
                                
                            }
                            .padding()
                            
                            
                            VStack{
                                Text("이 차의 상태")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(.bottom,3)
                                Text(listing.description)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                            .padding()
                            VStack{
                                Text("시세")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(.bottom, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                VStack{
                                    Text("시세안전구간")
                                        .foregroundStyle(.gray)
                                    Text("\(Int(viewModel.safeMin))~\(Int(viewModel.safeMax))만원")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .padding(.bottom, 15)
                                    
                                    PriceRangeView(viewModel: viewModel)
                                    
                                }
                                
                            }
                            .padding()
                            
                        }
                        .padding(.bottom, 90)
                        //                    HStack{
                        //                        Button(action:{
                        //
                        //                        }){
                        //                            Text("구매 문의")
                        //                                .foregroundStyle(.white)
                        //                                .fontWeight(.bold)
                        //
                        //                        }
                        //                        .frame(maxWidth: .infinity, minHeight: 50)
                        //                        .background(
                        //                            RoundedRectangle(cornerRadius: 8)
                        //                                .fill(Color.blue)
                        //                        )
                        //
                        //                    }
                        //                    .padding()
                    }
                    .background(Color.backgroundGray100)
                    .navigationBarHidden(true)   // 기본 네비게이션 바 숨김
                    .navigationBarBackButtonHidden(true) // 기본 뒤로가기 숨김
                    .task {
                        if viewModel.listing == nil {
                                await viewModel.loadListing(id: listingId)
                            }
                    }
                }
            } else {
                VStack {
                    ProgressView()
                    Text("불러오는 중...")
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.backgroundGray100)
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                .task {
                    if viewModel.listing == nil {
                            await viewModel.loadListing(id: listingId)
                        }
                }
            }

            
            }
            .background(Color.backgroundGray100)
            .navigationBarHidden(true)   // 기본 네비게이션 바 숨김
            .navigationBarBackButtonHidden(true) // 기본 뒤로가기 숨김
            HStack{
//                Button(action:{
//                    
//                }){
//                    Text("구매 문의")
//                        .foregroundStyle(.white)
//                        .fontWeight(.bold)
//                    
//                }
//                .frame(maxWidth: .infinity, minHeight: 50)
//                .background(
//                    RoundedRectangle(cornerRadius: 8)
//                        .fill(Color.blue)
//                )
                
                /**채팅방과 연결 */
                Button(action: {
                    createOrFetchChat()
                }) {
                    Text("구매 문의")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                )
                
                
                // ✅ 네비게이션 링크 (선택된 Chat 있으면 활성화됨)
                // ✅ ListingDetailView 안에
                NavigationLink(
                    destination:
                        Group {
                            if let chat = selectedChat,
                               let currentUserId = Auth.auth().currentUser?.uid {
                                ChatDetailView(
                                    chat: chat,
                                    currentUserId: currentUserId,
                                    userStore: userStore
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


                
                /** 채팅방과 연결  */
                
            }
            .padding()
            
            
        }
        

    /**채팅방과 연결 */
    // Firestore 확인 → Chat 객체 세팅 → Navigation 실행
       private func createOrFetchChat() {
           guard let currentUserId = Auth.auth().currentUser?.uid else { return } //로그인 후 이용 모달 나중에 띄우기
           let db = Firestore.firestore()
           
           db.collection("chats")
               .whereField("buyerId", isEqualTo: currentUserId)
               .whereField("sellerId", isEqualTo: viewModel.listing?.sellerId ?? "")
               .whereField("listingId", isEqualTo: viewModel.listing?.id ?? "")
               .getDocuments (completion:{ snapshot, error in
                   if let doc = snapshot?.documents.first,
                      let existingChat = try? doc.data(as: Chat.self) {
                       // ✅ 기존 채팅방 있음
                       self.selectedChat = existingChat
                       self.isChatActive = true
                   } else {
                       // ✅ 채팅방 없음 → 새 Chat 객체 넘기기
                       let newChat = Chat(
                           id: nil,
                           buyerId: currentUserId,
                           sellerId: viewModel.listing?.sellerId ?? "",
                           listingId: viewModel.listing?.id ?? "",
                           lastMessage: nil,
                           listingTitle: viewModel.listing?.title ?? "",
                           lastAt: Date()
                       )
                       self.selectedChat = newChat
                       self.isChatActive = true
                   }
               })
       }
    /**채팅방과 연결 */

}


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



