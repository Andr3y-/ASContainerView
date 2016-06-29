//
//  UIContainerViewDelegate.swift
//
//  Created by Andr3y on 25/05/2016.
//  Copyright © 2016 Andr3y. All rights reserved.
//

import UIKit
typealias UIContainerViewDelegate = ASContainerViewDelegate

protocol ASContainerViewDelegate: class {
	func containerDidLoad(view: UIView, atIndex index: Int, container: ASContainerView)
	func containerWillShow(view: UIView, atIndex index: Int, container: ASContainerView)
	func containerDidShow(view: UIView, atIndex index: Int, container: ASContainerView)
}
