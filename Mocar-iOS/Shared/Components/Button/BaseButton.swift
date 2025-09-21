//
//  BaseButton.swift
//  Mocar-iOS
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

struct BaseButton: View {
    let title:String
    let backgroundColor:Color
    let textColor: Color
    let fontWeight: Font.Weight
    let action: () -> Void
    
    var body: some View {
        Button(action:action){
            Text(title)
                .foregroundColor(textColor)
                .font(.system(size: 18))
                .fontWeight(fontWeight)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(backgroundColor)
                .cornerRadius(10)
        }
    }
}
#Preview {
    
}


