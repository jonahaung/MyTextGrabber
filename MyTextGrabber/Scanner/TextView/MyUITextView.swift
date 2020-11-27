//
//  NotePadTextView.swift
//  BalarSarYwat
//
//  Created by Aung Ko Min on 2/11/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

class MyUITextView: UITextView {
    
    private var placeHolderAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.placeholderText]
    private var suggestedTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.tertiaryLabel]
    
    var suggestedText: String? {
        didSet {
            if oldValue != suggestedText {
                setNeedsDisplay()
            }
        }
    }
    
    private var suggestedRect = CGRect.zero
    private let oprationQueue: OperationQueue = {
        $0.qualityOfService = .background
        $0.maxConcurrentOperationCount = 1
        return $0
    }(OperationQueue())
    
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MyUITextView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let suggestedText = self.suggestedText {
            let caretRect = self.caretRect(for: self.endOfDocument)
            
            let size = CGSize(width: rect.width - caretRect.maxX, height: 50)
            let diff = (caretRect.height - self.font!.lineHeight) / 2
            
            let origin = CGPoint(x: caretRect.maxX, y: caretRect.minY + diff)
            suggestedRect = CGRect(origin: origin, size: size)
        
            suggestedText.draw(in: suggestedRect, withAttributes: suggestedTextAttributes)
        }
    }
}

extension MyUITextView {

    private func setup() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        showsHorizontalScrollIndicator = false
        keyboardDismissMode = .interactive
        textContainer.lineFragmentPadding += 10
    
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineHeightMultiple = 1.1
        font = UIFont.preferredFont(forTextStyle: .body)
        var attr = typingAttributes
        attr[.paragraphStyle] = paragraphStyle
        attr[.font] = font
        typingAttributes = attr
        
        dataDetectorTypes = []
        
        suggestedTextAttributes[.paragraphStyle] = {
            $0.lineBreakMode = .byClipping
            return $0
        }(NSMutableParagraphStyle())
        suggestedTextAttributes[.font] = font
        delegate = self
        
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        rightGesture.direction = .right
        addGestureRecognizer(rightGesture)
        
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        leftGesture.direction = .left
        addGestureRecognizer(leftGesture)
    }
}

extension MyUITextView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        suggestedText = nil
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let subString = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if text == " " {
            findNextWord(text: subString)
        }else {
            findCompletions(text: subString)
        }
        
        return true
    }
    
    private func findCompletions(text: String) {
        
        oprationQueue.cancelAllOperations()
        oprationQueue.addOperation {[weak self] in
            guard let `self` = self else { return }
            
            let lastWord = text.lastWord.trimmed
            
            var suggestingText: String?
            
            suggestingText = markov.completion(for: lastWord)
            OperationQueue.main.addOperation {
                self.suggestedText = suggestingText
            }
        }
    }
    private func findNextWord(text: String) {
        
        oprationQueue.cancelAllOperations()
        oprationQueue.addOperation {[weak self] in
            guard let `self` = self else { return }
            
            let lastWord = text.lastWord.trimmed
            
            var suggestingText: String?
            
            suggestingText = markov.pridict(text: lastWord)
            OperationQueue.main.addOperation {
                self.suggestedText = suggestingText
            }
        }
    }
 
}
extension MyUITextView: UIGestureRecognizerDelegate {
    @objc private func swipeRight(_ gesture: UISwipeGestureRecognizer) {
        gesture.delaysTouchesBegan = true
        if !text.isEmpty {
            
            if let suggestion = suggestedText {
                suggestedText = nil
                insertText(suggestion+" ")
                
                gesture.delaysTouchesEnded = true
                
            } else {
                if text.hasSuffix(" ") {
                    deleteBackward()
                    gesture.delaysTouchesEnded = true
                    return
                }
                (1...text.lastWord.utf16.count).forEach { _ in
                    deleteBackward()
                }
                gesture.delaysTouchesEnded = true
            }
            ensureCaretToTheEnd()
            
            findNextWord(text: text)
        }
    }
    @objc private func swipeLeft(_ gesture: UISwipeGestureRecognizer) {
//        (1...text.lastWord.utf16.count).forEach { _ in
//            deleteBackward()
//        }
        findNextWord(text: text)
        
    }
}
