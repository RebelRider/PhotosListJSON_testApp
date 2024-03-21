//
//  PhotoCollectionViewController.swift
//  PhotosListJSON_testApp
//
//  Created by Kirill Smirnov on 20.03.2024.
//

import UIKit


class PhotoCollectionViewController: UIViewController {
    
    init() {
        self.viewModel = PhotoCollectionViewModel()
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        
        // Set a render callback for view model (calls the render method once)
        self.viewModel.setRenderCallback { [weak self] newState in
            self?.render(state: newState)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }
    
    // MARK: - Properties
    private let viewModel: PhotoCollectionViewModel
    private let collectionView: UICollectionView
    private static let reuseId = "cell"
    
    private var openedPhotoDetailCell: PhotoCollectionViewCell? = nil // Tapped cell
    private var openedPhotoDetailVC: PhotoDetailViewController? = nil // Currently opened VC
    
    private var photosToDisplay = [PhotoInfo]()
    
    private var showOnlyFavorites = false
    
    // MARK: - Views
    let albumNumberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Album N"
        textField.keyboardType = .numberPad
        textField.font = UIFont(name: "Arial", size: 12)
        
        // Add a "Done" button to the numeric keyboard
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: nil, action: #selector(doneButtonAction))
        let items = [flexSpace, doneButton]
        toolbar.items = items
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar
        
        // Add padding to the text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.backgroundImage = UIImage() // Removing "Dividers"
        searchBar.returnKeyType = .done // More sense than "Search", right?)
        return searchBar
    }()
    
    let onlyFavoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .red
        button.addTarget(nil, action: #selector(handleOnlyFavoritesButtonTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Config
    private func configureViewController() {
        navigationItem.title = "Photos"
        view.backgroundColor = .systemBackground
        
        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [albumNumberTextField, searchBar, onlyFavoriteButton])
            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.spacing = 7
            return stackView
        }()
        
        view.addSubview(stackView)
        searchBar.delegate = self
        albumNumberTextField.delegate = self
        albumNumberTextField.addTarget(self, action: #selector(albumNumberTextFieldDidChange), for: .editingChanged)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4)
        ])
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.anchor(top: searchBar.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor) // collectionView below the searchBar
        
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: Self.reuseId)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        collectionView.addGestureRecognizer(tapGesture)
        
        AppModel.shared.onPhotosLoaded = { [weak self] in
            self?.filterPhotos()
        } // Handle slow connection filtertering (to not create a separated State)
    }
    
    // MARK: - Methods
    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self.collectionView)
        guard let indexPath = self.collectionView.indexPathForItem(at: point) else { return }
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell else { return }
        self.openedPhotoDetailCell = cell
        if self.openedPhotoDetailVC != nil {
            self.openedPhotoDetailVC?.removeFromParent()
            self.openedPhotoDetailVC = nil
        }
        let photoFrame = navigationController!.view.convert(cell.frame, from: collectionView)
        self.openedPhotoDetailVC = PhotoDetailViewController(photo: photosToDisplay[indexPath.item], photoFrame: photoFrame, initialImage: cell.thumbImageView.image, delegate: self, favoritesModel: self.viewModel.favoritesModel)
        // Add Photo Detail View Controller as a child for NavVC
        navigationController!.view.addSubview(openedPhotoDetailVC!.view)
        navigationController!.addChild(openedPhotoDetailVC!)
        self.openedPhotoDetailVC?.didMove(toParent: navigationController!)
        
        searchBar.resignFirstResponder()
    }
    
}

// MARK: - State
extension PhotoCollectionViewController {
    
    // The struct that represents the state of this view.
    public struct ViewState {
        var photos: [PhotoInfo]
        
        static var empty: ViewState {
            return ViewState(photos: [])
        }
    }
    
    // Renders the given state for this view. Called by ViewModel.
    public func render(state: ViewState) {
        self.photosToDisplay = state.photos
        collectionView.reloadData()
    }
}

