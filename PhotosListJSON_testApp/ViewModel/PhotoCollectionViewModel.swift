//
//  PhotoCollectionViewModel.swift
//  PhotosListJSON_testApp
//
//  Created by Kirill Smirnov on 20.03.2024.
//

import UIKit

class PhotoCollectionViewModel: ViewModel {
   
    var favoritesModel = FavoritesModel()

    init() {
        getDataFromModel()
        AppModel.shared.onModelChange = getDataFromModel // Reload data when model changes
    }
    
    private func getDataFromModel() {
        self.photosToDisplay = AppModel.shared.photos.values.compactMap { $0 }
        state = ViewState(photos: self.photosToDisplay)
        favoritesModel.loadFavorites()
    }
    
    // MARK: - State Management
    
    typealias ViewState = PhotoCollectionViewController.ViewState
    
    private var renderCallback: RenderStateCallback?
    
    public func setRenderCallback(_ renderCallback: @escaping RenderStateCallback) {
        self.renderCallback = renderCallback
        // Make a callback once to initialize view's state
        self.renderCallback?(state)
    }
    
    public private(set) var state: ViewState = .empty {
        didSet {
            self.renderCallback?(state)
        }
    }
    private var photosToDisplay = [PhotoInfo]()
    
    // MARK: - Favorites Management
    func toggleFavorite(id: Int) -> Bool {
        return favoritesModel.toggleFavorite(id: id)
    }

    func isFavorite(id: Int) -> Bool {
        return favoritesModel.isFavorite(id: id)
    }
}
