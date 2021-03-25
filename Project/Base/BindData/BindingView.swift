//
//  BindingView.swift
//  Project
//
//  Created by Be More on 24/03/2021.
//

import UIKit

//UITapGestureRecognizer
//UIPinchGestureRecognizer
//UIRotationGestureRecognizer
//UISwipeGestureRecognizer
//UIPanGestureRecognizer
//UIScreenEdgePanGestureRecognizer
//UILongPressGestureRecognizer
//UIHoverGestureRecognizer

enum GestureRecognizerType {
    case tap
    case pinch
    case rotation
    case swipe
    case pan
    case screenEdgePan
    case longPress
    case hover
}

class BindingView: UIView {
    
    private var completion: (UIView) -> () = { _ in  }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commontInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commontInit()
    }
    
    init(gestureType: GestureRecognizerType) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.isUserInteractionEnabled = true
        switch gestureType {
        case .tap:
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:))))
        case .pinch:
            self.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handleGesture(_:))))
        case .rotation:
            self.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: #selector(handleGesture(_:))))
        case .swipe:
            self.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:))))
        case .pan:
            self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:))))
        case .screenEdgePan:
            self.addGestureRecognizer(UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleGesture(_:))))
        case .longPress:
            self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleGesture(_:))))
        case .hover:
            self.addGestureRecognizer(UIHoverGestureRecognizer(target: self, action: #selector(handleGesture(_:))))
        
        }
        
    }
    
    func bind(callBack: @escaping (UIView) -> ()) {
        self.completion = callBack
    }
    
    private func commontInit() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:))))
    }
    
    @objc private func handleGesture(_ sender: UIView) {
        self.completion(sender)
    }
}
