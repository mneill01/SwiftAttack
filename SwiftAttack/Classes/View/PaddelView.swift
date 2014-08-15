//
//  PaddelView.swift
//  SwiftBrickAttack
//
//  Created by Mike Neill on 8/12/14.
//
//

import UIKit

protocol PaddelViewDelegate
{
    func PaddelViewCenterDidChange(pView : PaddelView, center : CGPoint);
}

class PaddelView: RoundedBoxView
{
    var delegate : PaddelViewDelegate?;
    var direction : PaddleDirection;
    
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
            if (newValue.x < self.center.x)
            {
                self.direction = PaddleDirection.Right;
            }
            else if (newValue.x > self.center.x)
            {
                self.direction = PaddleDirection.Left;
            }
            else
            {
                self.direction = PaddleDirection.None;
            }
            
            self.frame.origin.x = newValue.x - (self.frame.size.width / 2);
            self.frame.origin.y = newValue.y - (self.frame.size.height / 2);
            
            if let d = delegate?
            {
                d.PaddelViewCenterDidChange(self, center: self.center);
            }
        }
    }
    
    convenience init()
    {
        self.init(position: CGPointMake(0, 0));
    }
    
    convenience init(position: CGPoint)
    {
        self.init(frame: CGRectMake(position.x, position.y, 100, 15));
    }
    
    override init(frame: CGRect)
    {
        direction = PaddleDirection.None;
        super.init(frame: frame);
        self.color = UIColor.grayColor();
    }
}

enum PaddleDirection
{
    case None
    case Left
    case Right
};