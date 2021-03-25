//
//  EULAView.swift
//  MyCamera
//
//  Created by Aung Ko Min on 19/3/21.
//

import SwiftUI

struct EULAView: View {
    
    private let subHeadText = """
    This End User License Agreement is between you and 'MyCamera' App and governs use of this app made available through the Apple App Store.
    By installing the 'MyCamera' App, you agree to be bound by this Agreement and understand that there is no tolerance for objectionable content.
    If you do not agree with the terms and conditions of this Agreement, you are not entitled to use the 'MyCamera' App.

    """
    
    private let bodyText = """
    This End User License Agreement (“Agreement”) is between you and App Name and governs use of this app made available through the Apple App Store. By installing the App Name App, you agree to be bound by this Agreement and understand that there is no tolerance for objectionable content. If you do not agree with the terms and conditions of this Agreement, you are not entitled to use the App Name App.

    Parties
     This Agreement is between you and App Name only, and not Apple, Inc. (“Apple”). Notwithstanding the foregoing, you acknowledge that Apple and its subsidiaries are third party beneficiaries of this Agreement and Apple has the right to enforce this Agreement against you. App Name, not Apple, is solely responsible for the App Name App and its content.

    Privacy
     Mobile Device Access. We may request access or permission to certain features from your mobile device, including your mobile device’s camera, microphone, storage, and other features. If you wish to change our access or permissions, you may do so in your device’s settings.
     User Content, including any image or video files, is stored locally on Your mobile device and not sent or share to any other services.
     We do NOT access your Contacts, Location Services.
     We do NOT share your information with third parties, we do NOT access and share your email addresses or phone number with sponsors or any third parties, and we do NOT run exclusive ‘sponsored’, 'phone calls' or 'sms' on behalf of third parties.

    Limited License
     App Name grants you a limited, non-exclusive, non-transferable, revocable license to use theApp Name App for your personal, non-commercial purposes. You may only use theApp Name App on Apple devices that you own or control and as permitted by the App Store Terms of Service.

    Age Restrictions
     By using 'MyCamera' App, you represent and wrrant that
        (a) you are 12 years of age or older and you agree to be bound by this Agreement
        (b) if you are under 12 years of age, you have obtained verifiable consent from a parent or legal guardian and
        (c) your use of the 'MyCamera' App does not violate any applicable law or regulation.
     Your access to to the 'MyCamera' may be terminated without warning if we believe, in its sole discretion, that you are under the age of 12 years and have not obtained verifiable consent from a parent or legal guardian. If you are a parent or legal guardian and you provide your consent to your child's use of the 'MyCamera' App, you agree to be bound by this Agreement in respect to your child's use of the 'MyCamera' App.

    Warranty
     App Name disclaims all warranties about the App Name App to the fullest extent permitted by law. To the extent any warranty exists under law that cannot be disclaimed, App Name, not Apple, shall be solely responsible for such warranty.

    Maintenance and Support
      App Name does provide minimal maintenance or support for it but not to the extent that any maintenance or support is required by applicable law, App Name, not Apple, shall be obligated to furnish any such maintenance or support.

    Product Claims
     App Name, not Apple, is responsible for addressing any claims by you relating to the App Name App or use of it, including, but not limited to: (i) any product liability claim; (ii) any claim that the App Name App fails to conform to any applicable legal or regulatory requirement; and (iii) any claim arising under consumer protection or similar legislation. Nothing in this Agreement shall be deemed an admission that you may have such claims.

    Third Party Intellectual Property Claims
     App Name shall not be obligated to indemnify or defend you with respect to any third party claim arising out or relating to the App Name App. To the extent App Name is required to provide indemnification by applicable law, App Name, not Apple, shall be solely responsible for the investigation, defense, settlement and discharge of any claim that the App Name App or your use of it infringes any third party intellectual property right.

    YOU EXPRESSLY ACKNOWLEDGE THAT YOU HAVE READ THIS EULA AND UNDERSTAND THE RIGHTS, OBLIGATIONS, TERMS AND CONDITIONS SET FORTH HEREIN.
    BY CLICKING ON THE 'I AGREE & CONTINUE' BUTTON, YOU EXPRESSLY CONSENT TO BE BOUND BY ITS TERMS AND CONDITIONS AND GRANT TO 'MyCamera' THE RIGHTS SET FORTH HEREIN.
    """
    
    var body: some View {
        VStack {
            
            ScrollView(showsIndicators: false) {
                Text("End User License Agreement").font(.title).padding(.top).multilineTextAlignment(.center)
                Text("Last updated: 19-March-2021").font(.subheadline).foregroundColor(.secondary).padding()
                Text(subHeadText).font(.caption2).italic()
                Text(bodyText).font(.footnote)
            }
            Spacer()
            NavigationLink(
                destination: WelcomeView(),
                label: {
                    HStack {
                        Text("I Agree & Continue")
                            .bold()
                    }
                })
        }.padding()
    }
}
