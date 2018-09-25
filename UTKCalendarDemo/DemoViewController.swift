//
//  DemoViewController.swift
//  UTKCalendarDemo
//
//  Created by UTEAMTEC on 2018/9/18.
//  Copyright © 2018年 Lingfeng Liu. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {

    @IBOutlet weak var calendar: UTKUICalendarView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var today: UIButton!
    
    var isCalendarFold = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        calendar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setCalendarBackToday(_ sender: Any) {
        calendar.backToday()
    }
    @IBAction func foldCalendar(_ sender: Any) {
        if (isCalendarFold) {
            //unfold calendar
            UIView.animate(withDuration: 0.4) {
                self.calendar?.transform = CGAffineTransform(translationX: 0, y: -self.calendar.frame.height)
            }
        }
        else {
            UIView.animate(withDuration: 0.4) {
                self.calendar?.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        }
        isCalendarFold = !isCalendarFold
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DemoViewController: UTKUICalendarViewDelegate {
    func onYearChanged(year: Int64) {
        yearLabel.text = String(year)
    }
    
    func onMonthChanged(month: Int64) {
        monthLabel.text = String(month)
    }
    
    func onToMarkDate(date: Date) {
        print(date)
    }
    
}
