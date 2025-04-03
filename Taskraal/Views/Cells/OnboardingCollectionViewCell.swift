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
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 240/255, green: 243/255, blue: 245/255, alpha: 1)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let slideImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        return imageView
    }()
    
    private let slideTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 70/255, green: 90/255, blue: 110/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let slideSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 120/255, green: 140/255, blue: 160/255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let imageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 240/255, green: 243/255, blue: 245/255, alpha: 1)
        view.layer.cornerRadius = 15
        return view
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Apply neumorphic effects after layout
        containerView.addNeumorphicEffect(cornerRadius: 20)
        imageContainer.addInsetNeumorphicEffect(cornerRadius: 15)
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.anchor(top: contentView.topAnchor,
                            leading: contentView.leadingAnchor,
                            bottom: contentView.bottomAnchor,
                            trailing: contentView.trailingAnchor,
                            paddingTop: 15,
                            paddingLeading: 15,
                            paddingBottom: 15,
                            paddingTrailing: 15)
        
        containerView.addSubview(imageContainer)
        imageContainer.anchor(top: containerView.topAnchor,
                             leading: containerView.leadingAnchor,
                             trailing: containerView.trailingAnchor,
                             paddingTop: 25,
                             paddingLeading: 25,
                             paddingTrailing: 25,
                             height: contentView.frame.size.height * 0.45)
        
        imageContainer.addSubview(slideImageView)
        slideImageView.anchor(top: imageContainer.topAnchor,
                             leading: imageContainer.leadingAnchor,
                             bottom: imageContainer.bottomAnchor,
                             trailing: imageContainer.trailingAnchor,
                             paddingTop: 15,
                             paddingLeading: 15,
                             paddingBottom: 15,
                             paddingTrailing: 15)
        
        containerView.addSubview(slideTitleLabel)
        slideTitleLabel.anchor(top: imageContainer.bottomAnchor,
                              leading: containerView.leadingAnchor,
                              trailing: containerView.trailingAnchor,
                              paddingTop: 25,
                              paddingLeading: 20,
                              paddingTrailing: 20)
        
        containerView.addSubview(slideSubtitleLabel)
        slideSubtitleLabel.anchor(top: slideTitleLabel.bottomAnchor,
                                 leading: containerView.leadingAnchor,
                                 trailing: containerView.trailingAnchor,
                                 paddingTop: 15,
                                 paddingLeading: 25,
                                 paddingTrailing: 25)
    }
    
    func configure(with slide: OnboardingSlide) {
        slideImageView.image = slide.image
        slideTitleLabel.text = slide.title
        slideSubtitleLabel.text = slide.description
    }
}
