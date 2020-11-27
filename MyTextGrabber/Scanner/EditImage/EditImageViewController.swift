//
//  EditImageViewController.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 26/11/20.
//

import UIKit
import AVFoundation
import CoreData

final class EditImageViewController: UIViewController {
    override var prefersStatusBarHidden: Bool { return true }
    init(_ _image: UIImage, _ _quad: Quadrilateral) {
        originalImage = _image
        editedImage = _image
        quad = _quad
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView: UIImageView = {
        $0.clipsToBounds = true
        $0.isOpaque = true
        $0.backgroundColor = .black
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView())
    
    private let quadView: QuadrilateralView = {
        $0.editable = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(QuadrilateralView())
    
    let originalImage: UIImage
    var editedImage: UIImage {
        didSet {
            imageView.image = editedImage
        }
    }
    private var quad: Quadrilateral
    private var zoomGestureController: ZoomGestureController!
    
    private var quadViewWidthConstraint = NSLayoutConstraint()
    private var quadViewHeightConstraint = NSLayoutConstraint()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = originalImage
        setup()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.view.tintColor = .systemOrange
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustQuadViewConstraints()
        displayQuad()
    }
}

extension EditImageViewController {
    
    fileprivate func setupToolbar() {
        let recognize = UIBarButtonItem(image: UIImage(systemName: "text.magnifyingglass"), style: .plain, target: self, action: #selector(didTapRecognizeButton(_:)))
        let tool1 = UIBarButtonItem(image: UIImage(systemName: "memories"), style: .plain, target: self, action: #selector(didTapResetImage(_:)))
        let tool2 = UIBarButtonItem(image: UIImage(systemName: "crop"), style: .plain, target: self, action: #selector(didTapFilterImage(_:)))
        toolbarItems = [tool1, UIBarButtonItem.flexible(), recognize, UIBarButtonItem.flexible(), tool2]
    }
    
    fileprivate func setupNavBar() {
        navigationController?.view.tintColor = .systemYellow
        let dismiss = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didtapDismissButton(_:)))
        navigationItem.rightBarButtonItems = [dismiss]
    }
    
    private func setup() {
        
        setupNavBar()
        setupToolbar()
        
        view.addSubview(imageView)
        view.addSubview(quadView)
       
        setupConstraints()

        zoomGestureController = ZoomGestureController(image: originalImage, quadView: quadView)
        
        let touchDown = UILongPressGestureRecognizer(target: zoomGestureController, action: #selector(zoomGestureController.handle(pan:)))
        touchDown.minimumPressDuration = 0
        view.addGestureRecognizer(touchDown)
    }
    
    private func setupConstraints() {
        let imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ]

        quadViewWidthConstraint = quadView.widthAnchor.constraint(equalToConstant: 0)
        quadViewHeightConstraint = quadView.heightAnchor.constraint(equalToConstant: 0)
        
        let quadViewConstraints = [
            quadView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            quadView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            quadViewWidthConstraint,
            quadViewHeightConstraint
        ]
        NSLayoutConstraint.activate(quadViewConstraints + imageViewConstraints)
    }
    
    private func displayQuad() {
        let imageSize = editedImage.size
        let imageFrame = CGRect(origin: quadView.frame.origin, size: CGSize(width: quadViewWidthConstraint.constant, height: quadViewHeightConstraint.constant))
        
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: imageSize, aspectFillInSize: imageFrame.size)
        let transforms = [scaleTransform]
        let transformedQuad = quad.applyTransforms(transforms)
        
        quadView.drawQuadrilateral(quad: transformedQuad, animated: false)
    }
    
   
    private func adjustQuadViewConstraints() {
        let frame = AVMakeRect(aspectRatio: editedImage.size, insideRect: imageView.bounds)
        quadViewWidthConstraint.constant = frame.size.width
        quadViewHeightConstraint.constant = frame.size.height
    }
    
    @objc private func didTapRecognizeButton(_ sender: UIButton) {
        sender.isEnabled = false
        showLoading()
        MyanmarTextRecognizer.shared.recognize(image: editedImage) { string in
            self.hideLoading()
            sender.isEnabled = true
            guard let text = string else { return }
            let context = PersistenceController.shared.container.viewContext
            let item = Item(context: context)
            item.timestamp = Date()
            item.text = text
            try? context.save()
            
            let x = TextEditorViewController(text)
            self.navigationController?.pushViewController(x, animated: true)
        }
    }
    
    @objc private func didTapFilterImage(_ sender: UIButton) {
        cropImage()
        
    }
    @objc private func didTapResetImage(_ sender: UIButton) {
        editedImage = originalImage
        
    }
    @objc private func didtapDismissButton(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}


extension EditImageViewController {
    @objc func cropImage() {
        guard let quad = quadView.quad,
            let ciImage = CIImage(image: editedImage) else {
                return
        }
        let cgOrientation = CGImagePropertyOrientation(editedImage.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        let scaledQuad = quad.scale(quadView.bounds.size, editedImage.size)
        self.quad = scaledQuad
        
        // Cropped Image
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: editedImage.size.height)
        cartesianScaledQuad.reorganize()
        
        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
            ])
        
        let croppedImage = UIImage.from(ciImage: filteredImage)
        editedImage = croppedImage
        
    }
}
