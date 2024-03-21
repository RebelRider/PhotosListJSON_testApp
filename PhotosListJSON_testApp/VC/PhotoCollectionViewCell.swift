//
//  PhotoCollectionViewCell.swift
//  PhotosListJSON_testApp
//
//  Created by Kirill Smirnov on 20.03.2024.
//

import UIKit

// Represents a single Photo view cell in PhotoCollectionViewController.collectionView
class PhotoCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: PhotoCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(thumbImageView)
        thumbImageView.fillSuperview()
        
        thumbImageView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: thumbImageView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: thumbImageView.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: thumbImageView.centerYAnchor, constant: 26) // place in center?
        ])
        
        addSubview(favoriteButton)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favoriteButton.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            favoriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7),
            favoriteButton.widthAnchor.constraint(equalToConstant: 16),
            favoriteButton.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
    
    // MARK: - Properties
    public let thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true // This is important to make the corner radius visible
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        label.numberOfLines = 0
        label.font = UIFont(name: "Arial", size: 10)
        return label
    }()
    
    private var imageUrl: String = ""
    
    public let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .red
        button.backgroundColor = .clear
        button.addTarget(nil, action: #selector(handleFavoriteButtonTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Config
    func setData(thumbnailUrl: String?, album: Int?, title: String?, isFavorite: Bool) {
        guard let thumbnailUrl = thumbnailUrl else {
            print("empty URL: \(String(describing: thumbnailUrl))")
            return
        }
        thumbImageView.image = nil
        self.imageUrl = thumbnailUrl
        ImageCache.getImage(fromRemoteUrl: thumbnailUrl) { [weak self] image, url in
            guard let self = self else { return }
            if self.imageUrl == url {
                print("thumbImage imageUrl \(imageUrl)")
                self.thumbImageView.image = image
            }
        }
        if let albumId = album {
            titleLabel.text = "\(albumId): \(title ?? "")"
        } else {
            titleLabel.text = title ?? ""
        }
        favoriteButton.setImage(UIImage(systemName: isFavorite ? "heart.fill" : "heart"), for: .normal)
    }
}

// MARK: - Fav button handler
extension PhotoCollectionViewCell {
    @objc func handleFavoriteButtonTap() {
        delegate?.didTapAddRemoveFavoriteButton(in: self)
    }
}

// MARK: - Cell Delegate
protocol PhotoCollectionViewCellDelegate: AnyObject {
    func didTapAddRemoveFavoriteButton(in cell: PhotoCollectionViewCell)
}
