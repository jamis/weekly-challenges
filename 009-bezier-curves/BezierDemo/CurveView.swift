//
//  CurveView.swift
//  BezierDemo
//
//  Created by Jamis Buck on 9/26/16.
//  Copyright © 2016 Jamis Buck. All rights reserved.
//

import Cocoa

class CurveView : NSView, ControlPointDelegate {
    var points: [ControlPointView] = []
    
    func appendControlPoint(x: CGFloat, y: CGFloat) {
        let point = ControlPointView(origin: NSPoint(x: x, y: y), radius: 10.0)
        point.delegate = self
        points.append(point)
        addSubview(point)
    }
    
    func evaluate(at t: CGFloat, points c: [NSPoint]) -> NSPoint {
        preconditionFailure("subclasses must define #evaluate")
    }


    func factory() -> CurveView {
        preconditionFailure("subclasses must define #factory")
    }

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

    override func draw(_ dirtyRect: NSRect) {
        if points.count > 0 {
            let path = NSBezierPath()
            
            let c = points.map { point in point.center }
            
            path.move(to: c[0])
            for t: CGFloat in stride(from: 0.02, to: 0.999, by: 0.02) {
                let point = evaluate(at: t, points: c)
                path.line(to: point)
            }
            path.line(to: c[c.count-1])
            
            NSColor.black.setStroke()
            path.stroke()
        }
    }
    
    func controlPointMoved(_ point: ControlPointView) {
        setNeedsDisplay(bounds)
    }
}
