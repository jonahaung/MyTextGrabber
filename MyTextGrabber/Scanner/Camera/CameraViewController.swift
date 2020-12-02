//
//  CameraViewController.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 26/11/20.
//

import UIKit
protocol CustomCameraViewControllerDelegate: class {
    func customCameraViewController(_ contoller: CameraViewController, didCaptureImage image: UIImage)
}
class CameraViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool { return true }
    let cameraManager = Cameramanager()
    let cameraView = CameraUIView()
    weak var delegate: CustomCameraViewControllerDelegate?
    
    override func loadView() {
        view = cameraView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        cameraManager.cameraView = cameraView
        cameraManager.delegate = self
        cameraManager.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraManager.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.viewWillDisappear()
    }
}

extension CameraViewController: CameraManagerDelegate {
    
    func cameraManage(_ manager: Cameramanager, didCaptureImage image: UIImage) {
        delegate?.customCameraViewController(self, didCaptureImage: image)
        let result = ImageScannerResult()
        result.originalImage = image
        result.editedImage = image
        let x = EditImageViewController(_result: result)
        navigationController?.pushViewController(x, animated: true)
        
    }
}

extension CameraViewController {
    fileprivate func setupToolbar() {
        let language = UIBarButtonItem(title: userDefaults.isMyanmar ? "Myanamr" : "English", style: .plain, target: self, action: #selector(didtapLanguageButton(_:)))
        let tool1 = UIBarButtonItem(image: UIImage(systemName: "textformat.alt"), style: .plain, target: self, action: nil)
        let tool2 = UIBarButtonItem(image: UIImage(systemName: "lightbulb.fill"), style: .plain, target: self, action: nil)
        toolbarItems = [language, UIBarButtonItem.flexible(), tool1, tool2]
    }
    
    fileprivate func setupNavBar() {
        let dismiss = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didtapDismissButton(_:)))
        navigationItem.rightBarButtonItems = [dismiss]
    }
    
    private func setup() {
        setupNavBar()
        
        setupToolbar()
        
        let captureButton: UIButton = {
            $0.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .thin), forImageIn: .normal)
            $0.addTarget(self, action: #selector(didTapCaptureButton(_:)), for: .touchUpInside)
            return $0
        }(UIButton())
        
        view.addSubview(captureButton)
        NSLayoutConstraint.activate([
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            captureButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ])
    }
    
    
    @objc private func didtapLanguageButton(_ sender: UIBarButtonItem) {
       userDefaults.isMyanmar.toggle()
        let title = userDefaults.isMyanmar ? "Myanmar" : "English"
        sender.title = title
    }
    
    @objc private func didtapDismissButton(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    @objc private func didTapCaptureButton(_ sender: UIButton) {
        cameraManager.capture()
    }
}
