//
//  ActivityIndicatorView.swift
//  MyCamera
//
//  Created by Aung Ko Min on 17/3/21.
//

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {
    var color: UIColor = .gray
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.color = color
        view.hidesWhenStopped = true
        return view
    }
 
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.startAnimating()
        // Update the view
    }
}
