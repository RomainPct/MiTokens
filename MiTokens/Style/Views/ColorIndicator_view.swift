//
//  ColorIndicator_view.swift
//  MiTokens
//
//  Created by Romain Penchenat on 06/05/2018.
//  Copyright © 2018 Romain Penchenat. All rights reserved.
//

import UIKit

class ColorIndicator_view: UIView {
    
    var isAnimate:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
        layer.maskedCorners = [CACornerMask.layerMinXMaxYCorner,CACornerMask.layerMinXMinYCorner]
    }
    
    func stopChangingStateAnimation(){
        isAnimate = false
    }
    
    func startChangingStateAnimation(){
        isAnimate = true
        changingState()
    }
    
    func changingState(reversed:Bool = false){
        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: UICubicTimingParameters(animationCurve: .easeInOut))
        animator.addAnimations {
            self.alpha = reversed ? 1 : 0
        }
        animator.addCompletion { (_) in
            if self.isAnimate || !reversed {
                self.changingState(reversed: !reversed)
            } else {
                self.isAnimate = false
            }
        }
        animator.startAnimation()
    }
    
}
