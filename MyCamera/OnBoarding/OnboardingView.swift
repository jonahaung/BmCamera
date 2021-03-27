//
//  OnboardingView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 5/12/20.
//

import SwiftUI

struct OnboardingView: View {
    
    init(isFirstTime: Bool) {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.systemGray
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
        self.isFirstTime = isFirstTime
    }
    
    let isFirstTime: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            TabView {
                ForEach(OnboardingData) { page in
                    GeometryReader { g in
                        VStack {
                            Image(page.image)
                                .resizable()
                                .scaledToFit()
                            Text(page.title)
                                .font(.system(size: 26, weight: .semibold, design: .rounded))
                                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 20).multilineTextAlignment(.center)
                            Text(page.descrip)
                                .font(.callout)
                                .multilineTextAlignment(.center)
                                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/).multilineTextAlignment(.center)
                                .foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
                        }
                        .opacity(Double(g.frame(in : . global).minX)/200+1)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            
            if isFirstTime {
                let eulaView = EULAView(showAgreementButton: isFirstTime).navigationBarBackButtonHidden(isFirstTime).navigationBarHidden(true)
                
                NavigationLink(destination: eulaView, label: {
                        Text("Start")
                            .font(.headline)
                            .frame(width: 200, height: 40, alignment: .center)
                            .foregroundColor(.white)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    })
            } else {
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
}
