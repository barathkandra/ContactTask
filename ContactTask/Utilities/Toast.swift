//
//  Toast.swift
//  ContactTask
//
//  Created by Bharath on 19/04/19.
//  Copyright © 2018 Bharath. All rights reserved.
//

import UIKit
import QuartzCore

extension UINotificationFeedbackGenerator.FeedbackType {
    
    var ToastColor: UIColor {
        let toastColor = UIColor.init(red: 80.0/255.0, green: 227.0/255.0, blue: 194.0/255.0, alpha: 1.0)
        return self == .success ? toastColor : toastColor
    }
    
    var TextColor : UIColor {
        return self == .success ? UIColor.white : UIColor.white
    }
    
}


final class Toast: NSObject {
    
    public var toastView: UIView!
    
    private var window: UIWindow!
    private var toastLabel: UILabel!
    private var timer = Timer()
    private let notificationFeedback = UINotificationFeedbackGenerator()

    private static let sharedInstance = Toast()
    
    class func shared() -> Toast {
        return sharedInstance
    }
    
    func showNoInternetToast(withToastDuration duration: TimeInterval = 3) {
        self.removeExistedToast()
        Toast.sharedInstance.showToast(withDuration: duration, afterDelay: 0, withMessage: "The Internet connection appears to be offline.", toastType: .error, hideToastAfterCompletion: true)
    }
    
    func showToast(withDuration duration: TimeInterval, afterDelay delay: TimeInterval, withMessage message: String, toastType type: UINotificationFeedbackGenerator.FeedbackType, hideToastAfterCompletion: Bool) {
        
        let window = (UIApplication.shared.delegate as! AppDelegate).window
        
        toastView = UIView.init()
        toastView.tag = 999
        toastView.accessibilityHint = "toastView"
        toastView.backgroundColor = UIColor.clear
        toastView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 80)
        toastView.isUserInteractionEnabled = true
        
        let toastLabelWidth = screenWidth*0.75
        let xPosition = (screenWidth - toastLabelWidth)/2
        let size = message.height(withConstrainedWidth: toastLabelWidth, font: UIFont.systemFont(ofSize: 16))
        
        var topPadding: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            topPadding = window?.safeAreaInsets.top ?? 0.0
        }
        topPadding = (topPadding == 0.0 ?  20.0  : topPadding)
        
        toastLabel = UILabel(frame: CGRect(x: xPosition, y: topPadding, width: toastLabelWidth, height: size))
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        toastLabel.textAlignment = .center
        toastLabel.textColor = type.TextColor
        toastLabel.font = UIFont.systemFont(ofSize: 16)
        toastLabel.backgroundColor = UIColor.clear
        toastView.addSubview(toastLabel)
        toastView.frame.size.height = toastLabel.frame.origin.y + size + 32
        self.removeExistedToast()
        self.drawWave(forToastView: toastView, fillColor: type.ToastColor)
        window?.addSubview(toastView)
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(type)
        
        Toast.animateLayer(toastView: toastView)
        
        self.animate(toast: toastView, withDelay: delay, duration: 0.5, transform: CGAffineTransform.identity, {
            if $0 && hideToastAfterCompletion {
                self.timer = Timer.scheduledTimer(withTimeInterval: delay + duration, repeats: false, block: { (_) in
                    self.removeToastOnSwipe()
                })
            }
        })
        self.setupGesture()
    }
    
    private func setupGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture))
        swipeGesture.direction = [.up]
        toastView.addGestureRecognizer(swipeGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleGesture))
        tapGesture.numberOfTapsRequired = 1
        toastView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleGesture() {
        self.removeToastOnSwipe()
        timer.invalidate()
    }
    
    private class func animateLayer(toastView: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear)
        animation.duration = 10
        animation.fromValue = NSValue(cgPoint: CGPoint.zero)
        animation.toValue = NSValue(cgPoint: CGPoint(x: -toastView.frame.size.width, y: 0))
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        toastView.layer.sublayers?.filter({ $0.name == "sineWave" }).forEach({
            $0.add(animation, forKey: "position")
        })
    }
    
    func removeExistedToast(){
        let window = UIApplication.shared.keyWindow
        window?.subviews.filter({ $0.tag == 999 && $0.accessibilityHint == "toastView" }).forEach({ (existedToast) in
            UIView.animate(withDuration: 0.25, animations: {
                existedToast.alpha = 0
            }, completion: { (_) in
                self.timer.invalidate()
                existedToast.removeFromSuperview()
            })
        })
    }
    
    func toastNotExists() -> Bool {
        let window = UIApplication.shared.keyWindow
        let toastViews = window?.subviews.filter({ $0.tag == 999 && $0.accessibilityHint == "toastView" })
        return toastViews?.isEmpty ?? true
    }
    
    @objc private func removeToastOnSwipe(){
        let window = UIApplication.shared.keyWindow
        window?.subviews.filter({ $0.tag == 999 && $0.accessibilityHint == "toastView" }).forEach({ (existedToast) in
            animate(toast: existedToast, withDelay: 0, duration: 0.5, transform: CGAffineTransform(translationX: 0, y: -existedToast.frame.height), { _ in
                existedToast.removeFromSuperview()
            })
        })
    }
    
    private func animate(toast: UIView, withDelay delay: TimeInterval, duration: TimeInterval, transform: CGAffineTransform, _ completion:((Bool) -> Void)?) {
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .allowAnimatedContent, animations: {
            toast.transform = transform
        }, completion: completion)
    }
    
    private func drawWave(forToastView toast: UIView, fillColor: UIColor) {
        
        let bezierPath = UIBezierPath()
        
        let numberOfCurves = 10
        let curveWidth: CGFloat = (toast.frame.width*2)/CGFloat(numberOfCurves)
        let difference: CGFloat = curveWidth/3
        let curveHeight: CGFloat = 6
        let yAxis: CGFloat = toast.frame.height - curveHeight
        
        
        bezierPath.move(to: toast.frame.origin)
        bezierPath.addLine(to: CGPoint(x: toast.frame.origin.x, y: yAxis))
        
        for curve in 1...numberOfCurves {
            
            let multiplier = CGFloat(1 + ((curve - 1 ) * 3))
            
            let xPosition = multiplier * difference
            let yPosition = ((curve%2) == 0) ? yAxis - curveHeight : yAxis + curveHeight
            
            let firstPoint: CGPoint = CGPoint(x: xPosition, y: yPosition)
            let secondPoint: CGPoint = CGPoint(x: xPosition + difference, y: yPosition)
            let endPoint: CGPoint = CGPoint(x: xPosition + difference + difference, y: yAxis)
            
            bezierPath.addCurve(to: endPoint, controlPoint1: firstPoint, controlPoint2: secondPoint)
            
        }
        
        bezierPath.addLine(to: CGPoint(x: toast.frame.width*2, y: 0))
        bezierPath.close()
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.name = "sineWave"
        shapeLayer.fillColor = fillColor.cgColor
        toast.layer.insertSublayer(shapeLayer, at: 0)
        
    }
}

