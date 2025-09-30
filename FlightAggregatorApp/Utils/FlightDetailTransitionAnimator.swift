//
//  FlightDetailTransitionAnimator.swift
//  FlightAggregatorApp
//
//  Created by Alexandra Makey on 30.09.25.
//

import UIKit
class FlightDetailTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: TimeInterval = 0.6
    private let isPush: Bool
    //MARK: - Init
    init(isPush: Bool) {
        self.isPush = isPush
        super.init()
    }
    //MARK: - Actions
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPush {
            animatePush(using: transitionContext)
        } else {
            animatePop(using: transitionContext)
        }
    }
    
    private func animatePush(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        
        toView.transform = CGAffineTransform(translationX: containerView.frame.width, y: 0)
            .scaledBy(x: 0.95, y: 0.95)
        toView.alpha = 0.8
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            fromView.transform = CGAffineTransform(translationX: -containerView.frame.width * 0.3, y: 0)
            fromView.alpha = 0.7
            
            toView.transform = .identity
            toView.alpha = 1.0
        } completion: { finished in
            fromView.transform = .identity
            fromView.alpha = 1.0
            transitionContext.completeTransition(finished)
        }
    }
    
    private func animatePop(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.insertSubview(toView, belowSubview: fromView)
        
        toView.transform = CGAffineTransform(translationX: -containerView.frame.width * 0.3, y: 0)
        toView.alpha = 0.7
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            fromView.transform = CGAffineTransform(translationX: containerView.frame.width, y: 0)
                .scaledBy(x: 0.95, y: 0.95)
            fromView.alpha = 0.8
            
            toView.transform = .identity
            toView.alpha = 1.0
        } completion: { finished in
            transitionContext.completeTransition(finished)
        }
    }
}
