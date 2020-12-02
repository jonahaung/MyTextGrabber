//
//  SpinnerViewController.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 26/11/20.
//

import UIKit

final class SpinnerViewController: UIViewController {
    
    private let spinner: UIActivityIndicatorView = {
        $0.color = UIColor.systemYellow
        return $0
    }(UIActivityIndicatorView(style: .medium))

    override func loadView() {
        view = UIView()
//        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
}
private let child = SpinnerViewController()

extension UIViewController {
    func showLoading() {
        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    func hideLoading() {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
