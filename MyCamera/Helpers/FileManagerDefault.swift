//
//  FileManagerDefault.swift
//  MyCamera
//
//  Created by Aung Ko Min on 25/3/21.
//

import Foundation

class FileManagerDefault {
    
    static let shared = FileManagerDefault()
    
    private let manager = FileManager.default
    
    func getCurrentFolderUrl(for folerName: String) -> URL? {
        let folderPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(folerName)
        if !manager.fileExists(atPath: folderPath) {
            do {
                try manager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            } catch { print(error) }
        }
        
        return URL(string: folderPath)
    }
    
}
