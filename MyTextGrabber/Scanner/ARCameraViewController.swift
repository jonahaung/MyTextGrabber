//
//  ARCameraViewController.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 27/11/20.
//

import UIKit
import ARKit

class AText {
    let text: String
    let node: SCNNode
    var hidden: Bool {
        get{
            return node.opacity != 1
        }
    }
    var timestamp: TimeInterval {
        didSet {
            updated = Date()
        }
    }
    private(set) var updated = Date()
    
    init(text: String, node: SCNNode, timestamp: TimeInterval) {
        self.text = text
        self.node = node
        self.timestamp = timestamp
    }
}

extension Date {
    func isAfter(seconds: Double) -> Bool {
        let elapsed = Date.init().timeIntervalSince(self)
        
        if elapsed > seconds {
            return true
        }
        return false
    }
}



class ARCameraViewController: UIViewController {
    
    let sceneView: ARSCNView = {
        $0.showsStatistics = true
        $0.autoenablesDefaultLighting = true
        return $0
    }(ARSCNView(frame: UIScreen.main.bounds))
    
    let dispatchQueueML = DispatchQueue(label: "com.jonahaung.mytextgrabber")
 
    var aTexts = [AText]()
    override func loadView() {
        view = sceneView
    }

    var bounds: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        let scene = SCNScene()
        sceneView.scene = scene
        
        loopCoreMLUpdate()
        bounds = sceneView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Enable plane detection
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        loopCoreMLUpdate()
    }
}

extension ARCameraViewController {
    
    private func loopCoreMLUpdate() {
        dispatchQueueML.async {
            // 1. Run Update.
            self.updateCoreML()
            
            // 2. Loop this function.
//            self.loopCoreMLUpdate()
        }
        
    }
    
    private func updateCoreML() {
        guard let frame = sceneView.session.currentFrame else { return }
        let pixbuff = frame.capturedImage
        detect(pixbuff, frame)
    }
    
    func detect(_ buffer: CVPixelBuffer, _ frame: ARFrame) {
        let request = VNRecognizeTextRequest { (x, error) in
            
            guard let results = x.results as? [VNRecognizedTextObservation] else { return }
            let textRects = results.map{TextRect.init(observation: $0)}.compactMap{$0}
            let normalizedRect = textRects.map{$0.boundingBox}.reduce(CGRect.null, {$0.union($1)})
            let text = "Aung"
            let boundingBox = self.transformBoundingBox(normalizedRect)
            
            guard let position = self.normalizeWorldCoord(boundingBox) else {
                print("No feature point found")
                return
            }
            
            let extistings = self.aTexts
                .filter{ $0.text == text  && $0.timestamp != frame.timestamp}
                .sorted{ $0.node.position.distance(toVector: position) < $1.node.position.distance(toVector: position) }
            
            guard let existing = extistings.last else {
                let node = SCNNode.init(withText: text, position: position)
                self.dispatchQueueML.async {
                    DispatchQueue.main.async {
                        self.sceneView.scene.rootNode.addChildNode(node)
                        node.show()
                    }
                }
                
                let aText = AText(text: text, node: node, timestamp: frame.timestamp)
                self.aTexts.append(aText)
                return
            }
            self.dispatchQueueML.async {
                DispatchQueue.main.async {
                    if let displayFace = extistings.filter({ !$0.hidden }).first  {
                        
                        let distance = displayFace.node.position.distance(toVector: position)
                        if(distance >= 0.03 ) {
                            displayFace.node.move(position)
                        }
                        displayFace.timestamp = frame.timestamp
                        
                    } else {
                        existing.node.position = position
                        existing.node.show()
                        existing.timestamp = frame.timestamp
                    }
                }
            }
            
        }
        request.recognitionLevel = .fast
        
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up)
        
        try? handler.perform([request])
    }
    
    private func normalizeWorldCoord(_ boundingBox: CGRect) -> SCNVector3? {
        
        var array: [SCNVector3] = []
        Array(0...2).forEach{_ in
            if let position = determineWorldCoord(boundingBox) {
                array.append(position)
            }
            usleep(12000) // .012 seconds
        }

        if array.isEmpty {
            return nil
        }
        
        return SCNVector3.center(array)
    }
    
    
    /// Determine the vector from the position on the screen.
    ///
    /// - Parameter boundingBox: Rect of the face on the screen
    /// - Returns: the vector in the sceneView
    private func determineWorldCoord(_ boundingBox: CGRect) -> SCNVector3? {
        let arHitTestResults = sceneView.hitTest(CGPoint(x: boundingBox.midX, y: boundingBox.midY), types: [.featurePoint])
        
        // Filter results that are to close
        if let closestResult = arHitTestResults.filter({ $0.distance > 0.10 }).first {
//            print("vector distance: \(closestResult.distance)")
            return SCNVector3.positionFromTransform(closestResult.worldTransform)
        }
        return nil
    }
    
    
    /// Transform bounding box according to device orientation
    ///
    /// - Parameter boundingBox: of the face
    /// - Returns: transformed bounding box
    private func transformBoundingBox(_ boundingBox: CGRect) -> CGRect {
        var size: CGSize
        var origin: CGPoint
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            size = CGSize(width: boundingBox.width * bounds.height,
                          height: boundingBox.height * bounds.width)
        default:
            size = CGSize(width: boundingBox.width * bounds.width,
                          height: boundingBox.height * bounds.height)
        }
        
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            origin = CGPoint(x: boundingBox.minY * bounds.width,
                             y: boundingBox.minX * bounds.height)
        case .landscapeRight:
            origin = CGPoint(x: (1 - boundingBox.maxY) * bounds.width,
                             y: (1 - boundingBox.maxX) * bounds.height)
        case .portraitUpsideDown:
            origin = CGPoint(x: (1 - boundingBox.maxX) * bounds.width,
                             y: boundingBox.minY * bounds.height)
        default:
            origin = CGPoint(x: boundingBox.minX * bounds.width,
                             y: (1 - boundingBox.maxY) * bounds.height)
        }
        
        return CGRect(origin: origin, size: size)
    }
}

extension ARCameraViewController: ARSCNViewDelegate {
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
    }
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            // Do any desired updates to SceneKit here.
        }
    }
    
}
extension UIFont {
    // Based on: https://stackoverflow.com/questions/4713236/how-do-i-set-bold-and-italic-on-uilabel-of-iphone-ipad
    func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
}
