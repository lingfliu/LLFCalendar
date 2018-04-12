//
//  ViewController.swift
//  UTKCalendarDemo
//
//  Created by Lingfeng Liu on 2018/4/12.
//  Copyright © 2018年 Lingfeng Liu. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController {

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var backTodayBtn: UIButton!
    @IBOutlet weak var modeSwitchBtn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    let dateFormatter = DateFormatter()
    enum UTKUICalendarMode {
        case week
        case month
    }
    var calMode:UTKUICalendarMode = .month
    let calReuseId = "UTKUICalendar"
    var selectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Setup calendar spacing
//        calendarView = JTAppleCalendarView(frame: CGRect)
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        let nib = UINib(nibName: "UTKUICalendarCell", bundle: Bundle.main)
        calendarView.register(nib, forCellWithReuseIdentifier: calReuseId)
        
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        calendarView.scrollingMode = ScrollingMode.stopAtEachCalendarFrame
        calendarView.scrollDirection = UICollectionViewScrollDirection.horizontal
        // Setup labels
        dateFormatter.dateFormat = "yyyy MM dd"
        selectedDate = dateFormatter.date(from: "2013 01 01")!
        calendarView.scrollToDate(selectedDate, animateScroll: false)
        calendarView.selectDates([selectedDate])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func switchMode(_ sender: Any) {
        switch calMode {
        case.week:
            calMode = .month
            break
        case.month:
            calMode = .week
            break
        }
        calendarView.reloadData()
    }
    
    @IBAction func backToday(_ sender: Any) {
        selectedDate = Date()
        calendarView.scrollToDate(selectedDate, triggerScrollToDateDelegate: true, animateScroll: true, preferredScrollPosition: .left, extraAddedOffset: 0) {
            self.calendarView.selectDates([self.selectedDate])
        }
    }
}

extension ViewController: JTAppleCalendarViewDelegate,JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        dateFormatter.dateFormat = "yyyy MM dd"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        
        var numRow = 1
        switch calMode {
        case.week:
            numRow = 1
            break
        case.month:
            numRow = 6
            break
        }
        
        let startTime = dateFormatter.date(from: "2014 01 01")!
        let stopTime = dateFormatter.date(from: "2100 12 31")!
        let parameters = ConfigurationParameters(startDate: startTime, endDate: stopTime, numberOfRows: numRow, calendar: Calendar.current, generateInDates: InDateCellGeneration.forAllMonths, generateOutDates: OutDateCellGeneration.tillEndOfGrid, firstDayOfWeek: .monday, hasStrictBoundaries: false)
        
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        dateLabel.text = dateFormatter.string(for:visibleDates.monthDates[0].date)
    }
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cellView = cell as? UTKUICalendarCellView else {return}
        if cellState.isSelected && cellState.dateBelongsTo == .thisMonth {
            UIView.animate(withDuration: 0.4, animations: {
                cellView.selectedNoter.alpha = 1
//                cellView.isUserInteractionEnabled = false
            })
        }
        else if cellState.isSelected && cellState.dateBelongsTo == .followingMonthWithinBoundary {
//            calendarView.scrollToSegment(SegmentDestination.next)
            calendar.scrollToSegment(.next, completionHandler: {
                self.selectedDate = date
                calendar.selectDates([self.selectedDate])
            })
        }
        else if cellState.isSelected && cellState.dateBelongsTo == .previousMonthWithinBoundary {
//            calendarView.scrollToSegment(SegmentDestination.previous)
            calendar.scrollToSegment(.previous, completionHandler: {
                self.selectedDate = date
                calendar.selectDates([self.selectedDate])
            })
        }
    }
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date:
        Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cellView = cell as? UTKUICalendarCellView else {return}
        if cellState.dateBelongsTo == .thisMonth || cellState.dateBelongsTo == .followingMonthWithinBoundary || cellState.dateBelongsTo == .previousMonthWithinBoundary{
            UIView.animate(withDuration: 0.4, animations: {
                cellView.selectedNoter.alpha = 0
            })
        }
    }
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cellView  = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: calReuseId, for: indexPath) as! UTKUICalendarCellView
        if cellState.dateBelongsTo == .thisMonth  && cellState.isSelected{
            UIView.animate(withDuration: 0.4, animations: {
                cellView.selectedNoter.alpha = 1
            })
        }
        else if (cellState.dateBelongsTo == .thisMonth || cellState.dateBelongsTo == .followingMonthWithinBoundary || cellState.dateBelongsTo == .previousMonthWithinBoundary)
            && !cellState.isSelected && cellView.selectedNoter.alpha > 0{
            UIView.animate(withDuration: 0.4, animations: {
                cellView.selectedNoter.alpha = 0
            })
        }
        cellView.dayLabel.text = cellState.text
        return cellView
    }
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cellView  = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: calReuseId, for: indexPath) as! UTKUICalendarCellView
        if cellState.dateBelongsTo == .thisMonth  && cellState.isSelected{
            UIView.animate(withDuration: 0.4, animations: {
                cellView.selectedNoter.alpha = 1
            })
        }
        else if cellState.dateBelongsTo == .thisMonth && !cellState.isSelected && cellView.selectedNoter.alpha > 0{
            UIView.animate(withDuration: 0.4, animations: {
                cellView.selectedNoter.alpha = 0
            })
        }
        cellView.dayLabel.text = cellState.text
    }
}
