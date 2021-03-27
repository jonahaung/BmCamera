//
//  onBoardingPage.swift
//  Food
//
//  Created by BqNqNNN on 7/13/20.
//

import Foundation

struct Page : Identifiable {
    var id : Int
    var image : String
    var title : String
    var descrip : String
}

var OnboardingData = [
    Page(id: 0, image: "photoAlbum", title: "Custom Photo & Video Camera", descrip: "We make it simple to capture photos & videos directly from the app. Media items taken from the app are directly saved into the most recently accessed album"),
    
    Page(id: 1, image: "photoAlbum", title: "One Passcode to One Album", descrip: "You can create as many private albums as possible along with its unique passcode. What album you chose to show to someone is totally up to you"),
    Page(id: 2, image: "photoAlbum", title: "Keep Your Passcodes Serious", descrip: "Album Passcodes are unrecoverable. When you lost your passcode, you will also lost the album and all of its media contents"),
    
    Page(id: 3, image: "photoAlbum", title: "Keep Your Album Information Unknown", descrip: "No one can know how many passcodes & albums you have created and each and every album is inaccessible without the passcode")
]
