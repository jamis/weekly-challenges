//
//  CurveViewController.swift
//  BezierDemo
//
//  Created by Jamis Buck on 9/25/16.
//  Copyright © 2016 Jamis Buck. All rights reserved.
//

import Cocoa

class CurveViewController : NSViewController {
    override func viewDidLoad() {
        let curve = CubicCurveView.withDefaultCurveIn(frame: view.bounds)
        let (left, right) = curve.splitAt(at: 0.75)
        view.addSubview(left)
        view.addSubview(right)
    }
}
