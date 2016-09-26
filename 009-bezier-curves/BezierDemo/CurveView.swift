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
