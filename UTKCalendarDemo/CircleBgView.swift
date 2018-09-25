//
//  CircleBgView.swift
//  UTKCalendarDemo
//
//  Created by Lingfeng Liu on 2018/9/20.
//  Copyright © 2018年 Lingfeng Liu. All rights reserved.
//

import UIKit

class CircleBgView: UIView {
    
    var h:CGFloat!
    var w:CGFloat!
    var c:CGPoint!
    override func layoutSubviews() {
        h = frame.height
        w = frame.width
        c = CGPoint(x: w/2.0, y: h/2.0)
    }
    override func draw(_ rect: CGRect) {
        // Drawing code
        h = bounds.height
        w = bounds.width
        c = CGPoint(x: w/2.0, y: h/2.0)
        let r = h > w ? w/2.0*0.8 : h/2.0*0.8
        
        let path = UIBezierPath.init(arcCenter: c, radius: r, startAngle:0, endAngle:CGFloat.pi*2, clockwise:true)
        
        let color = UIColor.white
        color.setFill()
        path.fill()
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.addPath(path.cgPath)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }

}
