//
//  RoundedBoxView.swift
//  SwiftBrickAttack
//
//  Created by Mike Neill on 8/12/14.
//
//

import UIKit

class RoundedBoxView: UIView
{
    var color : UIColor;
    var cornorRadius : CGFloat;
    
    override init(frame: CGRect)
    {
        color = UIColor.blackColor();
        cornorRadius = 5;
        
        super.init(frame: frame);
        
        self.backgroundColor = UIColor.clearColor();
    }
    
    required convenience init(coder aDecoder: NSCoder!)
    {
        self.init(frame: CGRectMake(0, 0, 200, 25));
    }
    
    override func drawRect(rect: CGRect)
    {
        let bPath = UIBezierPath(roundedRect: rect, cornerRadius: cornorRadius);
        let ctx = UIGraphicsGetCurrentContext();
        
        CGContextAddPath(ctx, bPath.CGPath);
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextFillPath(ctx);
    }
}
