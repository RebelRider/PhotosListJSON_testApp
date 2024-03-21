//
//  PhotoDetailViewController.swift
//  PhotosListJSON_testApp
//
//  Created by Kirill Smirnov on 20.03.2024.
//

import UIKit


class PhotoDetailViewController: UIViewController {
    
    private var favoritesModel: FavoritesModel // Inject FavoritesModel
      
      init(photo: PhotoInfo, photoFrame: CGRect, initialImage: UIImage? = nil, delegate: PhotoDetailViewControllerDelegate? = nil, favoritesModel: FavoritesModel) {
          self.photo = photo
          self.photoFrame = photoFrame
          self.delegate = delegate
          self.imageView.image = initialImage
          self.favoritesModel = favoritesModel
          
          super.init(nibName: nil, bundle: nil)
      }
    
    required init?(coder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
    }
    
    // MARK: - Properties
    private var photo: PhotoInfo
    private let photoFrame: CGRect
    public weak var delegate: PhotoDetailViewControllerDelegate? = nil
    
    // The height for the popup description view.
    private var descriptionViewHeight: CGFloat {
        return descriptionLabel.intrinsicContentSize.height + 40
    }
    
    // MARK: - Config
    private func configureViewController() {
        view.backgroundColor = .clear
        view.addSubview(imageView)
        
        // Add corner radius
        imageView.layer.cornerRadius = 14
        imageView.clipsToBounds = true
        
        ImageCache.getImage(fromRemoteUrl: self.photo.url) { [weak self] image, _ in
            guard let self = self else { return }
            self.imageView.image = image
        }
        imageView.frame = photoFrame
        imageView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        view.addSubview(addRemoveFavoriteButton)
        addRemoveFavoriteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addRemoveFavoriteButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 10),
            addRemoveFavoriteButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10),
            addRemoveFavoriteButton.widthAnchor.constraint(equalToConstant: 24),
            addRemoveFavoriteButton.heightAnchor.constraint(equalToConstant: 22)
        ])
        addRemoveFavoriteButton.isSelected = isFavorite(id: photo.id)
        
        view.addSubview(descriptionView)
        descriptionView.frame = CGRect(x: 0, y: imageView.frame.maxY, width: view.bounds.width, height: descriptionViewHeight)
        descriptionView.alpha = 1
        
        view.addSubview(topBar)
        topBar.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 90)
        topBar.alpha = 0
        
        showPhotoDetailView()
    }
    
    @objc private func backButtonPressed() {
        hidePhotoDetailView()
    }
    
    private func setBackgroundAlpha(_ alpha: CGFloat) {
        self.view.backgroundColor = UIColor.systemBackground.withAlphaComponent(alpha)
        self.topBar.subviews[0].alpha = alpha
    }
    
    //MARK: - show
    public func showPhotoDetailView() {
        print("showPhotoDetailView >")
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Calculate the final frame for the image view
        let photoFrameAspectRatio = photoFrame.width / photoFrame.height
        let finalImageWidth = screenWidth
        let finalImageHeight = finalImageWidth / photoFrameAspectRatio
        let finalFrame = CGRect(x: 0, y: screenHeight / 2 - finalImageHeight / 2, width: finalImageWidth, height: finalImageHeight)
        
        // Animation
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn]) {
            self.imageView.transform = .identity
            self.imageView.frame = finalFrame
            self.topBar.alpha = 1.0
            self.view.backgroundColor = .systemBackground
            self.descriptionView.alpha = 1
            self.descriptionView.frame = CGRect(x: 0, y: finalFrame.origin.y + finalFrame.height,
                                                width: finalFrame.width, height: self.descriptionViewHeight)
        } completion: { _ in
            self.delegate?.photoDetailVCAppear?(self)
        }
    }
    
    //MARK: - hide
    public func hidePhotoDetailView(_ velocity: CGFloat = 0.2) {
        print("hidePhotoDetailView >")
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
            // Hide the image view and topBar
            self.imageView.transform = .identity
            self.imageView.frame = self.photoFrame
            self.view.backgroundColor = .clear
            self.topBar.alpha = 0
            self.descriptionView.alpha = 0
            
        } completion: { _ in
            self.delegate?.photoDetailVCDismiss?(self)
        }
    }
    
    
    // MARK: - Views
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    public let addRemoveFavoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .red
        button.backgroundColor = .clear
        button.addTarget(nil, action: #selector(toggleFavoriteStatus), for: .touchUpInside)
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    private lazy var barTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Arial", size: 17)
        label.text = "Photo Preview"
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setTitle(nil, for: .normal)
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.imageView?.centerInSuperview()
        button.imageView?.setSize(height: 24, width: 24)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, height: 40)
        
        contentView.addSubview(barTitleLabel)
        barTitleLabel.centerX(inView: contentView)
        barTitleLabel.center(inView: contentView, yConstant: -5)
        let bottomLine = UIView()
        bottomLine.backgroundColor = .systemGray6
        view.addSubview(bottomLine)
        bottomLine.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, height: 1)
        
        contentView.addSubview(backButton)
        backButton.centerY(inView: contentView, constant: -5)
        backButton.anchor(left: contentView.leftAnchor, spacingLeft: 10, width: 24, height: 24)
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = photo.title
        label.numberOfLines = 3
        label.textColor = .black
        return label
    }()
    
    private lazy var descriptionView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(descriptionLabel)
        descriptionLabel.anchor(left: view.leftAnchor, right: view.rightAnchor, spacingLeft: 20, spacingRight: 20)
        descriptionLabel.centerY(inView: view)
        return view
    }()
}

// MARK: - PhotoDetailViewControllerDelegate
@objc protocol PhotoDetailViewControllerDelegate {
    @objc optional func photoDetailVCDismiss(_ photoDetailViewController: PhotoDetailViewController)
    @objc optional func photoDetailVCAppear(_ photoDetailViewController: PhotoDetailViewController)
}

// MARK: - Favorites Management
extension PhotoDetailViewController {
    @objc func toggleFavoriteStatus() {
        print("toggleFavoriteStatus >")
        let isFavorite = favoritesModel.toggleFavorite(id: photo.id)
        addRemoveFavoriteButton.isSelected = isFavorite
    }
    
    func isFavorite(id: Int) -> Bool {
        print("isFavorite \(id) >")
        return favoritesModel.isFavorite(id: id)
    }
}
