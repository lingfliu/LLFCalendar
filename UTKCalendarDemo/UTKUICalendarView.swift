//
//  UTKUICalendarView.swift
//  UTKCalendarDemo
//
//  Created by UTEAMTEC on 2018/9/18.
//  Copyright © 2018年 Lingfeng Liu. All rights reserved.
//

import UIKit
import JTAppleCalendar

protocol UTKUICalendarViewDelegate {
    func onYearChanged(year:Int64)
    func onMonthChanged(month:Int64)
    func onToMarkDate(date:Date)
    func onToDate(date:Date)
}

class UTKUICalendarView: UIView {

    
    var delegate:UTKUICalendarViewDelegate?
    let cellReuseId = "UTKUICalendar"
    var markedDate:[Date] = []
    var selectedDate = Date()
    var today = Date()
    
    var inDay:Int64?
    var inMonth:Int64?
    var inYear:Int64?
    
    let dateFormatter = DateFormatter()
    var calendar:JTAppleCalendarView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dateFormatter.dateFormat = "yyyy MM dd"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        let strs = dateFormatter.string(from: today).split(separator: " ")
        inMonth = Int64(strs[1])
        inYear = Int64(strs[0])
        
        let headerXib = UINib(nibName: "UTKUICalendarHeader", bundle: Bundle.main)
        let calendarHeader = headerXib.instantiate(withOwner: self, options: nil)[0] as! UIView
        calendarHeader.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 40)
        self.addSubview(calendarHeader)
        calendar = JTAppleCalendarView(frame: CGRect(x: 0, y: 40, width: frame.width, height: frame.height-40))
        self.addSubview(calendar!)
        
        setupCalendar()
    }
    
    
    func setupCalendar() {
        
//        markedDate.append(dateFormatter.date(from: "2018 09 19")!)
//        markedDate.append(dateFormatter.date(from: "2018 09 20")!)
//        markedDate.append(dateFormatter.date(from: "2018 09 21")!)
//        markedDate.append(dateFormatter.date(from: "2018 10 21")!)

        
        calendar?.register(UTKUICalendarCellView.self, forCellWithReuseIdentifier: self.cellReuseId)
        calendar?.calendarDataSource = self
        calendar?.calendarDelegate = self
        calendar?.minimumLineSpacing = 0
        calendar?.minimumInteritemSpacing = 0
        calendar?.scrollingMode = ScrollingMode.stopAtEachCalendarFrame
        calendar?.scrollDirection = UICollectionViewScrollDirection.horizontal
        calendar?.showsVerticalScrollIndicator = false
        calendar?.showsHorizontalScrollIndicator = false
        calendar?.backgroundColor = UIColor(red: 118/255.0, green: 204/255.0, blue: 211/255.0, alpha: 1)
        
        backToday()
        
    }
    
    func backToday() {
        today = Date()
        calendar?.scrollToDate(today, triggerScrollToDateDelegate: true, animateScroll: true, completionHandler: {
            self.calendar?.selectDates([self.today])
//            self.calendar?.reloadData() //failsafe solution to avoid nil cell deselect
        })
    }
    
    func isThisMonth(date:Date) -> Int64 {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        let month = Int64(formatter.string(from: date))
        formatter.dateFormat = "yyyy"
        let year = Int64(formatter.string(from: date))
        if month! < inMonth! && year! > inYear! {
            return 1 //next month
        }
        else if month! > inMonth! && year! < inYear!{
            return -1 //previous month
        }
        else {
            if month! < inMonth! {
                return -1
            }
            else if month! > inMonth! {
                return 1
            }
            else {
                return 0
            }
        }
    }
}

extension UTKUICalendarView:JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let dcell = cell as! UTKUICalendarCellView
        
        configCell(dateCell: dcell, date: date, label: cellState.text)

    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: self.cellReuseId, for: indexPath) as! UTKUICalendarCellView
        
        configCell(dateCell: cell, date:date, label:cellState.text)
        return cell
    }
    
    func configCell(dateCell:UTKUICalendarCellView, date:Date, label:String) {
        dateCell.dayLabel.text = label
        dateCell.setDate(date: date)
        
        if markedDate.contains(date) {
            dateCell.setMarked()
        }
        else {
            dateCell.setUnmarked()
        }
        
        if (calendar?.selectedDates.count)! > 0 {
            if dateFormatter.string(from: date) == dateFormatter.string(from:(calendar?.selectedDates[0])!) {
                dateCell.setSelected()
            }
            else {
                dateCell.setUnSelected()
            }
        }
        else {
            dateCell.setUnSelected()
        }

        

    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        if dateFormatter.string(from:date) != dateFormatter.string(from: selectedDate) {
            selectedDate = date
            print("selected date", date)
            let dateCell = cell as! UTKUICalendarCellView
            dateCell.setSelected()
            calendar.selectDates([date])
            
            if dateCell.isMarked && delegate != nil {
                delegate?.onToMarkDate(date: date)
            }

            let res = isThisMonth(date: date)
            if res == 1 {
                calendar.scrollToSegment(SegmentDestination.next)
            }
            else if res == -1 {
                calendar.scrollToSegment(SegmentDestination.previous)
            }
            
            if delegate != nil {
                delegate?.onToDate(date: date)
            }
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        let dateCell = cell as? UTKUICalendarCellView
        dateCell?.setUnSelected()
//        print("deselect cell", dateCell, " date ", dateCell?.date)

    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let inDate = visibleDates.monthDates[0].date
        let str = dateFormatter.string(from: inDate)
        let strs = str.split(separator: " ")
        let year = Int64(strs[0])!
        let month = Int64(strs[1])!
        
        if delegate != nil {
            if (month != inMonth) {
                inMonth = month
                delegate?.onMonthChanged(month: inMonth!)
            }
            
            if (year != inYear) {
                inYear = year
                delegate?.onYearChanged(year: inYear!)
            }
        }
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
