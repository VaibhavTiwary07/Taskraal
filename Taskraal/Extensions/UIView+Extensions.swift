//
//  UIView+Extensions.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 04/03/25.
//
import UIKit
import Foundation

extension UIView{
    @IBInspectable var cornerRadius: CGFloat{
        get{return cornerRadius}
        set{
            self.layer.cornerRadius = newValue
        }
    }
    
    
}
