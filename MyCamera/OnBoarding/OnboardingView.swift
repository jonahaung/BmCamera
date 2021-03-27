//
//  OnboardingView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 5/12/20.
//

import SwiftUI

struct OnboardingView: View {
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.systemGray
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }
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
            
            
            NavigationLink(
                destination: EULAView(isFirstTime: true).navigationBarBackButtonHidden(true).navigationBarHidden(true),
                label: {
                    Text("Start")
                        .font(.headline)
                        .frame(width: 200, height: 40, alignment: .center)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                })
            Spacer()
        }
        
        .navigationBarItems(trailing:
                                NavigationLink(
                                    destination: EULAView(isFirstTime: true)
                                        .navigationBarBackButtonHidden(true).navigationBarHidden(true),
                                    label: {
                                        Image(systemName: "arrow.right")
                                            .font(Font.system(.title3))
                                    })
        )
        .navigationBarBackButtonHidden(true)
    }
}
