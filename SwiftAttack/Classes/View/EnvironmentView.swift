//
//  EnvironmentView.swift
//  SwiftBrickAttack
//
//  Created by Mike Neill on 8/13/14.
//
//

import UIKit

protocol EnvironmentViewDelegate
{
    func EnvironmentViewDidTouchDidBegin(eView : EnvironmentView, touch : UITouch);
    func EnvironmentViewDidTouchDidMove(eView : EnvironmentView, touch : UITouch);
    func EnvironmentViewDidTouchDidEnd(eView : EnvironmentView, touch : UITouch);
    func EnvironmentViewDidTap(eView : EnvironmentView, touch : UITouch);
}

class EnvironmentView: UIView
{
    var delegate : EnvironmentViewDelegate?;
    private var didTap : Bool?;
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!)
    {
        didTap = true;
        
        let touch: UITouch = touches.anyObject() as UITouch;
        
        if let d = delegate?
        {
            d.EnvironmentViewDidTouchDidBegin(self, touch: touch);
        }
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!)
    {
        didTap = false;
        
        let touch: UITouch = touches.anyObject() as UITouch;
        
        if let d = delegate?
        {
            d.EnvironmentViewDidTouchDidMove(self, touch: touch);
        }
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!)
    {
        if let tapped = didTap
        {
            let touch: UITouch = touches.anyObject() as UITouch;
            
            if let d = delegate?
            {
                d.EnvironmentViewDidTap(self, touch: touch);
                d.EnvironmentViewDidTouchDidEnd(self, touch: touch);
            }
        }
    }
}
