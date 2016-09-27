//
//  CubicCurveView.swift
//  BezierDemo
//
//  Created by Jamis Buck on 9/26/16.
//  Copyright © 2016 Jamis Buck. All rights reserved.
//

import Cocoa

class CubicCurveView : CurveView {
    class func withDefaultCurveIn(frame frameRect: NSRect) -> CubicCurveView {
        let view = CubicCurveView(frame: frameRect)

        let x1 = frameRect.size.width / 8.0
        let x2 = frameRect.size.width - x1
        
        let y2 = frameRect.size.height / 8.0
        let y1 = frameRect.size.height - y2
        
        view.appendControlPoint(x: x1, y: y2)
        view.appendControlPoint(x: x1, y: y1)
        view.appendControlPoint(x: x2, y: y1)
        view.appendControlPoint(x: x2, y: y2)
        
        return view
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func evaluate(at t: CGFloat, points c: [NSPoint]) -> NSPoint {
        let ti = (1 - t)
        let t1 = ti * ti * ti
        let t2 = ti * ti * t
        let t3 = ti * t * t
        let t4 = t * t * t

        let x = c[0].x * t1 + 3 * c[1].x * t2 + 3 * c[2].x * t3 + c[3].x * t4
        let y = c[0].y * t1 + 3 * c[1].y * t2 + 3 * c[2].y * t3 + c[3].y * t4
        
        return NSPoint(x: x, y: y)
    }
    
    override func factory() -> CurveView {
        return CubicCurveView(frame: frame)
    }
}
