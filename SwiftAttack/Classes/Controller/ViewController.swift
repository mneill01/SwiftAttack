//
//  ViewController.swift
//  SwiftBrickAttack
//
//  Created by Mike Neill on 8/12/14.
//
//

import UIKit

class ViewController: UIViewController, EnvironmentViewDelegate, UICollisionBehaviorDelegate, PaddelViewDelegate, BallViewDelegate
{
    // Private Properties
    private let _paddleView : PaddelView;
    private let _ballView : BallView;
    
    private var _dynamicAni : UIDynamicAnimator!;
    private var _collisionBehavior : UICollisionBehavior!;
    private var _paddleDynamicItemBehavior : UIDynamicItemBehavior!;
    private var _ballDynamicItemBehavior : UIDynamicItemBehavior!;
    private var _ballGravityBehvaior : UIGravityBehavior!;
    
    private var _bricks : [BrickView];
    private var _ballIsMoving : Bool;
    
    // Constants
    private let _TopBoundryIdentifier : String = "TopBoundry";
    private let _LeftBoundryIdentifier : String = "LeftBoundry";
    private let _RightBoundryIdentifier : String = "RightBoundry";
    
    private let _PaddleVelocityMultiplier : CGFloat = 50;
    private let _BallVelocityMultiplier : CGFloat = 1000;
    
    private let _PaddleDefaultResistance : CGFloat = 0.25;
    private let _PaddleMaxResistance : CGFloat = 100.0;
    
    private let _ballSpeedMax : CGFloat = 800;
    
    private let _ballGravityDefaultMagnitude : CGFloat = 0.5;
    private let _ballGravityMaxMagnitude : CGFloat = 10.0;
    private let _ballBoundryMagnitudeMultiplier : CGFloat = 0.00001;
    private let _ballPaddleMagnitudeMultiplier : CGFloat = 0.000025;
    private let _ballGravityMultiplier : CGFloat = 0.0001;
    
    private let _NumBricks : Int = 30;
    private let _BricksPerRow : Int = 5;
    private let _BrickPadding: CGFloat = 5;
    private let _BricksTopPadding : CGFloat = 50;
    private let _BricksLeftPadding : CGFloat = 10;
    private let _BricksRightPadding : CGFloat = 10;
    
    private let _PushDirectionRight : CGFloat = 0.0;
    private let _PushDirectionDown : CGFloat = 90.0;
    private let _PushDirectionLeft : CGFloat = 180.0;
    private let _PushDirectionUp : CGFloat = 270.0;
    
    private let _maxLives : Int = 3;
    private var _usedLives : Int = 0;
    
    required init(coder aDecoder: NSCoder!)
    {
        _paddleView = PaddelView();
        _ballView = BallView();
        
        _dynamicAni = UIDynamicAnimator();
        _collisionBehavior = UICollisionBehavior();
        _paddleDynamicItemBehavior = UIDynamicItemBehavior();
        _ballDynamicItemBehavior = UIDynamicItemBehavior();
        _ballGravityBehvaior = UIGravityBehavior();
        
        _ballIsMoving = false;
        _bricks = [BrickView]();
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // setup scene
        let eView = self.view as EnvironmentView;
        eView.delegate = self;
        
        _paddleView.delegate = self;
        _ballView.delegate = self;
        
        self.view.addSubview(_paddleView);
        self.view.addSubview(_ballView);
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        // set frames
        _paddleView.frame.origin = CGPointMake((self.view.bounds.size.width - _paddleView.frame.size.width) * 0.5, self.view.bounds.size.height - ((self.view.bounds.size.height - _paddleView.frame.size.height) * 0.1));
        _ballView.frame.origin = CGPointMake(_paddleView.frame.origin.x + (_paddleView.frame.size.width * 0.5), _paddleView.frame.origin.y - _ballView.frame.size.height);
        
        self.BuildBricks();
        
        // set behaviors
        self.SetBehaviors();
        self.SetBoundries();
    }
    
    /*
    * Build Blocks
    */
    
