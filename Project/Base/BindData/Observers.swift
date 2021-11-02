//
//  Observers.swift
//  Project
//
//  Created by Be More on 10/11/20.
//

import Foundation

class Observable1<T> {
    
    typealias Observer = (_ observable: Observable1<T>, T) -> ()
    
    var observers: [Observer]
    
    public var value: T? {
        didSet {
            if let value = value {
                notifyObservers(value)
            }
        }
    }
    
    func excecute() {
        if !self.observers.isEmpty {
            self.observers.forEach { [unowned self](observer) in
                observer(self, EXECUTE_SIGNAL as! T)
            }
        }
    }
    
    init(_ value: T? = nil) {
        self.value = value
        observers = []
    }
    
    func bind(observer: @escaping Observer) {
        self.observers.append(observer)
    }
    
    func notifyObservers(_ value: T) {
        self.observers.forEach { [unowned self] (observer) in
            observer(self, value)
        }
    }
    
}
