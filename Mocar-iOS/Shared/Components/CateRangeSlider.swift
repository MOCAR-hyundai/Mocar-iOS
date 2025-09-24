//
//  CateRangeSlider.swift
//  Mocar-iOS
//
//  Created by Admin on 9/17/25.
//

import SwiftUI

struct CateRangeSlider: View {
    
     let title: String
        let minValue: Double
        let maxValue: Double
        let lowerPlaceholder: String
        let upperPlaceholder: String
        let unit: String

        @Binding var lowerValue: Double
        @Binding var upperValue: Double
        
        @State private var lowerText: String = ""
        @State private var upperText: String = ""
        
        let handleDiameter: CGFloat = 28
        let sliderHeight: CGFloat = 4
     
         // 선택 완료 동작 외부 주입
         var onConfirm: (() -> Void)? = nil
     
         var onClose: (() -> Void)? = nil   // ← 추가

        var body: some View {
            VStack(spacing: 20) {
                HStack {
                    Text(title)
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    // 초기화 버튼
                    Button(action: {
                        lowerValue = minValue
                        upperValue = maxValue
                        lowerText = ""
                        upperText = ""
                    }) {
                        HStack(spacing: 0) {
                            Text("초기화")
                                .foregroundColor(.black)
                                .font(.system(size: 16))
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundColor(.black)
                                .padding(.leading, 10)
                        }
                        .padding(6)
                        .cornerRadius(6)
                    }
                    .padding(6)
                    
                    
                    
                    Button(action: {
 //                       withAnimation { isPresented = false }
                        onClose?()  // ← 팝업 닫기
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(.black)
                    }
                    
                }
                .padding(7)
                
                HStack {
                    UnitTextField(text: $lowerText, placeholder: lowerPlaceholder, unit: unit)
                        .frame(maxWidth: .infinity)
                        .onChange(of: lowerValue) { newValue in
                            lowerText = (Int(newValue) == Int(minValue)) ? "" : String(Int(newValue))
                        }
                    
                    Spacer()
                    Text(" ~ ")
                    Spacer()
                    
                    UnitTextField(text: $upperText, placeholder: upperPlaceholder, unit: unit)
                        .frame(maxWidth: .infinity)
                        .onChange(of: upperValue) { newValue in
                            upperText = (Int(newValue) == Int(maxValue)) ? "" : String(Int(newValue))
                        }
                }
                
                GeometryReader { geo in
                    let width = geo.size.width
                    let lowerPos = CGFloat((lowerValue - minValue) / (maxValue - minValue)) * width
                    let upperPos = CGFloat((upperValue - minValue) / (maxValue - minValue)) * width
                    
                    
                    ZStack {
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: sliderHeight)
                        
                        Capsule()
                            .fill(Color.keyColorBlue)
                            .frame(width: upperPos - lowerPos, height: sliderHeight)
                            .offset(x: (upperPos + lowerPos)/2 - width/2)
                        
                        // Lower handle
                        Circle()
                            .fill(Color.white)
                            .overlay(Circle().stroke(Color.keyColorBlue, lineWidth: 2))
                            .frame(width: handleDiameter, height: handleDiameter)
                            .position(x: lowerPos, y: sliderHeight/2 + handleDiameter/2)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let pos = min(max(0, value.location.x), upperPos)
                                        lowerValue = Double(pos / width) * (maxValue - minValue) + minValue
                                        lowerText = String(Int(lowerValue))
                                    }
                            )
                        
                        // Upper handle
                        Circle()
                            .fill(Color.white)
                            .overlay(Circle().stroke(Color.keyColorBlue, lineWidth: 2))
                            .frame(width: handleDiameter, height: handleDiameter)
                            .position(x: upperPos, y: sliderHeight/2 + handleDiameter/2)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let pos = max(min(width, value.location.x), lowerPos)
                                        upperValue = Double(pos / width) * (maxValue - minValue) + minValue
                                        upperText = (Int(upperValue) == Int(maxValue)) ? "" : String(Int(upperValue))
                                    }
                            )
                    }
                }
                .frame(height: handleDiameter)
                .padding()
                
                Button(action: {
                    //print("선택 범위: \(lowerValue) ~ \(upperValue)")
                    // 팝업 닫기 + 외부 동작 호출
                    onConfirm?()
                }) {
                    Text("선택 완료")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.keyColorBlue)
                        .cornerRadius(8)
                }
            }
            .padding()
            .onAppear {
                    // 팝업 열릴 때 텍스트 초기화
                    lowerText = (Int(lowerValue) == Int(minValue)) ? "" : String(Int(lowerValue))
                    upperText = (Int(upperValue) == Int(maxValue)) ? "" : String(Int(upperValue))
                }
        }
 }

 #Preview {
     @Previewable @State var minPrice: Double = 0
     @Previewable @State var maxPrice: Double = 6000
     
     CateRangeSlider(
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



 struct UnitTextField: View {
     @Binding var text: String
     var placeholder: String
     var unit: String
     
     @FocusState private var isFocused: Bool
     
     // 설정값
     var placeholderFont: Font = .system(size: 14)
     var placeholderColor: Color = .gray
     var borderColor: Color = .gray.opacity(0.5)
     var focusedBorderColor: Color = .keyColorBlue

     var body: some View {
         ZStack(alignment: .trailing) {
             // 플레이스홀더
             if text.isEmpty {
                 Text(placeholder)
                     .foregroundColor(placeholderColor)
                     .font(placeholderFont)
                     .padding(.trailing, 39)
             }
             
             TextField("", text: $text)
                 .keyboardType(.numberPad)
                 .multilineTextAlignment(.trailing)
                 .padding(.trailing, 39) // 단위 공간 확보
                 .focused($isFocused)
             
             Text(unit)      // 단위
                 .foregroundColor(.black)
                 .font(.system(size: 14))
                 .padding(.trailing, 9)
         }
         .frame(height: 43)
         .overlay(
             RoundedRectangle(cornerRadius: 5)
                 .stroke(isFocused ? focusedBorderColor : borderColor, lineWidth: 1)
         )
     }
 }
