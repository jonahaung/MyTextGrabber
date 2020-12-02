//
//  ScannerNavigationController.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 26/11/20.
//

import UIKit

class ScannerNavigationController: UINavigationController {
    
    var image: UIImage?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
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
//        navigationBar.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolbar.isTranslucent = true
        toolbar.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        view.tintColor = .white
        view.backgroundColor = .black
        
        setToolbarHidden(false, animated: true)
        
        viewControllers = [CameraViewController()]
    }
}
