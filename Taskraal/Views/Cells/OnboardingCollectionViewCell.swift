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
        view.backgroundColor = UIColor.white // Pure white background
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let slideImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.tintColor = UIColor(red: 94/255, green: 132/255, blue: 226/255, alpha: 1.0) // Blue accent
        return imageView
    }()
    
    private let slideTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0) // Dark blue text
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let slideSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 130/255, green: 140/255, blue: 150/255, alpha: 1.0) // Medium gray text
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let imageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white // Pure white background
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
        
        // Clean up any previous neumorphic effects
        containerView.layer.sublayers?.filter { $0.name == "neumorphicShadow" }.forEach { $0.removeFromSuperlayer() }
        imageContainer.layer.sublayers?.filter { $0.name == "neumorphicShadow" }.forEach { $0.removeFromSuperlayer() }
        
        // Apply neumorphic effects only if the view has valid dimensions
        if containerView.bounds.width > 0 && containerView.bounds.height > 0 {
            containerView.addNeumorphicEffect(cornerRadius: 20, backgroundColor: UIColor.white)
        }
        
        if imageContainer.bounds.width > 0 && imageContainer.bounds.height > 0 {
            imageContainer.addInsetNeumorphicEffect(cornerRadius: 15, backgroundColor: UIColor.white)
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Add container view to content view with proper constraints
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add image container with flexible height based on available space
        containerView.addSubview(imageContainer)
        let imageContainerHeightConstraint = imageContainer.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.45)
        imageContainerHeightConstraint.priority = .defaultHigh // Lower priority to avoid conflicts
        
        NSLayoutConstraint.activate([
            imageContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25),
            imageContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            imageContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
            imageContainerHeightConstraint
        ])
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Add image view with proper padding
        imageContainer.addSubview(slideImageView)
        NSLayoutConstraint.activate([
            slideImageView.topAnchor.constraint(equalTo: imageContainer.topAnchor, constant: 15),
            slideImageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor, constant: 15),
            slideImageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor, constant: -15),
            slideImageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: -15)
        ])
        slideImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add title label with proper constraints
        containerView.addSubview(slideTitleLabel)
        NSLayoutConstraint.activate([
            slideTitleLabel.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 25),
            slideTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            slideTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
        slideTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subtitle label with proper constraints
        containerView.addSubview(slideSubtitleLabel)
        NSLayoutConstraint.activate([
            slideSubtitleLabel.topAnchor.constraint(equalTo: slideTitleLabel.bottomAnchor, constant: 15),
            slideSubtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            slideSubtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
            slideSubtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -25)
        ])
        slideSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(with slide: OnboardingSlide) {
        slideImageView.image = slide.image
        slideTitleLabel.text = slide.title
        slideSubtitleLabel.text = slide.description
    }
}