// MARK: - PhotoDetailView Delegate
extension PhotoCollectionViewController: PhotoDetailViewControllerDelegate {
    func photoDetailVCDismiss(_ photoDetailViewController: PhotoDetailViewController) {
        print("photoDetailVCDidDismiss >")
        // Remove Photo Detail View Controller from the NavController's child hierarchy
        self.openedPhotoDetailVC?.willMove(toParent: nil)
        self.openedPhotoDetailVC?.removeFromParent()
        self.openedPhotoDetailVC?.view.removeFromSuperview()
        // Update favorite status for the cell
        if let cell = self.openedPhotoDetailCell,
           let indexPath = collectionView.indexPath(for: cell) {
            let photo = photosToDisplay[indexPath.item]
            let isFavorite = self.viewModel.favoritesModel.isFavorite(id: photo.id)
            cell.favoriteButton.setImage(UIImage(systemName: isFavorite ? "heart.fill" : "heart"), for: .normal)
        }
        // Update photosToDisplay and collectionView
        filterPhotos()
        
        self.openedPhotoDetailCell?.thumbImageView.alpha = 1
        self.openedPhotoDetailCell = nil
    }
}

// MARK: - UICollectionView DataSource
extension PhotoCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("photosToDisplay \(photosToDisplay.count)")
        return photosToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.reuseId, for: indexPath) as! PhotoCollectionViewCell
        let cellIndex = indexPath.item
        let photoInfo = photosToDisplay[cellIndex]
        
        let isFavorite = viewModel.isFavorite(id: photoInfo.id)
        cell.setData(thumbnailUrl: photoInfo.thumbnailUrl, album: photoInfo.albumId, title: photoInfo.title, isFavorite: isFavorite)
        cell.delegate = self
        
        return cell
    }

    
}

// MARK: - UICollectionViewDelegate FlowLayout
extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 4 - 5 // This will affect how many columns will fit
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

// MARK: - UITextFieldDelegate album filter
extension PhotoCollectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        filterPhotos()
        return true
    }
    
    @objc func doneButtonAction() {
        albumNumberTextField.resignFirstResponder()
    }
}

// MARK: - UISearchBar Delegate
extension PhotoCollectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterPhotos()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Filter Photos func
extension PhotoCollectionViewController {
    @objc func albumNumberTextFieldDidChange(_ textField: UITextField) {
        filterPhotos()
    }
    
    func filterPhotos() {
        let searchText = searchBar.text ?? ""
        let albumNumber = Int(albumNumberTextField.text ?? "")
        
        photosToDisplay = viewModel.state.photos.filter { photo in
            let matchesSearchText = searchText.isEmpty || photo.title.lowercased().contains(searchText.lowercased())
            let matchesAlbumNumber = albumNumber == nil || photo.albumId == albumNumber
            let matchesFavorite = !showOnlyFavorites || viewModel.isFavorite(id: photo.id)
            return matchesSearchText && matchesAlbumNumber && matchesFavorite
        }
        
        if photosToDisplay.isEmpty {
            print("No photos found for the given search text and album number.")
        }
        
        collectionView.reloadData()
    }
    
}

// MARK: - Favorite Button Handler
extension PhotoCollectionViewController {
    @objc func handleOnlyFavoritesButtonTap() {
        print("handleFavoriteButtonTap >")
        showOnlyFavorites.toggle()
        onlyFavoriteButton.setImage(UIImage(systemName: showOnlyFavorites ? "heart.fill" : "heart"), for: .normal)
        filterPhotos()
    }
}

// MARK: - Favorite Button Delegate
extension PhotoCollectionViewController: PhotoCollectionViewCellDelegate {
    func didTapAddRemoveFavoriteButton(in cell: PhotoCollectionViewCell) {
        print("didTapAddRemoveFavoriteButton >")
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let photo = photosToDisplay[indexPath.item]
        let isFavorite = viewModel.toggleFavorite(id: photo.id)
        UserDefaults.standard.set(isFavorite, forKey: "photo_\(photo.id)")
        cell.favoriteButton.setImage(UIImage(systemName: isFavorite ? "heart.fill" : "heart"), for: .normal)
        collectionView.reloadData()
    }

}
