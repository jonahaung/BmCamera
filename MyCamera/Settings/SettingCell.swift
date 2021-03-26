//
//  SettingCell.swift
//  MyanScan
//
//  Created by Aung Ko Min on 3/3/21.
//

import SwiftUI

struct SettingCell: View {
    
    let text: String
    let subtitle: String?
    let imageName: String
    let color: Color
    
    var body: some View {
        
        HStack(spacing: 9) {
            Image(systemName: imageName)
                
                .foregroundColor(color)
                .opacity(0.7)
                .padding(5)
            Text(text)
            if let x = subtitle {
                Spacer()
                Text(x)
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
    }
}
