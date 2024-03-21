//
//  Cache.swift
//  PhotosListJSON_testApp
//
//  Created by Kirill Smirnov on 20.03.2024.
//

import UIKit


public final class ImageCache {
    private static func cacheImage(remoteImageUrl: String, image: UIImage) {
        guard var cacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
        
        cacheUrl.appendPathComponent("ImageCache")
        
        if !FileManager.default.fileExists(atPath: cacheUrl.path) {
            try? FileManager.default.createDirectory(at: cacheUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        guard let encodedUrl = remoteImageUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        
        cacheUrl.appendPathComponent(encodedUrl)
        cacheUrl.appendPathExtension("png")
        
        guard let data = image.pngData() else { return }
        
        do {
            try data.write(to: cacheUrl)
        } catch {
            print("Error caching image with to \(cacheUrl.path)")
            print("Error: \(error)")
        }
    }
    
    
    public static func getImage(fromRemoteUrl url: String, _ completion: @escaping (UIImage?, String) -> ()) {
        guard let remoteUrl = URL(string: url) else { return }
        guard var cacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
        
        cacheUrl.appendPathComponent("ImageCache")
        
        guard let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        
        cacheUrl.appendPathComponent(encodedUrl)
        cacheUrl.appendPathExtension("png")
        
        if FileManager.default.fileExists(atPath: cacheUrl.path) {
            print("fileExists in cache \(cacheUrl.path)")
            do {
                let imageData = try Data(contentsOf: cacheUrl)
                completion(UIImage(data: imageData), url)
            } catch {
                print("Error loading image. \(error)")
            }
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: remoteUrl) {
                if let image = UIImage(data: data) {
                    cacheImage(remoteImageUrl: url, image: image)
                    DispatchQueue.main.async {
                        completion(image, url)
                    }
                }
            }
        }
    }
    
}
