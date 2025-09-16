//
//  SellCarFlowView.swift
//  Mocar-iOS
//
//  Created by wj on 9/15/25.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

enum SellStep: Int, CaseIterable {
    case carNumber, ownerName, carInfo, mileage, price, additional, photos, review, complete

    var title: String {
        switch self {
        case .carNumber: return "차량 번호를 입력해주세요."
        case .ownerName: return "소유자명을 입력해주세요!"
        case .carInfo: return "차량 정보 확인"
        case .mileage: return "주행거리를 입력해주세요."
        case .price: return "판매가격을 입력해주세요."
        case .additional: return "추가 정보를 입력해주세요"
        case .photos: return "사진을 등록해주세요."
        case .review: return "최종 확인"
        case .complete: return "등록 완료"
        }
    }
}

struct SellCarFlowView: View {
    // MARK: - Inputs
    @State private var carNumber: String = ""
    @State private var ownerName: String = ""
    @State private var modelName: String = "현대 싼타페 CM 2WD(2.0 VGT) CLX 고급형"
    @State private var year: String = "2015"
    @State private var mileage: String = ""
    @State private var price: String = ""
    @State private var additionalInfo: String = ""
    @State private var photos: [UIImage] = []

    // MARK: - Flow state
    @State private var step: SellStep = .carNumber
    @State private var showingPhotoPicker = false
    @State private var showConfirmAlert = false
    @Environment(\.dismiss) private var dismiss

    private var totalSteps: Int { SellStep.allCases.count }
    private var currentIndex: Int { min(step.rawValue + 1, totalSteps) }

