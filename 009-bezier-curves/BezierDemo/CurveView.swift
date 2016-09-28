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
    var points: [(Double, Double, Double)] = []
    var activePoint: (Double, Double, Double)?
    var trackingArea: NSTrackingArea?
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

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }
        
        trackingArea = NSTrackingArea(rect: bounds, options: [.activeInActiveApp, .mouseMoved], owner: self, userInfo: nil)
        addTrackingArea(trackingArea!)
    }

    override func draw(_ dirtyRect: NSRect) {
        if handles.count > 0 {
            drawControlPolygon()
            drawCurve()
            drawActivePoint()
        }
    }
    
    override func mouseMoved(with event: NSEvent) {
        let pos = event.locationInWindow
        let x = Double(pos.x)
        let y = Double(pos.y)
        var closest: (Double, Double, Double)? = nil
        var closestDistance = 1000000.0
        
        for point in points {
            let dx = point.1 - x
            let dy = point.2 - y
            let d = sqrt(dx * dx + dy * dy)

            if d < closestDistance {
                closestDistance = d
                closest = point
            }
        }
        
        if let closest = closest {
            if closestDistance < 10.0 {
                if activePoint == nil || activePoint! != closest {
                    activePoint = closest
                    setNeedsDisplay(bounds)
                }
            } else {
                if activePoint != nil {
                    activePoint = nil
                    setNeedsDisplay(bounds)
                }
            }
        }
    }

    private func drawControlPolygon() {
        let poly = NSBezierPath()
        
        let point = curve.controlPoint(0)
        poly.move(to: NSPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
        
        for i in 1...curve.degree {
            let point = curve.controlPoint(i)
            poly.line(to: NSPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
            
        }
        
        NSColor.lightGray.setStroke()
        poly.stroke()
    }
    
    private func drawCurve() {
        let path = NSBezierPath()
        
        points.removeAll()

        let point = curve.evaluate(at: 0.0)
        points.append((0.0, point.0, point.1))

        path.move(to: NSPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
        
        for t: Double in stride(from: 0.02, to: 1.019, by: 0.02) {
            let point = curve.evaluate(at: t)
            points.append((t, point.0, point.1))

            path.line(to: NSPoint(x: CGFloat(point.0), y: CGFloat(point.1)))
        }
        
        NSColor.black.setStroke()
        path.stroke()
    }
    
    private func drawActivePoint() {
        if let point = activePoint {
            let dot = NSBezierPath(ovalIn: NSRect(x: CGFloat(point.1-3), y: CGFloat(point.2-3), width: 6, height: 6))
            NSColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0).setFill()
            NSColor(red: 0.0, green: 0.0, blue: 0.7, alpha: 1.0).setStroke();
            dot.fill()
            dot.stroke();
        }
    }
}