    func BuildBricks()
    {
        
        let boundsWidth = self.view.bounds.size.width - _BricksLeftPadding - _BricksRightPadding;
        let totalPadding = CGFloat(_BricksPerRow - 1) * _BrickPadding;
        let brickWidth = (boundsWidth - totalPadding) / CGFloat(_BricksPerRow);
        let brickHeight : CGFloat = 15.0;
        
        var lPos = CGPointMake(_BricksLeftPadding, _BricksTopPadding);
        var numRows = 0;
        var randMax : UInt32 = 3;
        
        for var i = 0; i < _NumBricks; i++
        {
            var brickView = BrickView(frame: CGRectMake(lPos.x, lPos.y, brickWidth, brickHeight));
            brickView.tag = i;
            self.view.addSubview(brickView);
            _bricks += [brickView];
            
            let randNum : UInt32 = arc4random() % randMax;
            
            switch (randNum)
            {
                case 1:
                    brickView.density = BrickDensityType.Medium;
                
                case 2:
                    brickView.density = BrickDensityType.Hard;
                
                default:
                    brickView.density = BrickDensityType.Soft;
            }
            
            lPos.x += brickView.frame.size.width + _BrickPadding;
            
            // if the next brick will hit the boundries, then jump to the next row
            if ((i - (numRows * _BricksPerRow)) + 1 == _BricksPerRow)
            {
                lPos.x = _BricksLeftPadding;
                lPos.y = brickView.frame.origin.y + brickView.frame.size.height + _BrickPadding;
                numRows++;
            }
        }
    }
    
    /*
    * Setup Behaviors
    */
    
    func SetBehaviors()
    {
        _dynamicAni = UIDynamicAnimator();
        _collisionBehavior = UICollisionBehavior();
        _paddleDynamicItemBehavior = UIDynamicItemBehavior();
        _ballDynamicItemBehavior = UIDynamicItemBehavior();
        _ballGravityBehvaior = UIGravityBehavior();
        
        // paddle view dynamic behavior
        _paddleDynamicItemBehavior.addItem(_paddleView);
        _paddleDynamicItemBehavior.allowsRotation = false;
        _paddleDynamicItemBehavior.elasticity = 0.5;
        _paddleDynamicItemBehavior.resistance = _PaddleDefaultResistance;
        _paddleDynamicItemBehavior.density = 10000000;
        _paddleDynamicItemBehavior.addLinearVelocity(CGPointMake(_PaddleVelocityMultiplier, 0), forItem: _paddleView);
        _dynamicAni.addBehavior(_paddleDynamicItemBehavior);
        
        // ball view dynamic behavior
        _ballDynamicItemBehavior.addItem(_ballView);
        _ballDynamicItemBehavior.elasticity = 0.75;
        _ballDynamicItemBehavior.resistance = 0.0;
        _ballDynamicItemBehavior.density = 0.25;
        _ballDynamicItemBehavior.allowsRotation = false;
        
        // brick dynamic behavior
        let brickDynamicItemBehavior : UIDynamicItemBehavior = UIDynamicItemBehavior(items: _bricks);
        brickDynamicItemBehavior.elasticity = 0.95;
        brickDynamicItemBehavior.resistance = 0.25;
        brickDynamicItemBehavior.density = 1000;
        brickDynamicItemBehavior.allowsRotation = false;
        _dynamicAni.addBehavior(brickDynamicItemBehavior);
        
        // collision detection
        _collisionBehavior.translatesReferenceBoundsIntoBoundary = true;
        _collisionBehavior.collisionDelegate = self;
        _dynamicAni.addBehavior(_collisionBehavior);
    }
    
    func ClearAllBehaviors()
    {
        _dynamicAni.removeAllBehaviors();
        
        _dynamicAni = nil;
        _collisionBehavior = nil;
        _paddleDynamicItemBehavior = nil;
        _ballDynamicItemBehavior = nil;
        _ballGravityBehvaior = nil;
    }
    
    func SetBoundries()
    {
        // set boundries
        _collisionBehavior.addBoundaryWithIdentifier(_TopBoundryIdentifier, fromPoint: CGPointMake(0, 0), toPoint: CGPointMake(self.view.bounds.size.width, 0));
        _collisionBehavior.addBoundaryWithIdentifier(_LeftBoundryIdentifier, fromPoint: CGPointMake(0, 0), toPoint: CGPointMake(0, self.view.bounds.size.height));
        _collisionBehavior.addBoundaryWithIdentifier(_RightBoundryIdentifier, fromPoint: CGPointMake(self.view.bounds.size.width, 0), toPoint: CGPointMake(self.view.bounds.size.width, self.view.bounds.size.height));
        
        // detect collision on items
        _collisionBehavior.addItem(_paddleView);
        
        for brickView in _bricks as [BrickView]
        {
            if (!brickView.shouldDie)
            {
                _collisionBehavior.addItem(brickView);
            }
        }
    }
    
