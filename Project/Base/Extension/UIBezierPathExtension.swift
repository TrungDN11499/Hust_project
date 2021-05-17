//
//  UIBezierPathExtension.swift
//  Triponus
//
//  Created by Be More on 14/05/2021.
//

import UIKit

extension UIBezierPath {

    func topCurvePath(width: CGFloat, y1: CGFloat, y2: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: y1))
        path.addCurve(to: CGPoint(x: width / 2, y: y2), controlPoint1: CGPoint(x: 0, y: y1), controlPoint2: CGPoint(x: width / 4, y: y2))
        path.addCurve(to: CGPoint(x: width, y: y1), controlPoint1: CGPoint(x: width * 0.75, y: y2), controlPoint2: CGPoint(x: width, y: y1))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: y1))
        path.stroke()
        return path
    }

    func bottomCornerPath(width: CGFloat, height: CGFloat, statusHeight: CGFloat, radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: -statusHeight))
        path.addLine(to: CGPoint(x: 0.0, y: height - radius))
        path.addArc(withCenter: CGPoint(x: radius, y: height-radius), radius: radius, startAngle: .pi, endAngle: .pi/2, clockwise: false)
        path.addLine(to: CGPoint(x: width - radius, y: height))
        path.addArc(withCenter: CGPoint(x: width-radius, y: height-radius), radius: radius, startAngle: .pi/2, endAngle: 0, clockwise: false)
        path.addLine(to: CGPoint(x: width, y: -statusHeight))
        path.addLine(to: CGPoint(x: 0, y: -statusHeight))
        path.stroke()
        return path
    }
}
