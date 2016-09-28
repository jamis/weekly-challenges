//
//  Curve.swift
//  BezierDemo
//
//  Created by Jamis Buck on 9/27/16.
//  Copyright © 2016 Jamis Buck. All rights reserved.
//

import Foundation

protocol CurveDelegate {
    func curveChanged(_ curve: Curve)
    func curveControlPoint(_ point: ControlPoint, addedTo curve: Curve)
}

class Curve: ControlPointDelegate {
    private var _points: [ControlPoint] = []
    private var _coeffs: [Double] = []
    
    var delegate: CurveDelegate?
    
    var degree: Int { return _points.count-1 }
    
    func controlPoint(_ i: Int) -> (Double, Double, Double) {
        return (_points[i].x, _points[i].y, _points[i].w)
    }

    func controlPointChanged(_ point: ControlPoint) {
        delegate?.curveChanged(self)
    }
    
    func addPoint(_ point: ControlPoint) {
        point.addDelegate(self)
        _points.append(point)
        recompute()
        delegate?.curveControlPoint(point, addedTo: self)
    }
    
    // generalized formula for rational Bezier curves of arbitrary degree
    //
    //    P(t) = sum(i=0,n) { Wi * choose(n,i) * (1-t)^(n-i) * t^i * Pi } /
    //           sum(i=0,n) { Wi * choose(n,i) * (1-t)^(n-i) * t^i }
    func evaluate(at t: Double) -> (Double, Double) {
        var x = 0.0
        var y = 0.0
        var w = 0.0
        
        let n = _points.count-1

        for i in 0...n {
            let coeff = _coeffs[i]
            let point = _points[i]
            var tc = 1.0
            
            for j in 0...n {
                if j < i { tc *= t }
                else if j > i { tc *= (1 - t) }
            }
            
            x += point.w * point.x * coeff * tc
            y += point.w * point.y * coeff * tc
            w += point.w * coeff * tc
        }
        
        return (x / w, y / w)
    }

    func project3D() -> [(Double, Double, Double)] {
        return _points.map { point in (point.x*point.w, point.y*point.w, point.w) }
    }

    func elevateDegree() {
        let points = project3D()
        let n1 = Double(points.count) // degree of curve + 1 == points.count
        
        let saved = points[points.count-1]

        for i in 1...points.count-1 {
            let a = Double(i) / n1

            let x = a * points[i-1].0 + (1 - a) * points[i].0
            let y = a * points[i-1].1 + (1 - a) * points[i].1
            let w = a * points[i-1].2 + (1 - a) * points[i].2

            _points[i].position = (x / w, y / w)
            _points[i].w = w
        }
        
        let w = saved.2
        let x = saved.0 / w
        let y = saved.1 / w

        let newPoint = ControlPoint(x: x, y: y, w: w)
        addPoint(newPoint)
    }

    func splitAt(at t: Double) -> (Curve, Curve) {
       var points = project3D()

       var left = [(Double, Double, Double)]()
       var right = [(Double, Double, Double)]()
    
       while points.count > 1 {
           left.append(points[0])
           right.append(points[points.count-1])
    
           var newList = [(Double, Double, Double)]()
           for i in 1...points.count-1 {
               let a = points[i-1]
               let b = points[i]
               
               let x = a.0 + (b.0 - a.0) * t
               let y = a.1 + (b.1 - a.1) * t
               let w = a.2 + (b.2 - a.2) * t

               newList.append((x, y, w))
           }
    
           points = newList
       }
    
       left.append(points[0])
       right.append(points[0])
    
       let leftCurve = Curve()
       for point in left {
           let w = point.2
           let x = point.0 / w
           let y = point.1 / w
           
           leftCurve.addPoint(ControlPoint(x: x, y: y, w: w))
       }
    
       let rightCurve = Curve()
       for point in right.reversed() {
           let w = point.2
           let x = point.0 / w
           let y = point.1 / w
           
           rightCurve.addPoint(ControlPoint(x: x, y: y, w: w))
       }

       return (leftCurve, rightCurve)
    }
 
    private func recompute() {
        while (_coeffs.count < _points.count) { _coeffs.append(0.0) }
        
        let n = _points.count - 1
        for k in 0...n {
            _coeffs[k] = choose(n: n, k: k)
        }
    }
    
    private func choose(n: Int, k: Int) -> Double {
        if k == n || k == 0 { return 1.0 }
        return choose(n: n-1, k: k-1) + choose(n: n-1, k: k)
    }
}
