//
//  AppModel.swift
//  PhotosListJSON_testApp
//
//  Created by Kirill Smirnov on 20.03.2024.
//

import UIKit

final class AppModel: NSObject {
    
    public private(set) var photos = [Int : PhotoInfo]() // Dictionary [id: PhotoInfo]
    public private(set) var photosPerAlbum = [Int : [PhotoInfo]]() // Dictionary format: [albumId: [PhotoInfo]]
    
    // Singleton instance
    public static let shared = AppModel()
    
    private override init() {
        super.init()
        print("AppModel init >")
        loadPhotos()
    }
    
    // MARK: - Methods
    private func loadPhotos() { // Loads all photos from JSON
        print("loadPhotos >")
        self.photosPerAlbum.removeAll()
        
        APIService.fetchAllPhotos { photos, error in
            if let error = error {
                print("Error fetching photos. \(error)")
                return
            }
            
            for photo in photos {
                self.photos[photo.id] = photo
                if self.photosPerAlbum[photo.albumId] == nil {
                    self.photosPerAlbum[photo.albumId] = []
                }
                self.photosPerAlbum[photo.albumId]?.append(photo)
            }
            
            self.modelDidChange() // Notify the model changes
           
            DispatchQueue.main.async { self.onPhotosLoaded?() }  // Call the onPhotosLoaded closure after all photos have been loaded and processed
        }
    }
    
    // MARK: - Model Change Handler
    var onModelChange: (() -> Void)?
    
    var onPhotosLoaded: (() -> Void)?
    
    // Call this when the model changes
    private func modelDidChange() {
        onModelChange?()
    }
}
