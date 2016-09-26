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

protocol ControlPointDelegate {
    func controlPointMoved(_ point: ControlPointView)
}

class ControlPointView : NSView {
    var state = ControlPointState.normal
    var delegate: ControlPointDelegate? = nil
    var trackingArea: NSTrackingArea? = nil

    var radius: CGFloat {
        return (bounds.size.width / 2.0)
    }
    
    var center: NSPoint {
        return NSPoint(x: frame.origin.x + frame.size.width / 2.0, y: frame.origin.y + frame.size.height / 2.0)
    }

    init(origin: NSPoint, radius: CGFloat) {
        let frame = NSRect(x: origin.x - radius, y: origin.y - radius, width: radius*2, height: radius*2)
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
        state = .active
        setNeedsDisplay(bounds)
    }
    
    override func mouseDragged(with event: NSEvent) {
        let p = event.locationInWindow
        setFrameOrigin(NSPoint(x: p.x - radius, y: p.y - radius))

        delegate?.controlPointMoved(self)
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
        let d: CGFloat = (state == .active || state == .highlighted) ? 1 : 5
        let path = NSBezierPath(ovalIn: bounds.insetBy(dx: d, dy: d))
        
        if (state == .highlighted || state == .active) {
            NSColor.red.setFill()
        } else {
            NSColor.gray.setFill()
        }

        NSColor.black.setStroke()

        path.fill()
        path.stroke()
    }
}
