# ASContainerView

### What is this for:
Optimize loading time for heavy multi-layer views. 

For instance, GMSMapView takes 1.5 seconds loading time on iPhone 6.
Use resources wisely and only load views that are actually requested by the user.

## Features:
- Easy setup
- Lazy views instantiation
- Support for all UIView-compatible instantiation methods
- XIB instantiation

### Easy Setup
Full setup in three lines, literally:
```Swift
let containerView = ASContainerView(frame: view.bounds)
view.addSubview(containerView)
  
containerView.delegate = self
containerView.setViewClasses([ProfileView.self, PhotoFeedView.self, GoogleMapsView.self])
containerView.showViewAtIndex(1, animated: false)
```

### Lazy content instantiation
To show view, simply call:
```Swift
containerView.showViewAtIndex(0, animated: true)
```
ASContainerView will load the view, if it has not been shown before, or show an already loaded instance

### Support for all UIView-compatible instantiation methods
ASContainerView will try and search for a XIB first, if successful, loading will be done from a XIB:
```Swift
init?(coder aDecoder: NSCoder)
```

If not found, it will attempt to instantiate with:
```Swift
init(frame: CGRect)
```
If all above fails, instantiation will be made with standard:
```Swift
init()
```

### XIB instantiation
If UI is defined in a XIB, rather than code, ASContainerView will load it from your XIB. 

Note: XIB name must be the same as of the view's class

### ASContainerViewDelegate
Get callbacks whenever container is loading/showing content in your view controller, for example:

```Swift
func containerDidLoad(view: UIView, atIndex index: Int, container: ASContainerView) {
    if let googleMapsView = view as? GMSMapView {
        print("Google maps view lazily loaded")
        googleMapsView.setMinZoom(minZoom: 4.0, maxZoom: 2.0)
    }
}

func containerWillShow(view: UIView, atIndex index: Int, container: ASContainerView) {
    if let googleMapsView = view as? GMSMapView {
        print("Google maps view will be shown")
        googleMapsView.moveCamera(viewModel.cameraPosition)
    }
}

func containerDidShow(view: UIView, atIndex index: Int, container: ASContainerView) {
    if let googleMapsView = view as? GMSMapView {
        print("Google maps view was shown")
        googleMapsView.animateToLocation(viewModel.currentLocation)
    }
}
```

### UIViewExtendedLifeCycle

Alternatively, get callbacks in view classes for additional setup inside:

```Swift
extension GMSMapView: UIViewExtendedLifeCycle {
    func viewWillShow() {
        print("GoogleMapsView will be shown")
        //  Update marker position to last known location
    }

    func viewDidShow() {
        print("GoogleMapsView was just shown")
        //  Start animating updated marker position to current location
    }
}
```

## License

MIT
