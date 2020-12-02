//
//  EditImageViewController.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 26/11/20.
//

import UIKit
import AVFoundation
import Vision

final class EditImageViewController: UIViewController {
    
    enum OperationState {
        case ready, editingImage, croppingImage
    }
    private var operaionState = OperationState.ready {
        didSet {
            updateToolbarItems()
            updateOperationState()
        }
    }
    
    let result: ImageScannerResult
    private let manager = EditImageManager()
    override var prefersStatusBarHidden: Bool {
        return true
    }
    init(_result: ImageScannerResult) {
        result = _result
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView: UIImageView = {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
        return $0
    }(UIImageView())
    
    override func loadView() {
        view = imageView
    }
    
    private let quadView: QuadrilateralView = {
        $0.editable = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(QuadrilateralView())
    
    private var zoomGestureController: ZoomGestureController!
    
    private var quadViewWidthConstraint = NSLayoutConstraint()
    private var quadViewHeightConstraint = NSLayoutConstraint()
    private let textRecognizer = MyanmarTextRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = result.editedImage
        setup()
        manager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager.detectTextBoxes()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustQuadViewConstraints()
        updateTransform()
    }
    
    private func updateTransform() {
        let videoRect = AVMakeRect(aspectRatio: result.editedImage.size, insideRect: imageView.bounds)
        let visible = videoRect.intersection(imageView.frame)
        let scaleT = CGAffineTransform(scaleX: visible.width, y: -visible.height)
        let translateT = CGAffineTransform(translationX: visible.minX, y: visible.maxY)
        CurrentSession.cameraTransform = scaleT.concatenating(translateT)
    }
    
    deinit {
        print("EditImageViewController")
    }
}

extension EditImageViewController: EditImageManagerDelegate {
    func editImageManager(_ manager: EditImageManager, showLoading isLoading: Bool) {
        isLoading ? showLoading() : hideLoading()
    }
    
    func editImageManager(didFinishEditingImage manager: EditImageManager) {
        imageView.image = result.editedImage
        updateTransform()
        manager.cleanUpScreen()
        manager.detectTextBoxes()
    }
    
    func editImageManager(_ manager: EditImageManager, didFinishDetecting textRects: [TextRect]) {
        let layer = imageView.layer
        textRects.forEach {
            $0.addShapeLayer(to: layer)
        }
    }
    
    func editImageManager(_ manager: EditImageManager, didFinishDisplayingLines textRects: [TextRect]) {
        if manager.currentTextRects.last?.recognizedText != nil {
            let text = manager.currentTextRects.map{$0.recognizedText}.compactMap{$0}.joined(separator: " ")
            let x = TextEditorViewController(text)
            navigationController?.pushViewController(x, animated: true)
        }
    }
}

extension EditImageViewController {
    
    private func updateOperationState() {
        switch operaionState {
        case .ready:
            quadView.editable = false
            quadView.drawQuadrilateral(quad: nil, animated: false)
        case .editingImage:
            quadView.editable = false
            quadView.drawQuadrilateral(quad: nil, animated: false)
            
        case .croppingImage:
            quadView.editable = true
            quadView.drawQuadrilateral(quad: manager.getQuad(for: imageView.bounds.size), animated: true)
        }
    }
    
