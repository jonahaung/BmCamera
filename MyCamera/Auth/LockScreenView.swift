//
//  LockScreenView.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import SwiftUI

struct LockScreenView: View {
   
    private var digits = [1, 2, 3, 4, 5, 6]
    @State private var password: String?
    @EnvironmentObject var currentLoginSession: CurrentLoginSession
    @State private var labelText = "Enter Passcode"
    @Environment(\.presentationMode) var presentationMode
    @State private var existingPasswords = UserdefaultManager.shared.passWords
    @State private var isNewUser = false
    
    
    
    var body: some View {
        VStack {
            topBar()
            Image(systemName: "lock.fill" )
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
            Spacer()
            bottomBar()
        }
        .padding()
    }
    
    
}

extension LockScreenView {
    
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
            if isNewUser {
                register(pw: pw)
            }else {
                authenticate(pw: pw)
            }
        } else {
            labelText = " "
        }
    }
    
    private func authenticate(pw: String) {
        if existingPasswords.contains(pw) {
            currentLoginSession.folderName = pw
            UserdefaultManager.shared.currentFolderName = pw
//            currentLoginSession.isLoggingIn = false
            presentationMode.wrappedValue.dismiss()
        } else {
            SoundManager.vibrate(vibration: .error)
            labelText = "Album Doesn't Exist"
            reset()
        }
    }
    private func register(pw: String) {
        if existingPasswords.contains(pw) {
            labelText = "Album Already Exist"
            SoundManager.vibrate(vibration: .error)
        } else {
            existingPasswords.append(pw)
            UserdefaultManager.shared.passWords = existingPasswords
            UserdefaultManager.shared.currentFolderName = pw
            Utils.createDefaultPhotos()
            labelText = "Success! Please login using your password"
            isNewUser = false
            reset()
        }
    }
    private func reset() {
        password = nil
    }
}
extension LockScreenView {
    private func topBar() -> some View {
        return HStack {
            Button {
                isNewUser.toggle()
                labelText = isNewUser ? "Enter passcode for your new album" : "Enter Passcode"
            } label: {
                let title = isNewUser ? "Login" : "New Album"
                let imageName = isNewUser ? "lock.open" : "plus"
                Label(title, systemImage: imageName)
            }
            
            Spacer()
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark")
            }
        }.padding()
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
        }
    }
    
    private func bottomBar() -> some View {
        return HStack {
            
            Button {
                reset()
            } label: {
                Text("Reset")
            }
            .disabled(password == nil)
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

extension Int: Identifiable {
    public var id: Int {
        return self
    }
    
    
}
