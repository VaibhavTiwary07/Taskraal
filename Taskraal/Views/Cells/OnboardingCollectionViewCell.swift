//
//  OnboardingCollectionViewCell.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 04/03/25.
//

import UIKit


class OnboardingCollectionViewCell: UICollectionViewCell {
    static let identifier = "OnboardingCollectionViewCell"
    
    // MARK: - UI Components
    private let slideImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let slideTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let slideSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubviews(slideImageView, slideTitleLabel, slideSubtitleLabel)
        
        slideImageView.anchor(top: contentView.topAnchor,
                              leading: contentView.leadingAnchor,
                              trailing: contentView.trailingAnchor,
                              paddingTop: 20,
                              paddingLeading: 20,
                              paddingTrailing: 20,
                              height: contentView.frame.size.height * 0.5)
        
        slideTitleLabel.anchor(top: slideImageView.bottomAnchor,
                               leading: contentView.leadingAnchor,
                               trailing: contentView.trailingAnchor,
                               paddingTop: 20,
                               paddingLeading: 20,
                               paddingTrailing: 20)
        
        slideSubtitleLabel.anchor(top: slideTitleLabel.bottomAnchor,
                                  leading: contentView.leadingAnchor,
                                  trailing: contentView.trailingAnchor,
                                  paddingTop: 20,
                                  paddingLeading: 20,
                                  paddingTrailing: 20)
    }
    
    func configure(with slide: OnboardingSlide) {
        slideImageView.image = slide.image
        slideTitleLabel.text = slide.title
        slideSubtitleLabel.text = slide.description
    }
}