    private func updateToolbarItems() {
        let flexible = UIBarButtonItem.flexible()
        
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelButtonItem(_:)))
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButtonItem(_:)))
        
        switch operaionState {
        case .ready:
            let findTexts = UIBarButtonItem(image: UIImage(systemName: "rectangle.and.text.magnifyingglass"), style: .plain, target: self, action: #selector(didTapDisplayLines(_:)))
            let finish = UIBarButtonItem(title: "Get Texts", style: .plain, target: self, action: #selector(didTapFinish(_:)))
            let editImage = UIBarButtonItem(title: "Edit Image", style: .plain, target: self, action: #selector(didTapEditButtonItem(_:)))
            setToolbarItems([editImage, flexible, findTexts, flexible, finish], animated: true)
        case .editingImage:
            let reset = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(didTapResetButtonItem(_:)))
            let crop = UIBarButtonItem(image: UIImage(systemName: "crop"), style: .plain, target: self, action: #selector(didTapCropButtonItem(_:)))
            let paint = UIBarButtonItem(image: UIImage(systemName: "paintpalette"), style: .plain, target: self, action: #selector(didTapPaintButtonItem(_:)))
            setToolbarItems([reset, flexible, paint, crop, flexible, done], animated: true)
        case .croppingImage:
            setToolbarItems([cancel, UIBarButtonItem.flexible(), done], animated: true)
        }
    }
    
    @objc private func didTapEditButtonItem(_ sender: UIBarButtonItem?) {
        operaionState = .editingImage
    }
    
    @objc private func didTapCropButtonItem(_ sender: UIBarButtonItem?) {
        operaionState = .croppingImage
    }
    @objc private func didTapResetButtonItem(_ sender: UIBarButtonItem?) {
        operaionState = .croppingImage
    }
    @objc private func didTapPaintButtonItem(_ sender: UIBarButtonItem?) {
        operaionState = .croppingImage
    }
    @objc private func didTapCancelButtonItem(_ sender: UIBarButtonItem?) {
        switch operaionState {
        case .croppingImage:
            operaionState = .editingImage
        case .editingImage:
            operaionState = .ready
        default:
            break
        }
    }
    
    @objc private func didTapDoneButtonItem(_ sender: UIBarButtonItem?) {
        
        switch operaionState {
        case .croppingImage:
           
            manager.cropToQuad(for: quadView)
            operaionState = .ready
        case .editingImage:
            operaionState = .ready
        default:
            break
        }
    }
    
    @objc private func didTapFinish(_ sender: UIBarButtonItem?) {
        if manager.currentTextRects.last?.recognizedText != nil {
            let text = manager.currentTextRects.map{$0.recognizedText}.compactMap{$0}.joined(separator: " ")
            let x = TextEditorViewController(text)
            navigationController?.pushViewController(x, animated: true)
        } else {
            sender?.isEnabled.toggle()
            showLoading()
            textRecognizer.recognize(image: result.editedImage) { string in
                self.hideLoading()
                sender?.isEnabled = true
                guard var text = string else { return }
                text = WordSegmentationManager.shared.tag(text).map{$0.tag}.joined(separator: " ")
                let x = TextEditorViewController(text)
                self.navigationController?.pushViewController(x, animated: true)
            }
        }
    }
    
    @objc private func didTapDisplayLines(_ sender: UIBarButtonItem?) {
        let layer = imageView.layer
        manager.currentTextRects.forEach {
            $0.addTextLayer(to: layer)
        }
        manager.displayLines(sender)
    }
    
    
    @objc private func didtapDismissButton(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

extension EditImageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return quadView.editable
    }
}

// setup
extension EditImageViewController {
    
    private func setupNavBar() {
        
        let dismiss = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didtapDismissButton(_:)))
        navigationItem.rightBarButtonItems = [dismiss]
    }
    
    private func setup() {
        view.backgroundColor = .black
        setupNavBar()
        updateToolbarItems()
        
        view.addSubview(quadView)
        
        setupConstraints()
        
        zoomGestureController = ZoomGestureController(imageView: imageView, quadView: quadView)
        let touchDown = UILongPressGestureRecognizer(target: zoomGestureController, action: #selector(zoomGestureController.handle(pan:)))
        touchDown.minimumPressDuration = 0
        imageView.addGestureRecognizer(touchDown)
        touchDown.delegate = self
    }
    
    private func setupConstraints() {
        quadViewWidthConstraint = quadView.widthAnchor.constraint(equalToConstant: 0)
        quadViewHeightConstraint = quadView.heightAnchor.constraint(equalToConstant: 0)
        
        let quadViewConstraints = [
            quadView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            quadView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            quadViewWidthConstraint,
            quadViewHeightConstraint
        ]
        NSLayoutConstraint.activate(quadViewConstraints)
    }
    
    private func adjustQuadViewConstraints() {
        let frame = AVMakeRect(aspectRatio: result.editedImage.size, insideRect: imageView.bounds)
        quadViewWidthConstraint.constant = frame.size.width
        quadViewHeightConstraint.constant = frame.size.height
    }
}
