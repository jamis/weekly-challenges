//
//  ControlPoint.swift
//  BezierDemo
//
//  Created by Jamis Buck on 9/27/16.
//  Copyright © 2016 Jamis Buck. All rights reserved.
//

import Foundation

protocol ControlPointDelegate {
    func controlPointChanged(_ point: ControlPoint)
}

class ControlPoint {
    private var _x: Double
    private var _y: Double
    private var _w: Double

    var x: Double { return _x }
    var y: Double { return _y }
    
    var position: (Double, Double) {
        get { return (_x, _y) }
        set(xy) {
            _x = xy.0
            _y = xy.1
            changed()
        }
    }
    
    var w: Double {
        get { return _w }
        set(newW) {
            _w = newW
            changed()
        }
    }

    private var delegates = [ControlPointDelegate]()
    
    init(x: Double, y: Double, w: Double) {
        _x = x
        _y = y
        _w = w
    }
    
    func addDelegate(_ delegate: ControlPointDelegate) {
        delegates.append(delegate)
    }
    
    private func changed() {
        for delegate in delegates { delegate.controlPointChanged(self) }
    }
}
