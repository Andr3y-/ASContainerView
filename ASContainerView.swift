//
//  UIContainerView.swift
//
//  Created by Andr3y on 25/05/2016.
//  Copyright © 2016 Andr3y. All rights reserved.
//

import UIKit
import ObjectiveC

typealias UIContainerView = ASContainerView

class ASContainerView: UIView {

	typealias ViewInstancePlaceholder = NSNull
	private var viewClasses = [AnyClass]()
	private var viewInstances = [AnyObject]()

	// MARK: Public
	// MARK: - Properties

	@IBInspectable
	var automaticallyFitContentToBounds: Bool = true

	@IBInspectable
	var animationDuration: Double = 0.2

	weak var delegate: UIContainerViewDelegate?

	// MARK: - Methods

	func showViewAtIndex(index: Int, animated: Bool) {
		if index < viewInstances.count {
			// Check if View is already loaded, else it is ViewInstancePlaceholder
			if (viewInstances[index] is ViewInstancePlaceholder) {
				// View is not instantiated, load it
				lazyLoadView(atIndex: index)
			}
			animateAppearanceOfViewAtIndex(index, animated: animated)
		} else {
			print("ASContainerView showViewAtIndex out of bounds")
		}
	}

	func setViewClasses(viewClasses: [UIView.Type]) {

		for view in subviews {
			view.removeFromSuperview()
		}
		self.viewClasses = [AnyClass]()
		self.viewInstances = [AnyObject]()

		for obj in viewClasses {
			if class_isMetaClass(object_getClass(obj)) {
				addViewClass(obj)
			}
		}
	}

	func addViewClass(classObject: AnyClass) {

		if !classObject.isSubclassOfClass(UIView.self) {
			NSLog("ASContainerView: Only subclasses of UIView can be added")
			return
		}

		viewClasses.append(classObject.self)
		viewInstances.append(ViewInstancePlaceholder())
	}

	// MARK: - Private
	// MARK: - Methods
	private func lazyLoadView(atIndex index: Int) -> UIView? {
		// Lazily Instantiate

		guard index < viewInstances.count else {
			print("ASContainerView: lazyLoadView (index out of bounds)")
			return nil
		}

		guard viewInstances[index] is ViewInstancePlaceholder else {
			print("ASContainerView: lazyLoadView: view instance is not ViewInstancePlaceholder")
			return nil
		}

		guard let viewClass = viewClasses[index] as? UIView.Type else {
			print("viewClasses\(index) is not of type UIView, returning")
			return nil
		}

		var newView: UIView?

		// 1. Xib instantiation attempt
		let classNameComponents = NSStringFromClass(viewClass.self).componentsSeparatedByString(".")
		if let lastComponent = classNameComponents.last {
			if NSBundle.mainBundle().pathForResource(lastComponent, ofType: "nib") != nil {
				if let subviewArray = NSBundle.mainBundle().loadNibNamed(lastComponent, owner: nil, options: nil) as? [UIView] {
					if let mainView = subviewArray.first {
						newView = mainView
						print("view loaded from a bundle")
					}
				}
			}
		}

		// 2. UIView subclass instantiation attempt
		if newView == nil {
			newView = viewClass.init(frame: CGRectZero)
			print("view loaded with init(frame: CGRectZero)")
		}

		// 3. NSObject/AnyObject subclass instantiation attempt
		if newView == nil {
			newView = viewClass.init()
			print("view loaded with init()")
		}

		guard let view = newView else {
			print("ASContainerView: view failed to load")
			return nil
		}

		view.alpha = 0

		delegate?.containerDidLoad(view, atIndex: index, container: self)

		addSubview(view)

		// Replace ViewInstancePlaceholder instance with newly initialized UIView instance
		viewInstances[index] = view

		if automaticallyFitContentToBounds {
			applyConstraintsToView(view)
		}

		return view

	}

	private func animateAppearanceOfViewAtIndex(index: Int, animated: Bool) {

		var viewShown: UIView?

		let animationBlock = { [unowned self] in
			for (idx, obj) in self.viewInstances.enumerate() {

				if let view = obj as? UIView {
					if idx == index {
						if let viewShownExtended = viewShown as? UIViewExtendedLifeCycle {
							viewShownExtended.viewWillShow()
						}
						self.delegate?.containerWillShow(view, atIndex: index, container: self)
						view.alpha = 1.0
						viewShown = view
					} else {
						view.alpha = 0.0
					}
				}
			}
		}

		let completionBlock = { [unowned self] in
			if let viewShown = viewShown {

				self.delegate?.containerDidShow(self, atIndex: index, container: self)
				if let viewShownExtended = viewShown as? UIViewExtendedLifeCycle {
					viewShownExtended.viewDidShow()
				}
			}
		}

		if animated {
			UIView.animateWithDuration(animationDuration, animations: { () -> Void in
				animationBlock()
				}, completion: { (finished: Bool) -> Void in
				completionBlock()
			})
		} else {
			animationBlock()
			completionBlock()
		}
	}

	private func applyConstraintsToView(view: UIView) {
		if subviews.contains(view) {
			view.translatesAutoresizingMaskIntoConstraints = false

			let views = ["view": view]

			addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: .DirectionLeadingToTrailing, metrics: nil, views: views))
			addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: .DirectionLeadingToTrailing, metrics: nil, views: views))
		}
	}

	deinit {
		print("ASContainerView dealloc")
	}
}