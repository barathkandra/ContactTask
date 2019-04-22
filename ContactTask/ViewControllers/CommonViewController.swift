//
//  CommonViewController.swift
//  ContactTask
//
//  Created by Bharath on 19/04/19.
//  Copyright © 2019 Bharath. All rights reserved.
//

import UIKit

class CommonViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    // MARK:-  Loading Methods
    
    func stopLoading()  {
        let loadingView = self.view.viewWithTag(999)
        UIView.animate(withDuration: 0.4, delay: 0, options: .transitionFlipFromTop , animations: {
            loadingView?.layer.opacity = 0.01
        }) { (finished) in
            loadingView?.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    func startLoading() {
        
        let loadingView = UIView()
        loadingView.tag = 999
        loadingView.layer.cornerRadius = 10.0
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.40)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(loadingView)
        
        let label = UILabel()
        let activity = UIActivityIndicatorView(style: .whiteLarge)
        activity.startAnimating()
        
        activity.translatesAutoresizingMaskIntoConstraints = false
        loadingView.addSubview(activity)
        label.text = "loading"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        loadingView.addSubview(label)
        
        let visualDict = ["loadingview":loadingView,"label":label,"activity":activity,"mainview":self.view]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[mainview]-(<=0)-[loadingview(100)]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: visualDict as Any as! [String : Any]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[mainview]-(<=0)-[loadingview(100)]", options: NSLayoutConstraint.FormatOptions.alignAllCenterX, metrics: nil, views: visualDict as Any as! [String : Any]))
        loadingView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[loadingview]-(<=0)-[activity]", options:NSLayoutConstraint.FormatOptions.alignAllCenterX, metrics: nil, views: visualDict as Any as! [String : Any]))
        loadingView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[activity]", options:[], metrics: nil, views: visualDict as Any as! [String : Any]))
        loadingView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[activity]-(<=8)-[label]", options:NSLayoutConstraint.FormatOptions.alignAllCenterX, metrics: nil, views: visualDict as Any as! [String : Any]))
        self.view.isUserInteractionEnabled = false
        
    }
    
}

