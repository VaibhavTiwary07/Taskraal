//
//  OnboardingCollectionViewCell.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 04/03/25.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: OnboardingCollectionViewCell.self)
    
    @IBOutlet var slideSubstitleLabel: UILabel!
    @IBOutlet var slideTitleLabel: UILabel!
    @IBOutlet var slideImageView: UIImageView!
    
    
    func setup(_ slide:OnboardingSlide){
        slideImageView.image = slide.image
        slideTitleLabel.text = slide.title
        slideSubstitleLabel.text = slide.description
    }
}