    func PushView(view : UIView, angleInDegrees : CGFloat = 0.0, magnitude : CGFloat = 0.05)
    {
        let pushBehavior = UIPushBehavior(items: [view], mode: UIPushBehaviorMode.Instantaneous);
        pushBehavior.magnitude = magnitude;
        pushBehavior.angle = angleInDegrees / 180.0  * CGFloat(M_PI);
        _dynamicAni.addBehavior(pushBehavior);
    }
    
    func PushView(view : UIView, direction : CGVector, magnitude : CGFloat = 0.15)
    {
        let pushBehavior = UIPushBehavior(items: [view], mode: UIPushBehaviorMode.Instantaneous);
        pushBehavior.magnitude = magnitude;
        pushBehavior.pushDirection = direction;
        _dynamicAni.addBehavior(pushBehavior);
    }
    
    /*
    * UICollisionBehavior Delegates
    */
    
    func collisionBehavior(behavior: UICollisionBehavior!, beganContactForItem item: UIDynamicItem!, withBoundaryIdentifier identifier: String!, atPoint p: CGPoint)
    {
        if (item.isKindOfClass(UIView))
        {
            if (item as UIView == _paddleView)
            {
                if (identifier == _RightBoundryIdentifier)
                {
                    _paddleDynamicItemBehavior.addLinearVelocity(CGPointMake(_PaddleVelocityMultiplier * -1, 0), forItem: _paddleView);
                }
                else if (identifier == _LeftBoundryIdentifier)
                {
                    _paddleDynamicItemBehavior.addLinearVelocity(CGPointMake(_PaddleVelocityMultiplier, 0), forItem: _paddleView);
                }
            }
            else if (item as UIView == _ballView)
            {
                var direction : CGFloat = 0.0;
                
                switch (identifier)
                {
                    case _RightBoundryIdentifier:
                        direction = _PushDirectionLeft;
                    
                    case _LeftBoundryIdentifier:
                        direction = _PushDirectionRight;
                    
                    case _TopBoundryIdentifier:
                        direction = _PushDirectionDown;
                    
                    default:
                        direction = _PushDirectionUp;
                }
                
                let ballSpeed = SpeedForBall();
                var pushMag = ballSpeed * _ballBoundryMagnitudeMultiplier;
                
                PushView(_ballView, angleInDegrees: CGFloat(direction), magnitude: pushMag);
            }
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior!, beganContactForItem item1: UIDynamicItem!, withItem item2: UIDynamicItem!, atPoint p: CGPoint)
    {
        if (item1.isKindOfClass(UIView) && item2.isKindOfClass(UIView))
        {
            // if the ball and paddle collided, then push the ball up to increase velocity
            if (
                (item1 as UIView == _paddleView || item2 as UIView == _paddleView)
                && (item1 as UIView == _ballView || item2 as UIView == _ballView)
            )
            {
                if (SpeedForBall() < _ballSpeedMax)
                {
                    let mag : CGFloat = SpeedForBall() * _ballPaddleMagnitudeMultiplier;
                    
                    PushView(_ballView, angleInDegrees: _PushDirectionUp, magnitude: mag);
                    
                    if (_paddleView.direction == PaddleDirection.Left)
                    {
                        PushView(_ballView, angleInDegrees: _PushDirectionLeft, magnitude: mag);
                    }
                    else
                    {
                        PushView(_ballView, angleInDegrees: _PushDirectionRight, magnitude: mag);
                    }
                }
            }
            // if the ball and a brick collided
            else if (
                (item1 as UIView == _ballView || item2 as UIView == _ballView)
                    && (item1.isKindOfClass(BrickView) || item2.isKindOfClass(BrickView))
                )
            {
                var brickView : BrickView;
                
                if (item1.isKindOfClass(BrickView))
                {
                    brickView = item1 as BrickView;
                }
                else
                {
                    brickView = item2 as BrickView;
                }
                
                brickView.hits++;
                
                if (brickView.shouldDie)
                {
                    brickView.removeFromSuperview();
                    _collisionBehavior.removeItem(brickView);
                    _dynamicAni.updateItemUsingCurrentState(_ballView);
                }
            }
        }
    }
    
    /*
    * EnvironmentView Delegates
    */
    
    func EnvironmentViewDidTap(eView: EnvironmentView, touch: UITouch)
    {
        // disable paddle velocity
        _paddleDynamicItemBehavior.resistance = _PaddleMaxResistance;
        
        // get the ball moving
        if (!_ballIsMoving)
        {
            // add behaviors to get the ball moving
            _dynamicAni.addBehavior(_ballDynamicItemBehavior);
            _collisionBehavior.addItem(_ballView);
            
            _ballGravityBehvaior.addItem(_ballView);
            _ballGravityBehvaior.magnitude = _ballGravityDefaultMagnitude;
            _dynamicAni.addBehavior(_ballGravityBehvaior);
            
            PushView(_ballView, angleInDegrees: _PushDirectionUp);
            
            _ballIsMoving = true;
        }
    }
    
    func EnvironmentViewDidTouchDidBegin(eView: EnvironmentView, touch: UITouch)
    {
        _paddleDynamicItemBehavior.resistance = _PaddleMaxResistance;
    }
    
    func EnvironmentViewDidTouchDidMove(eView: EnvironmentView, touch: UITouch)
    {
        let tLoc = touch.locationInView(touch.view.window) as CGPoint;
        
        // heading right
        if (_paddleView.center.x > tLoc.x)
        {
            _paddleDynamicItemBehavior.addLinearVelocity(CGPointMake((_PaddleVelocityMultiplier * 2) * -1, 0), forItem: _paddleView);
        }
        // heading left
        else if (_paddleView.center.x < tLoc.x)
        {
            _paddleDynamicItemBehavior.addLinearVelocity(CGPointMake((_PaddleVelocityMultiplier * 2) * 1, 0), forItem: _paddleView);
        }
        
        self._paddleView.center = CGPointMake(tLoc.x, self._paddleView.center.y);
        _dynamicAni.updateItemUsingCurrentState(_paddleView);
    }
    
    func EnvironmentViewDidTouchDidEnd(eView : EnvironmentView, touch : UITouch)
    {
        _paddleDynamicItemBehavior.resistance = _PaddleDefaultResistance;
        _paddleDynamicItemBehavior.addLinearVelocity(CGPointMake(_PaddleVelocityMultiplier, 0), forItem: _paddleView);
    }
    
    /*
    * PaddleView Delegates
    */
    
    func PaddelViewCenterDidChange(pView: PaddelView, center: CGPoint)
    {
        if (!_ballIsMoving)
        {
            CenterBallOnPaddle();
        }
    }
    
    /*
    * BallView Delegates
    */
    
    func BallViewCenterDidChange(bView : BallView, center : CGPoint)
    {
        // higher the speed, higher the gravity
        let speed : CGFloat = SpeedForBall();
        var gravMag : CGFloat;
        
        if (speed < 800)
        {
            gravMag = 1.0;
        }
        else
        {
            gravMag = SpeedForBall() * _ballGravityMultiplier;
        }
        
        _ballGravityBehvaior.magnitude = gravMag;
        
        // test to see if ball feel into the abyss
        if (_ballView.center.y >= self.view.bounds.size.height)
        {
            _usedLives++;
            
            if (_usedLives < _maxLives)
            {
                ResetBall();
            }
        }
    }
    
    /*
    * Convenience Methods
    */

    func CenterBallOnPaddle()
    {
        _ballView.frame.origin = CGPointMake(_paddleView.frame.origin.x + ((_paddleView.frame.size.width - _ballView.frame.size.width) * 0.5), _paddleView.frame.origin.y - _ballView.frame.size.height);
    }
    
    func ResetBall()
    {
        ClearAllBehaviors();
        SetBehaviors();
        SetBoundries();
        
        _ballIsMoving = false;
        
        CenterBallOnPaddle();
        _dynamicAni.updateItemUsingCurrentState(_ballView);
    }
    
    func SpeedForBall() -> CGFloat
    {
        return SpeedForView(_ballDynamicItemBehavior, view: _ballView);
    }
    
    func SpeedForPaddle() -> CGFloat
    {
        return SpeedForView(_paddleDynamicItemBehavior, view: _paddleView);
    }
    
    func SpeedForView(dynamicBehavior : UIDynamicItemBehavior, view : UIView) -> CGFloat
    {
        return CalculateSpeedFromPoint(dynamicBehavior.linearVelocityForItem(view));
    }
    
    func CalculateSpeedFromPoint(p : CGPoint) -> CGFloat
    {
        return CGFloat(sqrtf((powf(Float(p.x), 2) + powf(Float(p.y), 2))));
    }
}

