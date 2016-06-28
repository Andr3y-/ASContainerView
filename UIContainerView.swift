//
//  UIContainerView.swift
//  NHS
//
//  Created by Andr3y on 25/05/2016.
//  Copyright © 2016 Andr3y. All rights reserved.
//

import UIKit
import ObjectiveC

class UIContainerView: UIView {

	weak var delegate: UIContainerViewDelegate?
	var capacity: Int = 1 {
		didSet {
			for view in subviews {
				view.removeFromSuperview()
			}
			self.viewClasses.removeAll()
			self.viewClasses = [AnyClass]()
			self.viewInstances.removeAll()
			self.viewInstances = [AnyObject]()
		}
	}

	private var viewClasses = [AnyClass]()
	private var viewInstances = [AnyObject]()

	func showViewAtIndex(index: Int, animated: Bool) {
		if index < self.viewInstances.count {
			if (self.viewInstances[index] is NSNull) {
				// Lazily Instantiate
				guard let viewClass = self.viewClasses[index] as? UIView.Type else {
					print("viewClasses\(index) is not of type UIView, returning")
					return
				}

				var newView: UIView?
				// Xib instantiation attempt

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

				// UIView subclass instantiation attempt
				if newView == nil {
					newView = viewClass.init(frame: CGRectZero)
					print("view loaded with init(frame: CGRectZero)")
				}
				// NSObject subclass instantiation attempt
				if newView == nil {
					newView = viewClass.init()
					print("view loaded with init()")

				}

				if let newView = newView {
					newView.alpha = 0

					delegate?.containerDidLoad(newView, atIndex: index, container: self)

					addSubview(newView)

					self.viewInstances[index] = newView
					self.applyConstraintsToView(newView)
					self.animateAppearanceOfViewAtIndex(index, withDuration: animated ? 0.2 : 0.0)
				} else {
					print("view failed to load completely")
				}
			}
			else {
				// View is instantiated, show it
				self.animateAppearanceOfViewAtIndex(index, withDuration: animated ? 0.2 : 0.0)
			}
		}
	}

	private func animateAppearanceOfViewAtIndex(index: Int, withDuration duration: Double) {

		var viewShown: UIView?

		UIView.animateWithDuration(duration, animations: { () -> Void in
			for (idx, obj) in self.viewInstances.enumerate() {
				if idx == index {
					if let view = obj as? UIView {
						self.delegate?.containerWillShow(view, atIndex: index, container: self)
						view.alpha = 1.0
						viewShown = view
					}
				} else if let view = obj as? UIView {
					view.alpha = 0.0
				}
			}
			}, completion: { (finished: Bool) -> Void in
			if let viewShown = viewShown {

				self.delegate?.containerDidShow(self, atIndex: index, container: self)
				if let viewShownExtended = viewShown as? UIViewExtendedLifeCycle {
					viewShownExtended.viewDidShow()
				}
			}
		})
	}

	private func applyConstraintsToView(view: UIView) {
		if self.subviews.contains(view) {
			view.translatesAutoresizingMaskIntoConstraints = false
        
            let views = ["view": view]

			self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: views))
			self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: views))
		}
	}

	func addViewClasses(viewClasses: [UIView.Type]) {
		for obj in viewClasses {
			if class_isMetaClass(object_getClass(obj)) {
				self.addViewClass(obj)
			}
		}
	}

	func addViewClass(classObject: AnyClass) {

		if self.viewClasses.count >= self.capacity {
			NSLog("UIContainerView: Cannot add more view classes (capacity is max)")
			return
		}

		if !classObject.isSubclassOfClass(UIView.self) {
			NSLog("UIContainerView: Only subclasses of UIView can be added")
			return
		}

		self.viewClasses.append(classObject.self)
		self.viewInstances.append(NSNull())
	}

	deinit {
		NSLog("UIContainerView dealloc")
	}
}