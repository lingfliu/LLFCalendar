//
//  UTKUICalendarView.swift
//  UTKCalendarDemo
//
//  Created by UTEAMTEC on 2018/9/18.
//  Copyright © 2018年 Lingfeng Liu. All rights reserved.
//

import UIKit
import JTAppleCalendar

class UTKUICalendarView: UIView {

    let cellReuseId = "UTKUICalendar"
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    let dateFormatter = DateFormatter()
    var calendar:JTAppleCalendarView?
    let today = Date()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let headerXib = UINib(nibName: "UTKUICalendarHeader", bundle: Bundle.main)
        let calendarHeader = headerXib.instantiate(withOwner: self, options: nil)[0] as! UIView
        calendarHeader.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 40)
        self.addSubview(calendarHeader)
        calendar = JTAppleCalendarView(frame: CGRect(x: 0, y: 40, width: frame.width, height: frame.height-40))
        self.addSubview(calendar!)
        
        setupCalendar()
    }
    
    func setupCalendar() {
        
        dateFormatter.dateFormat = "yyyy MM dd"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        
        calendar?.register(UTKUICalendarCellView.self, forCellWithReuseIdentifier: self.cellReuseId)
        calendar?.calendarDataSource = self
        calendar?.calendarDelegate = self
        calendar?.minimumLineSpacing = 0
        calendar?.minimumInteritemSpacing = 0
        calendar?.scrollingMode = ScrollingMode.stopAtEachCalendarFrame
        calendar?.scrollDirection = UICollectionViewScrollDirection.horizontal
        calendar?.showsVerticalScrollIndicator = false
        calendar?.showsHorizontalScrollIndicator = false
        calendar?.backgroundColor = UIColor(red: 0x76/255.0, green: 0xcc/255.0, blue: 0xd3/255.0, alpha: 1.0)
        calendar?.scrollToDate(today, animateScroll:true)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.onSwipeCalendar(_:)))
        panGesture.delegate = self
        calendar?.addGestureRecognizer(panGesture)
    }
    
    @objc func onSwipeCalendar(_ gesture:UIPanGestureRecognizer){
        let offset = gesture.translation(in: calendar)
        switch gesture.state {
        case .changed:
            print("changed, offset=",offset.y)
            break
        case.ended:
            print("changed, offset=",offset.y)
            break
        default:
            break
        }
        print("offset ",offset.y)
    }
}

extension UTKUICalendarView:JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: self.cellReuseId, for: indexPath) as! UTKUICalendarCellView
        cell.dayLabel.text = cellState.text
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: self.cellReuseId, for: indexPath) as? UTKUICalendarCellView
        
        cell?.dayLabel.text = cellState.text
        return cell!
    }
    
    
}

extension UTKUICalendarView:JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let startTime = dateFormatter.date(from: "2014 01 01")
        let stopTime = dateFormatter.date(from: "2100 12 31")
        let params = ConfigurationParameters(startDate: startTime!, endDate: stopTime!, numberOfRows: 6, calendar: Calendar.current, generateInDates: InDateCellGeneration.forAllMonths, generateOutDates: OutDateCellGeneration.tillEndOfGrid, firstDayOfWeek: .monday, hasStrictBoundaries: false)
        return params
    }
    
    
}

//non-blocking gesture recognizer
extension UTKUICalendarView:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
