//
//  ControlPointView.swift
//  BezierDemo
//
//  Created by Jamis Buck on 9/25/16.
//  Copyright © 2016 Jamis Buck. All rights reserved.
//

import Cocoa

enum ControlPointState {
    case normal, active, highlighted
}

class ControlPointView : NSView, ControlPointDelegate {
    let point: ControlPoint
    var state = ControlPointState.normal
    var trackingArea: NSTrackingArea? = nil

    var radius: CGFloat {
        return CGFloat(point.w) * 5
    }

    init(point: ControlPoint) {
        self.point = point

        let r = CGFloat(point.w) * 5 + 1
        let frame = NSRect(x: CGFloat(point.x) - r, y: CGFloat(point.y) - r, width: r*2, height: r*2)
        super.init(frame: frame)

        point.addDelegate(self)
    }

    required init?(coder: NSCoder) {
        preconditionFailure("ControlPointView's init with coder should never be used")
    }

    func remove() {
        removeFromSuperview()
        point.removeDelegate(self)
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }

        trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        addTrackingArea(trackingArea!)
    }

    override func mouseDown(with event: NSEvent) {
        state = .active
        setNeedsDisplay(bounds)
    }
    
    override func mouseUp(with event: NSEvent) {
        state = .highlighted
        setNeedsDisplay(bounds)
    }
    
    override func mouseDragged(with event: NSEvent) {
        state = .active
        
        if event.modifierFlags.contains(.shift) {
            let dw = (abs(event.deltaX) > abs(event.deltaY) ? event.deltaX : event.deltaY) / 25.0
            let w = min(max(point.w + Double(dw), 0.4), 5.0)
            point.w = w
        } else {
            let p = event.locationInWindow
            point.position = (Double(p.x), Double(p.y))
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        state = .highlighted
        setNeedsDisplay(bounds)
    }
    
    override func mouseExited(with event: NSEvent) {
        state = .normal
        setNeedsDisplay(bounds)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath(ovalIn: bounds.insetBy(dx: 1, dy: 1))
        
        if state == .highlighted {
            NSColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1).setFill()
            NSColor(red: 0.6, green: 0, blue: 0, alpha: 1).setStroke()
        } else if state == .active {
            NSColor(red: 1.0, green: 0, blue: 0, alpha: 1).setFill()
            NSColor(red: 0.6, green: 0, blue: 0, alpha: 1).setStroke()
        } else {
            NSColor.gray.setFill()
            NSColor.black.setStroke()
        }

        path.fill()
        path.stroke()
    }
    
    func controlPointChanged(_ point: ControlPoint) {
        let r = radius + 1
        
        setFrameOrigin(NSPoint(x: CGFloat(point.x) - r, y: CGFloat(point.y) - r))
        setFrameSize(NSSize(width: r*2, height: r*2))
    }
}
