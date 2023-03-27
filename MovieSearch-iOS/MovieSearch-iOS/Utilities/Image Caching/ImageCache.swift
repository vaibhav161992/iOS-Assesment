//
//  ImageCache.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import UIKit

/// Protocol for image caching provider.
protocol ImageCacheProvider {
    func set(image: UIImage, forURL url: URL)
    func image(forURL url: URL) -> UIImage?
    func clear()
}

class ImageCache: ImageCacheProvider {
    
    static var shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    init() {
        cache.countLimit = 200
    }
    
    func set(image: UIImage, forURL url: URL) {
        self.cache.setObject(image, forKey: url.absoluteString as NSString)
    }
    
    func image(forURL url: URL) -> UIImage? {
        self.cache.object(forKey: url.absoluteString as NSString)
    }
    
    func clear() {
        cache.removeAllObjects()
    }
}
