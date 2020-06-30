//
//  Spinner.swift
//  ChatApplication
//
//  Created by Siddhesh jadhav on 29/06/20.
//  Copyright © 2020 infiny. All rights reserved.
//

import Foundation
import UIKit

open class Spinner {
    
    internal static var spinner: UIActivityIndicatorView?
    public static var style: UIActivityIndicatorView.Style = .medium
    public static var baseBackColor = UIColor.black.withAlphaComponent(0.5)
    public static var baseColor = UIColor.blue
    public static var loadingTextLabel = UILabel()
    
    public static func start(style: UIActivityIndicatorView.Style = style, backColor: UIColor = baseBackColor, baseColor: UIColor = baseColor) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: UIDevice.orientationDidChangeNotification, object: nil)
        if spinner == nil, let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            let frame = UIScreen.main.bounds
            spinner = UIActivityIndicatorView(frame: frame)
            spinner!.backgroundColor = backColor
            spinner!.style = style
            spinner?.color = baseColor
            
            loadingTextLabel.textColor = baseColor
            loadingTextLabel.text = "Loading Messages..."
            loadingTextLabel.sizeToFit()
            loadingTextLabel.center = CGPoint(x: spinner!.center.x, y: spinner!.center.y + 30)
            spinner!.addSubview(loadingTextLabel)
            
            window.addSubview(spinner!)
            spinner!.startAnimating()
        }
    }
    
    public static func stop() {
        if spinner != nil {
            spinner!.stopAnimating()
            spinner!.removeFromSuperview()
            spinner = nil
        }
    }
    
    @objc public static func update() {
        if spinner != nil {
            stop()
            start()
        }
    }
}

