//
//  BallView.swift
//  SwiftBrickAttack
//
//  Created by Mike Neill on 8/13/14.
//
//

import UIKit

protocol BallViewDelegate
{
    func BallViewCenterDidChange(bView : BallView, center : CGPoint);
}

class BallView: UIView
{
    var delegate : BallViewDelegate?;
    
    override var center: CGPoint
        {
        get
        {
            let centerX = self.frame.origin.x + (self.frame.size.width / 2)
            let centerY = self.frame.origin.y + (self.frame.size.height / 2)
            return CGPointMake(centerX, centerY)
        }
        set
        {
            self.frame.origin.x = newValue.x - (self.frame.size.width / 2);
            self.frame.origin.y = newValue.y - (self.frame.size.height / 2);
            
            if let d = delegate?
            {
                d.BallViewCenterDidChange(self, center: self.center);
            }
        }
    }
    
    convenience override init()
    {
        self.init(position: CGPointMake(0, 0));
    }
    
    convenience init(position: CGPoint)
    {
        self.init(frame: CGRectMake(position.x, position.y, 15, 15));
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame);
    }
    
    required convenience init(coder aDecoder: NSCoder!)
    {
        self.init(frame: CGRectMake(0, 0, 15, 15));
    }
    
    override func layoutSubviews()
    {
        self.backgroundColor = UIColor.clearColor();
    }
    
    override func drawRect(rect: CGRect)
    {
        let bPath = UIBezierPath(ovalInRect: rect);
        
        let ctx = UIGraphicsGetCurrentContext();
        
        CGContextAddPath(ctx, bPath.CGPath);
        CGContextSetFillColorWithColor(ctx, UIColor.orangeColor().CGColor);
        CGContextFillPath(ctx);
    }
}
