//
//  LockScreenView.swift
//  MyCamera
//
//  Created by Aung Ko Min on 9/3/21.
//

import SwiftUI

enum LockScreenType {
    
    case appSetUp, newAlbum, updateCurrentAlbum, viewPhotoGallery
    
    var title: String {
        switch self {
        case .newAlbum:
            return "Enter passcode for your new album"
        case .updateCurrentAlbum:
            return "Enter passcode for your desired album"
        case .viewPhotoGallery:
            return "Please enter Album Passcode"
        case .appSetUp:
            return "Setup Your First Album"
        }
    }
}
struct LockScreenView: View {
    
    let lockScreenType: LockScreenType

    @Environment(\.presentationMode) var presentationMode
    private let digits = [1, 2, 3, 4, 5, 6]
    @State private var password: String?
    
    @State private var labelText = "Login"
    @State private var existingPasswords = UserdefaultManager.shared.passWords
    
    @State private var isNewUser = false {
        didSet {
            labelText = isNewUser ? LockScreenType.newAlbum.title : LockScreenType.viewPhotoGallery.title
            tintColor = isNewUser ? Color(.systemGreen) : .blue
        }
    }
    let completion: ((_ selectedImage: String) -> Void)?
    @State private var isLoggedIn = false
    
    @State private var tintColor: Color = .blue
    
    var body: some View {
        VStack {
            Image(systemName: isLoggedIn ? "lock.open" : "lock.fill" ).font(.title).foregroundColor(.orange).padding()
            Spacer()
            Text(labelText)
                .font(.headline)
                .padding()
                .multilineTextAlignment(.center)
            
            digitsView()
            Spacer()
            numberPad
           
            Spacer()
            bottomBar()
        }
        .padding()
        .accentColor(tintColor)
        .onAppear{
            isNewUser = lockScreenType == .newAlbum || lockScreenType == .appSetUp
            labelText = lockScreenType.title
        }
       
       
    }
}

extension LockScreenView {
    
    private func updatePassword(number: Int) {
        guard password?.count ?? 0 < 7 else {
            return
        }
        SoundManager.vibrate(vibration: .rigid)
        
        guard var pw = password else {
            password = number.description
            return
        }
        pw = pw.appending(number.description)
        password = pw
        checkPassword(pw: pw)
    }
    
    private func checkPassword(pw: String) {
    
        let isValid = pw.count == 6
       
        if isValid {
            if isNewUser {
                register(pw: pw)
            }else {
                authenticate(pw: pw)
            }
            
        }
    }
    
    private func authenticate(pw: String) {
        if existingPasswords.contains(pw) {
//            currentLoginSession.folderName = pw
            UserdefaultManager.shared.currentFolderName = pw
            isLoggedIn = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                reset()
                completion?(pw)
                switch lockScreenType {
                case .viewPhotoGallery:
                    
                    presentationMode.wrappedValue.dismiss()
                case .updateCurrentAlbum:
                    presentationMode.wrappedValue.dismiss()
                case .newAlbum:
                    presentationMode.wrappedValue.dismiss()
                case .appSetUp:
                    UserdefaultManager.shared.doneSetup = true
                }
            }
        } else {
            isLoggedIn = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AlertPresenter.show(title: "Wrong Passcode", message: "However, you can create a new album associated with this passcode") { _ in
                    reset()
                    isNewUser = false
                }
            }
        }
    }
    
    private func register(pw: String) {
        if existingPasswords.contains(pw) {
            isLoggedIn = false
            AlertPresenter.show(title: "Invalid Passcode", message: "This passcode has been assigned to one of the existing albums") { _ in
                reset()
                isNewUser = true
            }
        } else {
            isLoggedIn = true
            existingPasswords.append(pw)
            UserdefaultManager.shared.passWords = existingPasswords
            UserdefaultManager.shared.currentFolderName = pw
            
            AlertPresenter.show(title: "New Album Created", message: "An album associated with this passcode is successfully created. Please log-in to get access to this album") { _ in
                
                reset()
                withAnimation{
                    isNewUser = false
                }
                
            }
        }
    }
    private func reset() {
        password = nil
        
    }
}
extension LockScreenView {
    
    private func digitsView() -> some View {
        return HStack(spacing: 1) {
            ForEach(digits) { digit in
                let typed = (password?.count ?? 0) >= digit
                let imageName = typed ? "circlebadge.fill" : "circlebadge"
                Image(systemName: imageName).opacity(0.4)
            }
        }.font(.headline)
    }
    
    private var numberPad: some View {
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
        return VStack {
            HStack {
                
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
            }.font(.callout).padding()
            
            Button(isNewUser ? "Login" : "Add New Album") {
                withAnimation{
                    isNewUser.toggle()
                }
            }
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
