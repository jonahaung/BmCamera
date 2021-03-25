//
//  ViewModifiers.swift
//  MyCamera
//
//  Created by Aung Ko Min on 20/3/21.
//

import SwiftUI


struct CircleShadowButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(width: 40, height: 40)
            .foregroundColor(.white)
            .background(Color(.separator))
            .clipShape(Circle())
    }
}
