//
//  UIKit+Extensions.swift
//  BlogCompanion
//
//  Created by Vadim on 12/30/21.
//

import UIKit

extension UIView {
    func addSubviewWithConstraints(_ view: UIView, insets: UIEdgeInsets = .zero) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.leftAnchor.constraint(equalTo: leftAnchor, constant: insets.left).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor, constant: -insets.right).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom).isActive = true
    }
}