    var body: some View {
        NavigationStack {
            VStack {
                if step != .complete {
                    // Top progress + title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("판매 등록")
                            .font(.headline)
                            .foregroundColor(.primary)

                        ProgressView(value: Double(currentIndex), total: Double(totalSteps))
                            .scaleEffect(x: 1, y: 1.6, anchor: .center)

                        HStack {
                            Text(step.title)
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Text("\(currentIndex)/\(totalSteps)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    Divider()
                        .padding(.vertical, 8)
                }

                // Content area (single source of truth, no nested NavigationStack)
                Group {
                    switch step {
                    case .carNumber: carNumberView
                    case .ownerName: ownerNameView
                    case .carInfo: carInfoView
                    case .mileage: mileageView
                    case .price: priceView
                    case .additional: additionalView
                    case .photos: photosView
                    case .review: reviewView
                    case .complete: completeView
                    }
                }
                .animation(.easeInOut, value: step)
                .padding(.horizontal, 20)

                Spacer()

                // Bottom buttons (not shown on complete screen)
                if step != .complete {
                    HStack(spacing: 16) {
                        Button(action: previousStep) {
                            Text("이전")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.15))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                        }
                        .disabled(step == .carNumber)

                        Button(action: nextAction) {
                            Text(step == .review ? "등록" : "다음")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isValidStep() ? Color.blue : Color.gray.opacity(0.4))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(!isValidStep())
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(step == .complete ? "" : "판매 등록")
                        .font(.headline)
                }
            }
            .sheet(isPresented: $showingPhotoPicker) {
                PhotoPicker(selectionLimit: 5, images: $photos)
            }
            .alert("정말 등록하시겠습니까?", isPresented: $showConfirmAlert) {
                Button("취소", role: .cancel) {}
                Button("등록", role: .destructive) {
                    submit()
                }
            }
        }
    }

    // MARK: - Step Views (no nested NavigationStack)
    private var carNumberView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("내 차,\n시세를 알아볼까요?")
                .font(.title)
                .fontWeight(.bold)

            TextField("12가1234", text: $carNumber)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.black.opacity(0.8), lineWidth: 1.5))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
    }

    private var ownerNameView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("소유자명을 입력해주세요!")
                .font(.title)
                .fontWeight(.bold)

            TextField("홍길동", text: $ownerName)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.black.opacity(0.8), lineWidth: 1.5))
                .disableAutocorrection(true)
        }
    }

    private var carInfoView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("차량 정보")
                .font(.title)
                .fontWeight(.bold)

            Text(modelName)
                .font(.caption)
                .foregroundColor(.secondary)

            Text("연식: \(year)년식")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var mileageView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("주행거리")
                .font(.title2)
                .fontWeight(.bold)
            TextField("예: 50000 (km)", text: $mileage)
                .keyboardType(.numberPad)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.black.opacity(0.6), lineWidth: 1))
        }
    }

    private var priceView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("판매가격")
                .font(.title2)
                .fontWeight(.bold)
            TextField("예: 15000000 (원)", text: $price)
                .keyboardType(.numberPad)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.black.opacity(0.6), lineWidth: 1))
        }
    }

    private var additionalView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("추가 정보")
                .font(.title2)
                .fontWeight(.bold)
            TextEditor(text: $additionalInfo)
                .frame(height: 140)
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
        }
    }

    private var photosView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("사진")
                .font(.title2)
                .fontWeight(.bold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(photos.enumerated()), id: \.offset) { _, img in
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 80)
                            .clipped()
                            .cornerRadius(8)
                    }

                    Button(action: { showingPhotoPicker = true }) {
                        VStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.title2)
                            Text("사진 추가")
                                .font(.caption)
                        }
                        .frame(width: 120, height: 80)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                    }
                }
                .padding(.vertical, 6)
            }
        }
    }

    private var reviewView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("입력하신 정보를 확인해주세요")
                    .font(.title2)
                    .fontWeight(.bold)

                Group {
                    infoRow("차량 번호", carNumber)
                    infoRow("소유자명", ownerName)
                    infoRow("모델명", modelName)
                    infoRow("연식", "\(year)년식")
                    infoRow("주행거리", "\(mileage) km")
                    infoRow("판매가격", "\(price) 원")
                    infoRow("추가 정보", additionalInfo.isEmpty ? "없음" : additionalInfo)
                }

                if !photos.isEmpty {
                    Text("사진")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(photos.enumerated()), id: \.offset) { _, img in
                                Image(uiImage: img)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 80)
                                    .clipped()
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value.isEmpty ? "—" : value)
        }
        .padding(.vertical, 4)
    }

    private var completeView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.green)

            Text("등록 완료!")
                .font(.title)
                .fontWeight(.bold)

            Text("판매 등록이 정상적으로 완료되었습니다.")
                .foregroundColor(.secondary)

            Button("메인으로 가기") {
                dismiss()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal, 20)

            Spacer()
        }
    }

    // MARK: - Navigation logic
    private func previousStep() {
        guard step.rawValue > 0 else { return }
        if let prev = SellStep(rawValue: step.rawValue - 1) {
            step = prev
        }
    }

    private func nextAction() {
        if step == .review {
            showConfirmAlert = true
            return
        }

        if let next = SellStep(rawValue: step.rawValue + 1) {
            step = next
        }
    }

    private func isValidStep() -> Bool {
        switch step {
        case .carNumber: return !carNumber.trimmingCharacters(in: .whitespaces).isEmpty
        case .ownerName: return !ownerName.trimmingCharacters(in: .whitespaces).isEmpty
        case .carInfo: return true
        case .mileage: return !mileage.isEmpty
        case .price: return !price.isEmpty
        case .additional: return true
        case .photos: return true
        case .review: return true
        case .complete: return true
        }
    }

    private func submit() {
        // TODO: 여기에 실제 API 호출을 넣으세요.
        // 현재는 시뮬레이션: 완료 화면으로 이동 + 자동 리턴
        withAnimation { step = .complete }

        // 자동으로 이전 화면(ContentView)으로 돌아가게 (1.2초 딜레이)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }
}

// MARK: - PHPicker wrapper (PhotoPicker)
struct PhotoPicker: UIViewControllerRepresentable {
    var selectionLimit: Int = 5
    @Binding var images: [UIImage]

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = selectionLimit
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: PhotoPicker
        init(_ parent: PhotoPicker) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            parent.images.removeAll()
            
            let itemProviders = results.map(\.itemProvider)
            for provider in itemProviders {
                if provider.canLoadObject(ofClass: UIImage.self) {
                    provider.loadObject(ofClass: UIImage.self) { object, error in
                        if let img = object as? UIImage {
                            DispatchQueue.main.async {
                                guard self.parent.images.count < self.parent.selectionLimit else { return }
                                self.parent.images.append(img)
                            }
                        }
                    }
                } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                        if let data = data, let ui = UIImage(data: data) {
                            DispatchQueue.main.async {
                                guard self.parent.images.count < self.parent.selectionLimit else { return }
                                self.parent.images.append(ui)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct SellCarFlowView_Previews: PreviewProvider {
    static var previews: some View {
        SellCarFlowView()
    }
}
