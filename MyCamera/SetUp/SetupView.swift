//
//  SetupView.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import SwiftUI

struct SetupView: View {
    
    private var digits = [1, 2, 3, 4, 5, 6]
    @State private var password: String?
    @State private var labelText = "Enter passcode for your new album"
    @Environment(\.presentationMode) var presentationMode
    
    @State var isSuccess = false
    
    var body: some View {
        VStack {
            VStack {
                Image(systemName: "lock.fill")
                    .font(.title).opacity(0.5)
                Spacer()
                
                Text(labelText)
                    .font(.title3).bold()
                    .padding()
                    .multilineTextAlignment(.center)
                
                digitsView()
                Spacer()
                numberPad()
                Spacer()
                bottomBar()
            }
            Spacer()
        }.actionSheet(isPresented: $isSuccess) {
            successSheet
        }
    }
    
}

extension SetupView {
    private func updatePassword(number: Int) {
        guard password?.count ?? 0 < 6 else { return }
        SoundManager.playSound(tone: .Tock)
        if let pw = password {
            password = pw.appending(number.description)
        } else {
            password = number.description
        }
        checkPassword()
    }
    
    private func checkPassword() {
        guard let pw = password else { return }
        let isValid = pw.count == 6
       
        if isValid {
            register(pw: pw)
        } else {
            labelText = " "
        }
    }
    
    private func register(pw: String) {
        let existingPasswords = UserdefaultManager.shared.passWords
        if existingPasswords.contains(pw) {
            labelText = "Album Already Exist\nPlease enter different passcode"
            SoundManager.vibrate(vibration: .error)
            password = nil
        } else {
            UserdefaultManager.shared.passWords.append(pw)
            labelText = "Your new album is successfully created!"
            isSuccess = true
            UserdefaultManager.shared.currentFolderName = pw
            Utils.createDefaultPhotos()
            
            
        }
    }
    private func reset() {
        password = nil
        labelText = "Enter password for your new album"
        isSuccess = false
    }
}

extension SetupView {
    private var successSheet: ActionSheet {
        return ActionSheet(
            title: Text("New Album Created"),
            message: Text("Passcode is un-recoverable. Please do not lose your passcode."),
            buttons: [
                .default(Text("Exit and Continue  "), action: {
                    UserdefaultManager.shared.doneSetup = true
                }),
                .default(Text("Create Another Album"), action: {
                    reset()
                }),
                .cancel()
            ]
        )
    }
    
    private func digitsView() -> some View {
        return HStack(spacing: 5) {
            ForEach(digits) { digit in
                let imageName = (password?.count ?? 0) >= digit ? "circlebadge.fill" : "circlebadge"
                Image(systemName: imageName)
            }
        }
    }
    
    private func numberPad() -> some View {
        return VStack {
            HStack {
                creteKeyButton(number: 1)
                creteKeyButton(number: 2)
                creteKeyButton(number: 3)
            }
            HStack {
                creteKeyButton(number: 4)
                creteKeyButton(number: 5)
                creteKeyButton(number: 6)
            }
            HStack {
                creteKeyButton(number: 7)
                creteKeyButton(number: 8)
                creteKeyButton(number: 9)
            }
            HStack {
                creteKeyButton(number: 0)
            }
        }.zIndex(2)
    }
    
    private func bottomBar() -> some View {
        return HStack {

            Spacer()
            Button {
                if let pw = password {
                    self.password = String(pw.dropLast())
                    if self.password?.isEmpty == true {
                        self.password = nil
                    }
                }
            } label: {
                Text("Delete")
            }
            .disabled(password == nil)

        }.padding()
    }
    
    private func creteKeyButton(number: Int) -> some View {
        return Button {
        
            updatePassword(number: number)
        } label: {
            Image(systemName: "\(number).circle.fill")
                .resizable().scaledToFit()
                .frame(width: 70, height: 70)
        }

    }
}
