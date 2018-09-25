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
    @IBOutlet weak var selectNoter: CircleBgView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var marker: UIImageView!
    
    var date:Date?
    var isMarked = false
    var isChosen = false
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
        let nib = UINib(nibName: "UTKUICalendarCell", bundle: Bundle.main);
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
        marker.alpha = 0
    }

    func setDate(date:Date) {
        self.date = date
    }
    
    func setSelected() {
        self.isChosen = true
        UIView.animate(withDuration: 0.2) {
            self.selectNoter.transform = CGAffineTransform(scaleX: 1, y: 1)
            let colorSelected = UIColor(red: 118/255.0, green: 204/255.0, blue: 211/255.0, alpha: 1)
            self.dayLabel.textColor = colorSelected
            self.marker.tintColor = colorSelected
        }
    }
    
    func setUnSelected() {
        self.isChosen = false
//        UIView.animate(withDuration: 0.8) {
            self.selectNoter.transform = CGAffineTransform(scaleX: 0, y: 0)
            self.dayLabel.textColor = UIColor.white
//        }
       
    }
    
    func setMarked() {
        self.isMarked = true
        UIView.animate(withDuration: 0.4) {
            self.marker.alpha = 1
        }
    }
    
    func setUnmarked() {
        self.marker.alpha = 0
        self.isMarked = false
    }
    
}
