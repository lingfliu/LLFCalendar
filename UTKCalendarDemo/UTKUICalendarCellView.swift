//
//  UTKUICalendarCellView.swift
//  UTKCalendarDemo
//
//  Created by Lingfeng Liu on 2018/4/12.
//  Copyright © 2018年 Lingfeng Liu. All rights reserved.
//

import UIKit
import JTAppleCalendar
class UTKUICalendarCellView:  JTAppleCell{
    @IBOutlet var mainView: UTKUICalendarCellView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var marker: UIImageView!
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("UTKUICalendarCell", owner: self, options: nil)
        mainView.frame = self.bounds
        mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        marker.alpha = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
    }
    
    func setMarked() {
        UIView.animate(withDuration: 0.4) {
            self.marker.alpha = 1
        }
    }
    
    func setUnmarked() {
        UIView.animate(withDuration: 0.2) {
            self.marker.alpha = 0
        }
    }
}
