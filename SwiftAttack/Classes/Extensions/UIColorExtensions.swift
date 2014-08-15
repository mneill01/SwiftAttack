//
//  UIColorExtensions.swift
//  SwiftBrickAttack
//
//  Created by Mike Neill on 8/13/14.
//
//

import UIKit

extension UIColor
{
    class func RandomColor() -> UIColor
    {
        let red : CGFloat = CGFloat(arc4random() % 255) / 255;
        let green : CGFloat = CGFloat(arc4random() % 255) / 255;
        let blue : CGFloat = CGFloat(arc4random() % 255) / 255;
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0);
    }
}