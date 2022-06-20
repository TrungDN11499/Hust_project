//
//  UITableViewExtension.swift
//  Triponus
//
//  Created by Be More on 15/06/2022.
//

import UIKit

extension UITableView {

    func registerCell<T: UITableViewCell>(ofType _ : T.Type) {
        register(T.self, forCellReuseIdentifier: String(describing: T.self))
    }

    func registerNib<T: UITableViewCell>(ofType _ : T.Type) {
        let nib = UINib(nibName: String(describing: T.self), bundle: nil)
        register(nib, forCellReuseIdentifier: String(describing: T.self))
    }

    func registerHeaderNib<T: UITableViewHeaderFooterView>(ofType _ : T.Type) {
        let nib = UINib(nibName: String(describing: T.self), bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
    }
    
    func registerFooterNib<T: UITableViewHeaderFooterView>(ofType _ : T.Type) {
        let nib = UINib(nibName: String(describing: T.self), bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
    }
    
    func registerHeaderClass<T: UITableViewHeaderFooterView>(ofType _ : T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
    }

    func dequeueCell<T: UITableViewCell>(ofType _ : T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(String(describing: T.self))")
        }
        return cell
    }

    func dequeueHeaderView<T: UITableViewHeaderFooterView>(ofType: T.Type) -> T {
        guard let headerView = dequeueReusableHeaderFooterView(withIdentifier: String(describing: T.self)) as? T else {
            fatalError("Could not dequeue Header view with identifier: \(String(describing: T.self))")
        }
        return headerView
    }
}

extension UIScrollView {
   func scrollToBottom(animated: Bool) {
     if self.contentSize.height < self.bounds.size.height { return }
     let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
     self.setContentOffset(bottomOffset, animated: animated)
  }
}

extension UITableView {
    func scroll(to: ScrollsTo, animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            switch to {
            case .top:
                if numberOfRows > 0 {
                     let indexPath = IndexPath(row: 0, section: 0)
                     self.scrollToRow(at: indexPath, at: .top, animated: animated)
                }
                
            case .bottom:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
            }
        }
    }

    enum ScrollsTo {
        case top, bottom
    }
}

