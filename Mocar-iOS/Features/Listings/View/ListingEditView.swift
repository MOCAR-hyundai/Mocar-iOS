//
//  ListingModifyView.swift
//  Mocar-iOS
//
//  Created by Admin on 9/24/25.
//


import SwiftUI
import PhotosUI
import FirebaseFirestore

struct ListingEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: ListingDetailViewModel
    
    let listing: Listing
    
    // 편집용 State 변수
    @State private var plateNo: String = ""
    @State private var year: String = ""
    @State private var mileage: String = ""
    @State private var price: String = ""
    @State private var description: String = ""
    @State private var images: [String]
    
    @State private var showImagePicker = false
    
    init(listing: Listing, viewModel: ListingDetailViewModel) {
            self.listing = listing
            self._viewModel = ObservedObject(initialValue: viewModel) // 여기 바꿔야 함
            self._images = State(initialValue: listing.images)
        }
    
    var body: some View {
        VStack(spacing:0){
            TopBar(style: .listing(title: "차량정보 수정", status: listing.status))
                .padding()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        // 차량 이미지 수정
                        VStack(alignment: .leading) {
                            
                            ZStack(alignment: .bottomTrailing) {
                                if !images.isEmpty || !viewModel.photos.isEmpty {
                                    TabView {
                                        // 기존 Firestore 이미지
                                        ForEach(images, id: \.self) { url in
                                            AsyncImage(url: URL(string: url)) { phase in
                                                if let image = phase.image {
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(maxWidth: .infinity, maxHeight: 250)
                                                } else if phase.error != nil {
                                                    Color.red
                                                } else {
                                                    ProgressView()
                                                }
                                            }
                                            .cornerRadius(0)
                                        }
                                        
                                        // 새로 선택한 이미지
                                        ForEach(viewModel.photos, id: \.self) { img in
                                            Image(uiImage: img)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(maxWidth: .infinity, maxHeight: 250)
                                                .clipped()
                                        }
                                    }
                                    .frame(height: 250)
                                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                                } else {
                                    Text("등록된 이미지가 없습니다.")
                                        .foregroundColor(.gray)
                                        .frame(height: 250)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.backgroundGray100)
                                        .cornerRadius(12)
                                }
                                
                                // ✅ 우측 하단 카메라 버튼
                                Button {
                                    showImagePicker = true
                                } label: {
                                    Image("Camera")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)

                                        .background(Color.white)
                                        .clipShape(Circle())

                                }
                                .padding(12) // 우측하단 여백
                            }
                        }
                        .padding(.bottom,10)

                        // 가격 입력
                        VStack(alignment: .leading) {
                            VStack(spacing: 10) {
                                PlaceholderTextField(
                                    label: "차량 가격",
                                    placeholder: "\(listing.price)",
                                    text: $price,
                                    keyboardType: .numberPad,
                                    validation: .numbersOnly
                                )
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        
                        // 차량 기본 정보
                        VStack(alignment: .leading) {
                            Text("기본 정보")
                                .font(.title3).fontWeight(.semibold)
                            
                            VStack(spacing: 10) {
                                //숫자2개 문자1개 공백1개 숫자4개
                                PlaceholderTextField(
                                    label: "차량 번호",
                                    placeholder: listing.plateNo,
                                    text: $plateNo,
                                    keyboardType: .default
                                )
                                PlaceholderTextField(
                                    label: "연식",
                                    placeholder: "\(listing.year)",
                                    text: $year,
                                    validation: .numbersOnly
                                )
                                PlaceholderTextField(
                                    label: "주행거리",
                                    placeholder: "\(listing.mileage)",
                                    text: $mileage,
                                    validation: .numbersOnly
                                )
                                
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // 설명 수정
                        VStack(alignment: .leading) {
                            Text("이 차의 상태")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            ZStack(alignment: .topLeading) {
                                if description.isEmpty {
                                    Text(listing.description)
                                        .foregroundColor(.gray)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                }
                                TextEditor(text: $description)
                                    .frame(height: 120)
                                    .padding(4)
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                    }
                    .padding(.bottom, 60)
                }
                .background(Color.backgroundGray100)
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
            }
            // 저장 버튼
            Button {
                let updatedListing = Listing(
                    id: listing.id,
                    sellerId: listing.sellerId,
                    plateNo: plateNo.isEmpty ? listing.plateNo : formattedPlateNo(plateNo),
                    title: listing.title,
                    brand: listing.brand,
                    model: listing.model,
                    trim: listing.trim,
                    year: year.isEmpty ? listing.year : Int(year) ?? listing.year,
                    mileage: Int(mileage) ?? listing.mileage,
                    fuel: listing.fuel,
                    transmission: listing.transmission,
                    price: Int(price) ?? listing.price,
                    region: listing.region,
                    description: description.isEmpty ? listing.description : description,
                    images: images,
                    status: listing.status,
                    stats: listing.stats,
                    createdAt: listing.createdAt,
                    updatedAt: Date().ISO8601Format(),
                    carType: listing.carType
                )
                print("업데이트된 가격:", listing.price)
                viewModel.saveListing(updatedListing)
                Task {
                    if let id = listing.id {
                        await viewModel.loadListing(id: id, forceReload: true)
                    }
                    dismiss()
                }
                dismiss()
            } label: {
                Text("저장하기")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
            }
            .padding(.horizontal)
            .padding(.bottom, 8) // safe area 위에 여백
            .background(Color.backgroundGray100)
            //PhotoPicker sheet 연결
            .sheet(isPresented: $showImagePicker) {
                PhotoPicker(images: $viewModel.photos) { selected in
                    // 기존 이미지 삭제 후 새로 선택한 이미지만 표시
                    images.removeAll()
                    viewModel.photos = selected
                }
            }
        }
    }
    
    
    
    
    // 차량번호 변환: 12가1234 -> 12가 1234
    func formattedPlateNo(_ raw: String) -> String {
        // 숫자+한글만 추출
        let filtered = raw.filter { $0.isNumber || ($0 >= "가" && $0 <= "힣") }
        
        // 7자리(예: 12가1234)일 때만 변환
        guard filtered.count == 7 else { return raw }
        
        let prefix = filtered.prefix(3)   // "12가"
        let suffix = filtered.suffix(4)   // "1234"
        return "\(prefix) \(suffix)"      // "12가 1234"
    }

}
