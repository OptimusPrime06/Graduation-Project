//
//  FaceOverlayView.swift
//  GP
//
//  Created by Abdelrahman Kafsher on 25/04/2025.
//

import UIKit

class FaceOverlayView: UIView {
    
    private let scanLine = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        isUserInteractionEnabled = false
        addMaskLayer()
        setupScanLine()
        animateScanLine()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addMaskLayer() {
        let path = UIBezierPath(rect: bounds)
        let radius: CGFloat = 150
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        path.append(circlePath)
        path.usesEvenOddFillRule = true
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        layer.mask = maskLayer
    }
    
    private func setupScanLine() {
        scanLine.frame = CGRect(x: bounds.midX - 100, y: bounds.midY - 150, width: 200, height: 2)
        scanLine.backgroundColor = UIColor.green
        scanLine.layer.cornerRadius = 1
        addSubview(scanLine)
    }
    
    private func animateScanLine() {
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.fromValue = bounds.midY - 150
        animation.toValue = bounds.midY + 150
        animation.duration = 2.0
        animation.repeatCount = .infinity
        animation.autoreverses = true
        scanLine.layer.add(animation, forKey: "scanLineAnimation")
    }
    
    // In FaceOverlayView.swift
    override func layoutSubviews() {
        super.layoutSubviews()
        // Instead of removing all sublayers, just update existing ones
        if let maskLayer = layer.mask as? CAShapeLayer {
            let path = UIBezierPath(rect: bounds)
            let radius: CGFloat = 150
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            path.append(circlePath)
            path.usesEvenOddFillRule = true
            maskLayer.path = path.cgPath
        }
        
        // Update scan line position
        scanLine.frame = CGRect(x: bounds.midX - 100, y: scanLine.frame.origin.y, width: 200, height: 2)
    }
}
