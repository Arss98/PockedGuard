//
//  CircleView.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 12.06.2025.
//

import UIKit

final class CircleView: UIView {
    let lineWidth: CGFloat = 3
    
    var strokeColor: UIColor = .systemBlue {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        createCirclePath()
    }
    
    private func createCirclePath() {
        layer.sublayers?.forEach { $0.removeFromSuperlayer()}
        
        let radius: CGFloat = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        let path: UIBezierPath = .init(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: radius,
            startAngle: .zero,
            endAngle: 2 * .pi,
            clockwise: true
        )
        
        let shapeLayer: CAShapeLayer = .init()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        
        layer.addSublayer(shapeLayer)
    }
}
