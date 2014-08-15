//
//  BrickView.swift
//  SwiftBrickAttack
//
//  Created by Mike Neill on 8/12/14.
//
//

import UIKit

enum BrickDensityType
{
    case Soft
    case Medium
    case Hard
};

class BrickView: RoundedBoxView
{
    var density : BrickDensityType;
    var hits : Int;
    
    var shouldDie : Bool
    {
        get
        {
            var allowedHits : Int;
            
            switch (density)
            {
                case BrickDensityType.Medium:
                    allowedHits = 2;
                    
                case BrickDensityType.Hard:
                    allowedHits = 3;
                    
                default:
                    allowedHits = 1;
            }
            
            if (allowedHits <= hits)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    }
    
    convenience init()
    {
        self.init(frame: CGRectZero);
    }
    
    override init(frame: CGRect)
    {
        density = BrickDensityType.Soft;
        hits = 0;
        
        super.init(frame: frame);
    }
    
    override func layoutSubviews()
    {
        var color : UIColor;
        
        switch (density)
        {
            case BrickDensityType.Medium:
                color = UIColor.yellowColor();
                
            case BrickDensityType.Hard:
                color = UIColor.redColor();
                
            default:
                color = UIColor.lightGrayColor();
        }
        
        self.color = color;
    }
}
