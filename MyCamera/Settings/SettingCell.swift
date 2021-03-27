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
        
        HStack {
            Image(systemName: imageName)
                .font(.title2)
                .frame(minWidth: 40)
                .foregroundColor(color)
                .opacity(0.9)
                
            
            Text(text)
            if let x = subtitle {
                Spacer()
                Text(x)
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
    }
}
