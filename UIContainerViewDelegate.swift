//
//  UIContainerViewDelegate.swift
//  NHS
//
//  Created by Andr3y on 25/05/2016.
//  Copyright © 2016 Andr3y. All rights reserved.
//

import UIKit

protocol UIContainerViewDelegate: class {
    func containerDidLoad(view: UIView, atIndex index: Int, container: UIContainerView)
    func containerWillShow(view: UIView, atIndex index: Int, container: UIContainerView)
    func containerDidShow(view: UIView, atIndex index: Int, container: UIContainerView)
}
