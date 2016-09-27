//
//  QuadraticCurveView.swift
//  BezierDemo
//
//  Created by Jamis Buck on 9/25/16.
//  Copyright © 2016 Jamis Buck. All rights reserved.
//

import Cocoa

class QuadraticCurveView : CurveView {
    class func withDefaultCurveIn(frame frameRect: NSRect) -> QuadraticCurveView {
        let view = QuadraticCurveView(frame: frameRect)
        
        let x1 = frameRect.size.width / 8.0
        let x2 = frameRect.size.width / 2.0
        let x3 = frameRect.size.width - x1
        
        let y2 = frameRect.size.height / 8.0
        let y1 = frameRect.size.height - y2
        
        view.appendControlPoint(x: x1, y: y2)
        view.appendControlPoint(x: x2, y: y1)
        view.appendControlPoint(x: x3, y: y2)
        
        return view
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func evaluate(at t: CGFloat, points c: [NSPoint]) -> NSPoint {
        let t1 = (1 - t) * (1 - t)
        let t2 = (1 - t) * t
        let t3 = t * t
        
        let x = c[0].x * t1 + 2 * c[1].x * t2 + c[2].x * t3
        let y = c[0].y * t1 + 2 * c[1].y * t2 + c[2].y * t3
        
        return NSPoint(x: x, y: y)
    }
    
    override func factory() -> CurveView {
        return QuadraticCurveView(frame: frame)
    }
}
