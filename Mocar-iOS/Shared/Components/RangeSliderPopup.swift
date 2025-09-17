//
//  RangeSliderPopup.swift
//  Mocar-iOS
//
//  Created by Admin on 9/17/25.
//

import SwiftUI

struct RangeSliderPopup: View {
    @Binding var isPresented: Bool
       
       let title: String
       let minValue: Double
       let maxValue: Double
       let lowerPlaceholder: String
       let upperPlaceholder: String
       let unit: String
       
       @Binding var lowerValue: Double
       @Binding var upperValue: Double
       
    
       // 외부에서 선택 완료 동작 주입
       var onConfirm: (() -> Void)? = nil
       
       // 팝업 높이
       let popupHeight: CGFloat = 450

       var body: some View {
           if isPresented {
               ZStack {
                   // 반투명 배경
                   Color.black.opacity(0.4)
                       .edgesIgnoringSafeArea(.all)
                       .onTapGesture {
                           withAnimation {
                               isPresented = false
                           }
                       }
                   
                   // 하단 고정 팝업
                   VStack(spacing: 0) {
                       Spacer()
                       
                       ZStack(alignment: .topTrailing) {
                           VStack (spacing:0){
                               CateRangeSlider(
                                   title: title,
                                   minValue: minValue,
                                   maxValue: maxValue,
                                   lowerPlaceholder: lowerPlaceholder,
                                   upperPlaceholder: upperPlaceholder,
                                   unit: unit,
                                   lowerValue: $lowerValue,
                                   upperValue: $upperValue,
                                   onConfirm: {
                                      isPresented = false
                                      onConfirm?()  // 외부에서 주입한 동작 실행
                                  },
                                   onClose: {
                                       isPresented = false   // ← X 버튼 누르면 팝업 닫기
                                   }
                               )
                               .padding(.bottom, 120)
                               
                           }
                           .frame(height: popupHeight)
                           .background(Color.white)
                           .cornerRadius(16, corners: [.topLeft, .topRight])
                           .shadow(radius: 8)
                           
                       }
                   }
                   .edgesIgnoringSafeArea(.bottom) // 하단에 딱 붙이기
                   
               }
           }
       }
}

// Extension으로 특정 모서리만 둥글게
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


#Preview {
//    RangeSliderPopup()
    @Previewable @State var minPrice: Double = 0
    @Previewable @State var maxPrice: Double = 6000
    @Previewable @State var showPopup: Bool = true
    
    RangeSliderPopup(
      isPresented: $showPopup,
      title: "가격",
      minValue: 0,
      maxValue: 6000,
      lowerPlaceholder: "최소 가격",
      upperPlaceholder: "최대 가격",
      unit: "만원",
      lowerValue: $minPrice,
      upperValue: $maxPrice
  )
    
}
