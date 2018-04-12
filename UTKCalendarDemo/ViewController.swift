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

    @IBOutlet  var calendarView: JTAppleCalendarView!
    @IBOutlet  var recordListView: UITableView!
    
    @IBOutlet weak var backTodayBtn: UIButton!
    @IBOutlet weak var modeSwitchBtn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    let dateFormatter = DateFormatter()
    enum UTKUICalendarMode {
        case week
        case month
    }
    var calMode:UTKUICalendarMode = .week
    let calReuseId = "UTKUICalendar"
    var selectedDate = Date()
    var offsetYRec = CGFloat(0)
    var offsetYCal = CGFloat(0)
    var calFoldDepth = 0
    var modeTriggerY = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Setup calendar spacing
        let rootFrame = self.view.frame
        calendarView = JTAppleCalendarView(frame: CGRect(x: 0, y: 120, width: rootFrame.size.width, height: 54))
        self.view.insertSubview(calendarView, at: 0)
        recordListView = UITableView(frame:CGRect(x:0,y:174,width:rootFrame.size.width, height:rootFrame.size.height-174))
        self.view.addSubview(recordListView)
        
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        let nib = UINib(nibName: "UTKUICalendarCell", bundle: Bundle.main)
        calendarView.register(nib, forCellWithReuseIdentifier: calReuseId)
        
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        calendarView.scrollingMode = ScrollingMode.stopAtEachCalendarFrame
        calendarView.scrollDirection = UICollectionViewScrollDirection.horizontal
        calendarView.showsVerticalScrollIndicator = false;
        calendarView.showsHorizontalScrollIndicator = false;
        calendarView.backgroundColor = UIColor(red: 0x1a/255.0, green: 0xaa/255.0, blue: 0xb6/255.0, alpha: 1.0)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onSwipeCalendar(_:)))
        panGesture.delegate = self
        calendarView.addGestureRecognizer(panGesture)
        // Setup labels
        dateFormatter.dateFormat = "yyyy MM dd"
        selectedDate = dateFormatter.date(from: "2018 12 29")!
        calendarView.scrollToDate(selectedDate, animateScroll: false)
        calendarView.selectDates([selectedDate])
        
        print (selectedDate.weekOfMonth())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var weekCurrent = Date()
    
    @objc func onSwipeCalendar(_ gesture:UIPanGestureRecognizer) {
        calendarView.selectDates([selectedDate])
        switch gesture.state {
        case.began:
            calendarView.isUserInteractionEnabled = false
            break
        case.changed:
            let offset = gesture.translation(in: calendarView)
            let offsetX = offset.x
            let offsetY = offset.y
            if (offsetX / offsetY > 2 || offsetX / offsetY < -2) {
                calendarView.isScrollEnabled = true
            }
            else {
                calendarView.isScrollEnabled = false
                if offsetY > 0 {
                    //pull
                    if calMode == .week {
                        if offsetY > 54 {
                            //switch to month mode
                            //backup current for restore
                            weekCurrent = firstDayOfSegment()
                            calFoldDepth = initWeekOfMonth()
                            calMode = .month
                            
                            UIView.animate(withDuration: 0.4, animations: {
                                self.calendarView.reloadData()
                                self.calendarView.scrollToDate(self.weekCurrent, animateScroll:false, completionHandler: {
                                    self.calendarView.selectDates([self.selectedDate])
                                })
                                
                                //transform finally goes here
                                self.calendarView.transform = CGAffineTransform(translationX: 0, y: self.offsetYCal+offsetY > 0 ? 0 : self.offsetYCal+offsetY)
                                self.recordListView.transform = CGAffineTransform(translationX: 0, y: offsetY+self.offsetYRec>54*6 ? 54*6 : offsetY+self.offsetYRec)
                            })
                            
                            self.calendarView.frame = CGRect(x:0,y:120,width:self.calendarView.frame.width,height:54*6)
                            self.calendarView.transform = CGAffineTransform(translationX: 0, y: 0 - CGFloat(54)*CGFloat(self.calFoldDepth))
                            offsetYCal = 0-CGFloat(calFoldDepth)*CGFloat(54)
                            offsetYRec = 0
                        }
                    }
                    else {
                        //in month mode, simply transform
                        self.calendarView.transform = CGAffineTransform(translationX: 0, y: self.offsetYCal+offsetY > 0 ? 0 : self.offsetYCal+offsetY)
                        self.recordListView.transform = CGAffineTransform(translationX: 0, y: offsetY+self.offsetYRec>54*6 ? 54*6 : offsetY+self.offsetYRec)
                    }
                }
                else {
                    //push only works in month mode
                    if calMode == .month {
                        if offsetY+offsetYRec < CGFloat(calFoldDepth-1)*CGFloat(54) {
                            //fold the calendar offset same as the recordlistview
                            self.calendarView.transform = CGAffineTransform(translationX: 0, y: offsetY > 0-CGFloat(calFoldDepth)*CGFloat(54) ? offsetY : 0 - CGFloat(calFoldDepth)*CGFloat(54))
                        }
                        
                        self.recordListView.transform = CGAffineTransform(translationX: 0, y: offsetY+self.offsetYRec < 0 ? 0 : offsetY+self.offsetYRec)
                    }
                }
            }
                
//                        print("push offsetY =", offsetY, " offsetRec = ", offsetYRec, " offsetCal = ", offsetYCal)
//                        print("pull offsetY =", offsetY, " offsetRec = ", offsetYRec, " offsetCal = ", offsetYCal)


            break
        case.ended:
            calendarView.isUserInteractionEnabled = true
            calendarView.isScrollEnabled = true
            
            let offset = gesture.translation(in: calendarView)
            let offsetY = offset.y
            
            if calMode == .month {
               
                if offsetY > 0 {
                    //pull
                    offsetYRec += offsetY
                    if offsetYRec > 6*54 {
                        offsetYRec = 6*54
                    }
                    offsetYCal += offsetY
                    if offsetYCal > 0 {
                        offsetYCal = 0
                    }
                }
                else {
                    //push
                    offsetYRec += offsetY
                    if offsetYRec < 0 {
                        offsetYRec = 0
                    }
                    
                    if offsetYRec < CGFloat(calFoldDepth-1)*CGFloat(54) {
                        offsetYCal =  offsetY > 0-CGFloat(calFoldDepth)*CGFloat(54) ? offsetY : 0 - CGFloat(calFoldDepth)*CGFloat(54)
                    }
                    else {
                        offsetYCal = 0
                    }
                    
                    if offsetYRec < 10 {
                        //pushed back to week mode
                        calMode = .week
                        calendarView.reloadData()
                        self.calendarView.scrollToDate(self.weekCurrent, animateScroll: false,completionHandler: {
                            self.calendarView.selectDates([self.selectedDate])
                        })
                        calendarView.frame = CGRect(x:0,y:120,width:calendarView.frame.width,height:54)
                        offsetYRec = 0
                        offsetYCal = 0 - CGFloat(calFoldDepth)*CGFloat(54)
                    }
                }
            }
            else {
                offsetYRec = 0
                offsetYCal = 0 - CGFloat(calFoldDepth)*CGFloat(54)
            }
            break
        
        default:
            calendarView.isScrollEnabled = true
            calendarView.isUserInteractionEnabled = true
            break
        }
    }
    
    @IBAction func switchMode(_ sender: Any) {
        switch calMode {
        case.week:
            calMode = .month
            weekCurrent = firstDayOfSegment()
            print (weekCurrent)
            calFoldDepth = initWeekOfMonth()
            calendarView.reloadData()
            self.calendarView.scrollToDate(self.weekCurrent, animateScroll:false, completionHandler: {
                self.calendarView.selectDates([self.selectedDate])
            })
            self.calendarView.frame = CGRect(x:0,y:120,width:self.calendarView.frame.width,height:54*6)
            print("fold depth = ", self.calFoldDepth)
            self.calendarView.transform = CGAffineTransform(translationX: 0, y: 0 - CGFloat(54)*CGFloat(self.calFoldDepth))
            offsetYCal = 0-CGFloat(calFoldDepth)*CGFloat(54)
            offsetYRec = 0
            UIView.animate(withDuration: 0.8, animations: {
                self.calendarView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.recordListView.transform = CGAffineTransform(translationX: 0, y: 54*6)
            })
            
            break
        case.month:
            calMode = .week
            UIView.animate(withDuration: 0.8, animations: {
                self.calendarView.transform =  CGAffineTransform(translationX: 0, y: 0 - CGFloat(54)*CGFloat(self.calFoldDepth))
                self.recordListView.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: { (finished) in
                self.calendarView.reloadData()
                self.calendarView.frame = CGRect(x:0,y:120,width:self.calendarView.frame.width,height:54)
                self.calendarView.scrollToDate(self.weekCurrent, animateScroll:false, completionHandler: {
                    self.calendarView.selectDates([self.selectedDate])
                })
            })
            
            break
        }
        
    }
    
    @IBAction func backToday(_ sender: Any) {
        selectedDate = Date()
        calendarView.scrollToDate(selectedDate, triggerScrollToDateDelegate: true, animateScroll: true, preferredScrollPosition: .left, extraAddedOffset: 0) {
            self.calendarView.selectDates([self.selectedDate])
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
        let parameters = ConfigurationParameters(startDate: startTime, endDate: stopTime, numberOfRows: numRow, calendar: Calendar.current, generateInDates: InDateCellGeneration.forAllMonths, generateOutDates: OutDateCellGeneration.tillEndOfGrid, firstDayOfWeek: .sunday, hasStrictBoundaries: false)
        
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        if calMode == .week {
            if visibleDates.indates.count > 0 {
                dateLabel.text = dateFormatter.string(for:visibleDates.indates[0].date)
            }
            else if visibleDates.monthDates.count > 0 {
                dateLabel.text = dateFormatter.string(for:visibleDates.monthDates[0].date)

            }
            else {
                dateLabel.text = dateFormatter.string(for:visibleDates.outdates[0].date)
            }
        }
        else {
            dateLabel.text = dateFormatter.string(for:visibleDates.monthDates[0].date)
        }
        
        weekCurrent = firstDayOfSegment()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cellView = cell as? UTKUICalendarCellView else {return}
        if cellState.isSelected && cellState.dateBelongsTo == .thisMonth && cellView.selectedNoter.alpha < 0.5{
            UIView.animate(withDuration: 0.4, animations: {
                cellView.selectedNoter.alpha = 1
//                cellView.isUserInteractionEnabled = false
            })
        }
        else if cellState.isSelected && cellState.dateBelongsTo == .followingMonthWithinBoundary && calMode == .month{
            calendar.scrollToSegment(.next, completionHandler: {
                self.selectedDate = date
                calendar.selectDates([self.selectedDate])
            })
            
        }
        else if cellState.isSelected && cellState.dateBelongsTo == .previousMonthWithinBoundary && calMode == .month{
            calendar.scrollToSegment(.previous, completionHandler: {
                self.selectedDate = date
                calendar.selectDates([self.selectedDate])
            })
        }
        else if cellState.isSelected && calMode == .week {
            UIView.animate(withDuration: 0.4, animations: {
                cellView.selectedNoter.alpha = 1
                //                cellView.isUserInteractionEnabled = false
            })
        }
    }
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date:
        Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cellView = cell as? UTKUICalendarCellView else {return}
        if (cellState.dateBelongsTo == .thisMonth || cellState.dateBelongsTo == .followingMonthWithinBoundary || cellState.dateBelongsTo == .previousMonthWithinBoundary) && calMode == .month && cellView.selectedNoter.alpha > 0.5{
            UIView.animate(withDuration: 0.4, animations: {
                cellView.selectedNoter.alpha = 0
            })
        }
        else if calMode == .week && cellView.selectedNoter.alpha > 0.5{
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
    
    func isThisMonth() -> Bool {
        let today = Date()
        dateFormatter.dateFormat = "yyyy"
        let yearStr = dateFormatter.string(from: calendarView.visibleDates().monthDates[0].date)
        let yearTodayStr = dateFormatter.string(from: today)
        
        dateFormatter.dateFormat = "MM"
        let monthStr = dateFormatter.string(from: calendarView.visibleDates().monthDates[0].date)
        let monthTodayStr = dateFormatter.string(from: today)

        if (yearStr == yearTodayStr && monthStr == monthTodayStr) {
            return true
        }
        else {
            return false
        }
    }
    
    //which week should be the init display week of the month when the calendar is transferring from month to week mode
    func initWeekOfMonth() -> Int{
        
        if calendarView.visibleDates().indates.count > 0 {
            return calendarView.visibleDates().indates[0].date.weekOfMonth() - 1
        }
        else if calendarView.visibleDates().monthDates.count > 0 {
            return calendarView.visibleDates().monthDates[0].date.weekOfMonth() - 1
        }
        else {
            return calendarView.visibleDates().outdates[0].date.weekOfMonth() - 1
        }
    }
    
    //which week should be the init display week of the month when the calendar is transferring from month to week mode
    func firstDayOfSegment() -> Date{
        if calendarView.visibleDates().indates.count > 0 {
            return calendarView.visibleDates().indates[0].date
        }
        else if calendarView.visibleDates().monthDates.count > 0 {
            return calendarView.visibleDates().monthDates[0].date
        }
        else {
            return calendarView.visibleDates().outdates[0].date
        }
    }
}

extension Date {
    
    func weekOfMonth() -> Int {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.weekOfMonth, Calendar.Component.weekday], from: self)
        return (dateComponents.weekOfMonth!)
    }
    
//    func nextWeek(day:Int) -> Date {
//        let calendar = Calendar.current
//        var dateComponents = calendar.dateComponents([
//            Calendar.Component.weekOfYear,
//            Calendar.Component.weekday,
//            Calendar.Component.year,
////            Calendar.Component.month,
////            Calendar.Component.day
//            ],
//            from: self)
//
//        if (dateComponents.weekOfYear! < self.weeksInYear()) {
//            dateComponents.weekOfYear = dateComponents.weekOfYear! + 1
//
//        }
//        else {
//            dateComponents.year = dateComponents.year! + 1
//           dateComponents.weekOfYear = 1
//            dateComponents.month = 1
//        }
//        dateComponents.weekday = day
//        return calendar.date(from: dateComponents)!
//    }
//
//    func weeksInYear() -> Int {
//
//        let weekBase = 53
//
//        let calendar = Calendar.current
//        var dateComponents = calendar.dateComponents([
//            Calendar.Component.year,
//            Calendar.Component.yearForWeekOfYear,
//            Calendar.Component.weekOfYear,
//            Calendar.Component.day
//            ],
//                                                     from: self)
//        let thisYear = dateComponents.year
//
//        dateComponents.weekOfYear = weekBase
//        dateComponents.day = 1
//
//        let date = calendar.date(from: dateComponents)
//
//        dateComponents = calendar.dateComponents([
//            Calendar.Component.year,
//            Calendar.Component.yearForWeekOfYear,
//            Calendar.Component.weekOfYear,
//            Calendar.Component.day
//            ],
//                                                 from: date!)
//
//        if (thisYear != dateComponents.yearForWeekOfYear)  {
//            return 52
//        }
//        else {
//            return 53
//        }
//    }
//
//    
//    func previousWeek(day:Int) -> Date {
//        let calendar = Calendar.current
//        var dateComponents = calendar.dateComponents([Calendar.Component.weekOfYear], from: self)
//        dateComponents.weekOfYear = dateComponents.weekOfYear! + 1
//        dateComponents.weekday = day
//        return calendar.date(from: dateComponents)!
//    }
    
    func startMonth() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM"
        var dateStr = ""
        dateStr += dateFormatter.string(from: self)
        dateStr += " 01"
        dateFormatter.dateFormat = "yyyy MM dd"
        let date = dateFormatter.date(from: dateStr)
        return date!
    }
    
    func endMonth() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM"
        var dateStr = ""
        dateStr += dateFormatter.string(from: self)
        dateStr += " 01"
        dateFormatter.dateFormat = "yyyy MM dd"
        let date = dateFormatter.date(from: dateStr)
        return date!
    }
    
    
}

