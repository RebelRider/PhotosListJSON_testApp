//
//  FavoritesModel.swift
//  PhotosListJSON_testApp
//
//  Created by Kirill Smirnov on 21.03.2024.
//

import Foundation

class FavoritesModel {
    private var favorites: [Int: Bool] = [:]

    init() {
        loadFavorites()
    }

    func toggleFavorite(id: Int) -> Bool {
        let isFavorite = !(favorites[id] ?? false)
        favorites[id] = isFavorite
        UserDefaults.standard.set(isFavorite, forKey: "photo_\(id)")
        print("Set favorite status for photo \(id): \(isFavorite)")
        UserDefaults.standard.synchronize() // Implicit sync UserDefaults
        return isFavorite
    }

    func isFavorite(id: Int) -> Bool {
        return favorites[id] ?? false
    }

    func loadFavorites() {
            print("loadFavorites >")
            let defaults = UserDefaults.standard
            for photo in AppModel.shared.photos.values {
                let isFavorite = defaults.bool(forKey: "photo_\(photo.id)")
                if isFavorite {
                    DispatchQueue.main.async {
                        self.favorites[photo.id] = true
                    }
                    print("Loaded favorite status for photo \(photo.id): \(isFavorite)")
                }
            }
    }
}
