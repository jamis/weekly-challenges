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
    }
    
    @IBAction func addNewPoint(sender: AnyObject) {
        let curveView = view as! CurveView
        curveView.elevateDegree()
    }
    
    @IBAction func splitActiveCurve(sender: AnyObject) {
        let curveView = view as! CurveView
        curveView.splitActiveCurve()
    }
}
