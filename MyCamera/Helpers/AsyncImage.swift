//
//  AsyncImage.swift
//  MyCamera
//
//  Created by Aung Ko Min on 11/3/21.
//

import Combine
import SwiftUI
import AVKit

struct AsyncImage<Placeholder: View>: View {
    
    @StateObject private var loader: ImageLoader
    private let placeholder: Placeholder
    private let image: (UIImage) -> Image
    private let isVideo: Bool
    
    init(url: URL, isVideo: Bool, @ViewBuilder placeholder: () -> Placeholder, @ViewBuilder image: @escaping (UIImage) -> Image = Image.init(uiImage:)) {
        self.placeholder = placeholder()
        self.image = image
        self.isVideo = isVideo
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: Environment(\.imageCache).wrappedValue))
    }
    
    var body: some View {
        Group {
            if loader.image != nil {
                ZStack {
                    image(loader.image!)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                    if isVideo {
                        Image(systemName: "play.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
            } else {
                placeholder.padding()
                    .onAppear{
                        loader.load(isVideo: isVideo)
                    }
            }
        }
    }
    
}

class ImageLoader: ObservableObject {
    
    @Published var image: UIImage?
    
    private(set) var isLoading = false
    
    private let url: URL
    private var cache: ImageCache?
    
    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
    
    init(url: URL, cache: ImageCache? = nil) {
        self.url = url
        self.cache = cache
    }
    
    deinit {
        cancel()
    }
    
    func load(isVideo: Bool) {
        guard !isLoading else { return }
        
        if let image = cache?[url] {
            self.image = image
            return
        }
        if isVideo {
            onStart()
            getThumbnailImageFromVideoUrl(url: url) { [weak self] image in
                guard let self = self, self.isLoading else { return }
                DispatchQueue.main.async {
                    self.onFinish()
                    self.image = image
                    self.cache(image)
                }
            }
        }else {
            onStart()
            getThumbnailImageFromImageUrl(url: url) { [weak self] image in
                guard let self = self, self.isLoading else { return }
                DispatchQueue.main.async {
                    self.onFinish()
                    self.image = image
                    self.cache(image)
                }
            }
//            cancellable = URLSession.shared.dataTaskPublisher(for: url)
//                .map { $0.data.image?.getThumbnail() }
//                .replaceError(with: nil)
//                .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
//                              receiveOutput: { [weak self] in self?.cache($0) },
//                              receiveCompletion: { [weak self] _ in self?.onFinish() },
//                              receiveCancel: { [weak self] in self?.onFinish() })
//                .subscribe(on: Self.imageProcessingQueue)
//                .receive(on: DispatchQueue.main)
//                .sink { [weak self] in self?.image = $0 }
        }
    }
    
    private func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        
        ImageLoader.imageProcessingQueue.async {
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 1, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
                completion(thumbNailImage.getThumbnail()) //9
            } catch {
                print(error.localizedDescription) //10
                completion(nil) //11
            }
        }
    }
    private func getThumbnailImageFromImageUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        
        ImageLoader.imageProcessingQueue.async {
            do {
                let data = try Data(contentsOf: url)
                let image = data.image?.getThumbnail()
                completion(image)
            } catch {
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    
    func cancel() {
//        cancellable?.cancel()
    }
    
    private func onStart() {
        isLoading = true
    }
    
    private func onFinish() {
        isLoading = false
    }
    
    private func cache(_ image: UIImage?) {
        image.map { cache?[url] = $0 }
    }
}

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCache = TemporaryImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}
protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}

struct TemporaryImageCache: ImageCache {
    private let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 100 // 100 items
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        return cache
    }()
    
    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}

extension Data {
    
//    func decrypt() -> Data? {
//        guard let folerName = UserdefaultManager.shared.currentFolderName else {
//            return nil
//        }
//        do {
//            let originalData = try RNCryptor.decrypt(data: self, withPassword: folerName)
//            return originalData
//            // ...
//        } catch {
//            print(error)
//            return nil
//        }
//    }
//
//    func encrypt() -> Data? {
//        guard let folerName = UserdefaultManager.shared.currentFolderName else {
//            return nil
//        }
//        return RNCryptor.encrypt(data: self, withPassword: folerName)
//    }
    
    var image: UIImage? {
        return UIImage(data: self)
    }
}


extension URL {
    var data: Data? {
        return try? Data(contentsOf: self)
    }
    
    var videoThumbnil: UIImage? {
        let asset = AVAsset(url: self) //2
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
        avAssetImageGenerator.appliesPreferredTrackTransform = true //4
        let thumnailTime = CMTimeMake(value: 1, timescale: 1) //5
        do {
            let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
            let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
            return thumbNailImage
        } catch {
            print(error.localizedDescription) //10
            return nil
        }
    }
}
