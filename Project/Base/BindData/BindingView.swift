//
//  BindingView.swift
//  Project
//
//  Created by Be More on 24/03/2021.
//

import UIKit

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
    
    private var completion: (UIGestureRecognizer) -> () = { _ in  }
    
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
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:))))
        case .pinch:
            self.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:))))
        case .rotation:
            self.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:))))
        case .swipe:
            self.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:))))
        case .pan:
            self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:))))
        case .screenEdgePan:
            self.addGestureRecognizer(UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleScreenEdgePanGesture(_:))))
        case .longPress:
            self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:))))
        case .hover:
            self.addGestureRecognizer(UIHoverGestureRecognizer(target: self, action: #selector(handleHoverGesture(_:))))
        }
        
    }
    
    func bind(callBack: @escaping (UIGestureRecognizer) -> ()) {
        self.completion = callBack
    }
    
    private func commontInit() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:))))
    }
    
    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
        self.completion(sender)
    }
    
    @objc private func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        self.completion(sender)
    }
    
    @objc private func handleRotationGesture(_ sender: UIRotationGestureRecognizer) {
        self.completion(sender)
    }
    
    @objc private func handleSwipeGesture(_ sender: UISwipeGestureRecognizer) {
        self.completion(sender)
    }
    
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        self.completion(sender)
    }
    
    @objc private func handleScreenEdgePanGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        self.completion(sender)
    }
    
    @objc private func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        self.completion(sender)
    }
    
    @objc private func handleHoverGesture(_ sender: UIHoverGestureRecognizer) {
        self.completion(sender)
    }
}
