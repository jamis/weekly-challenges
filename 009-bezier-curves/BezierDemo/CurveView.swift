//
//  CurveView.swift
//  BezierDemo
//
//  Created by Jamis Buck on 9/26/16.
//  Copyright © 2016 Jamis Buck. All rights reserved.
//

import Cocoa

class CurveView : NSView, CurveDelegate {
    var handles: [ControlPointView] = []
    let curve = Curve()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupQuadraticCurve()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupQuadraticCurve()
    }

    private func setupQuadraticCurve() {
        curve.delegate = self
        
        let x1 = Double(bounds.size.width) / 8.0
        let x2 = Double(bounds.size.width) / 2.0
        let x3 = Double(bounds.size.width) - x1
        
        let y2 = Double(bounds.size.height) / 8.0
        let y1 = Double(bounds.size.height) - y2
        
        let p1 = ControlPoint(x: x1, y: y2, w: 1.0)
        let p2 = ControlPoint(x: x2, y: y1, w: 1.0)
        let p3 = ControlPoint(x: x3, y: y2, w: 1.0)
        
        curve.addPoint(p1)
        curve.addPoint(p2)
        curve.addPoint(p3)
    }

    func elevateDegree() {
        curve.elevateDegree()
    }
    
    func curveChanged(_ curve: Curve) {
        setNeedsDisplay(bounds)
    }
    
    func curveControlPoint(_ point: ControlPoint, addedTo curve: Curve) {
        let cp = ControlPointView(point: point)
        self.addSubview(cp)
        handles.append(cp)
    }

/*
    func splitAt(at t: CGFloat) -> (CurveView, CurveView) {
        var list = points.map { point in point.center }
        var left = [NSPoint]()
        var right = [NSPoint]()
        
        while list.count > 1 {
            left.append(list[0])
            right.append(list[list.count-1])
            
            var newList = [NSPoint]()
            for i in 1...(list.count-1) {
                let x = list[i-1].x + (list[i].x - list[i-1].x) * t
                let y = list[i-1].y + (list[i].y - list[i-1].y) * t
                newList.append(NSPoint(x: x, y: y))
            }
            
            list = newList
        }
        
        left.append(list[0])
        right.append(list[0])
        
        let leftCurve = factory()
        for point in left { leftCurve.appendControlPoint(x: point.x, y: point.y) }

        let rightCurve = factory()
        for point in right.reversed() { rightCurve.appendControlPoint(x: point.x, y: point.y) }
        return (leftCurve, rightCurve)
    }
 */

    override func draw(_ dirtyRect: NSRect) {
        if handles.count > 0 {
            let path = NSBezierPath()
            
            let point = curve.evaluate(at: 0.0)
            path.move(to: NSPoint(x: CGFloat(point.0), y: CGFloat(point.1)))

            for t: Double in stride(from: 0.02, to: 1.019, by: 0.02) {
                let point = curve.evaluate(at: t)
                path.line(to: NSPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
            }
            
            NSColor.black.setStroke()
            path.stroke()
        }
    }
}
