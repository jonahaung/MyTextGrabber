//
//  ScannerNavigationController.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 26/11/20.
//

import UIKit

class ScannerNavigationController: UINavigationController {
    
    
    
    var image: UIImage?
    init(_ _image: UIImage?) {
        image = _image
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolbar.isTranslucent = true
        
        view.tintColor = .systemOrange
        
        if let image = image {
            viewControllers = [EditImageViewController(image, Quadrilateral(rect: CGRect(origin: .zero, size: image.size)))]
        }else {
            viewControllers = [CameraViewController()]
        }
        setToolbarHidden(false, animated: true)
    }
}
