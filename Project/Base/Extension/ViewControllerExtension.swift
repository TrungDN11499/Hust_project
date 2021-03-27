//
//  ViewControllerExtension.swift
//  Project
//
//  Created by Be More on 10/3/20.
//

import UIKit

extension UIViewController {
    
    /// Add accessory to text field
    ///
    /// - Parameters:
    ///   - textFields: add  to text field
    ///   - dismissable: can be dissmisssed
    ///   - previousNextable: can move to other text field
    func addInputAccessoryForTextFields(textFields: [UITextField], dismissable: Bool = true, previousNextable: Bool = false) {
        for (index, textField) in textFields.enumerated() {
            let toolbar: UIToolbar = UIToolbar()
            toolbar.sizeToFit()
            
            var items = [UIBarButtonItem]()
            if previousNextable {
                let previousButton = UIBarButtonItem(image: UIImage(named: "Backward_Arrow"), style: .plain, target: nil, action: nil)
                previousButton.width = 30
                if textField == textFields.first {
                    previousButton.isEnabled = false
                } else {
                    previousButton.target = textFields[index - 1]
                    previousButton.action = #selector(UITextField.becomeFirstResponder)
                }
                
                let nextButton = UIBarButtonItem(image: UIImage(named: "Forward_Arrow"), style: .plain, target: nil, action: nil)
                nextButton.width = 30
                if textField == textFields.last {
                    nextButton.isEnabled = false
                } else {
                    nextButton.target = textFields[index + 1]
                    nextButton.action = #selector(UITextField.becomeFirstResponder)
                }
                items.append(contentsOf: [previousButton, nextButton])
            }
            
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing))
            items.append(contentsOf: [spacer, doneButton])
            
            
            toolbar.setItems(items, animated: false)
            textField.inputAccessoryView = toolbar
        }
    }
    
    /// present alert with one button
    /// - Parameters:
    ///   - error: errort to present
    /// - Returns: Voic
    func presentError(_ error: Error) {
        let alertController = UIAlertController(title: "Error",
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)
        alertController.addAction(.init(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
    
    /// present message with one button
    /// - Parameters:
    ///   - message: message to present
    /// - Returns: Void
    func presentMessage(_ message: String) {
        let alertController = UIAlertController(title: "Message",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(.init(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
    
    /// present message with two buttons
    /// - Parameters:
    ///   - message: message to present
    /// - Returns: Void
    func presentMessage(_ message: String, handler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: "Message",
                                                message: message,
                                                preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .default, handler: handler)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Change root view controller
    /// - Parameters:
    ///   - rootViewController: change to view controller
    ///   - options: animation option, default is curveLinear
    ///   - duration: animation duration, default is 0
    /// - Returns: Void
    func changeRootViewControllerTo(rootViewController: UIViewController, withOption options: UIView.AnimationOptions = .curveLinear, duration: TimeInterval = 0) {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate
        else {
            return
        }
    
        sceneDelegate.window?.rootViewController = rootViewController
        
        UIView.transition(with: sceneDelegate.window!,
                          duration: duration,
                          options: options,
                          animations: {},
                          completion:{ completed in })
    }
}
