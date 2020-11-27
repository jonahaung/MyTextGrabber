//
//  TextEditorViewController.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 26/11/20.
//

import UIKit

class TextEditorViewController: UIViewController {
    
    let text: String
    init(_ _text: String) {
        text = _text
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let textView: MyUITextView = {
       
        return $0
    }(MyUITextView())
    
    override func loadView() {
         view = textView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = text
        setup()
    }
}

extension TextEditorViewController {
    
    fileprivate func setupToolbar() {
        let tool1 = UIBarButtonItem(image: UIImage(systemName: "textformat.alt"), style: .plain, target: self, action: nil)
        let tool2 = UIBarButtonItem(image: UIImage(systemName: "lightbulb.fill"), style: .plain, target: self, action: nil)
        toolbarItems = [tool1, UIBarButtonItem.flexible(), tool2]
    }
    
    fileprivate func setupNavBar() {
        navigationController?.view.tintColor = .link
        let dismiss = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didtapDismissButton(_:)))
        navigationItem.rightBarButtonItems = [dismiss]
    }
    private func setup() {
        setupNavBar()
        setupToolbar()
    }
    
    @objc private func didtapDismissButton(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
