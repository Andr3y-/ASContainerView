//
//  UIViewExtendedLifecycle.swift
//
//  Created by Andr3y on 25/05/2016.
//  Copyright © 2016 Andr3y. All rights reserved.
//

import UIKit

protocol UIViewExtendedLifeCycle {
	func viewWillShow()
	func viewDidShow()
}

extension UIViewExtendedLifeCycle {
	// Optional
	func viewDidShow() {

	}
	// Optional
	func viewWillShow() {

	}
}