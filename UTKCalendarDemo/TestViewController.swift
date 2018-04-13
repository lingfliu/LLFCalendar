//
//  TestViewController.swift
//  UTKCalendarDemo
//
//  Created by UTEAMTEC on 2018/4/13.
//  Copyright © 2018年 Lingfeng Liu. All rights reserved.
//

import UIKit
import JTAppleCalendar

class TestViewController: UIViewController {

    @IBOutlet weak var modeBtn: UIButton!
    @IBOutlet  var calendarView: JTAppleCalendarView!
    let dateFormatter = DateFormatter()
    enum UTKUICalendarMode {
        case week
        case month
    }
    var calMode:UTKUICalendarMode = .week
    let calReuseId = "UTKUICalendar"
    var viewWrapper:UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup calendar spacing
        let rootFrame = self.view.frame
        
        viewWrapper = UIView(frame: CGRect(x: 0, y: 120, width: rootFrame.size.width, height: 54))
        viewWrapper.backgroundColor = UIColor.gray
        self.view.insertSubview(viewWrapper, at: 0)
    }

   var calFoldDepth = 1
    var runonce = false
    @IBAction func switchMode(_ sender: Any) {
        switch calMode {
        case.week:
            calMode = .month

            calFoldDepth = 1

            if !runonce {
//                runonce = true
                 viewWrapper.transform = CGAffineTransform.identity
                 self.viewWrapper.frame = CGRect(x:0,y:120,width:self.viewWrapper.frame.width,height:54*3)
                
            }
            self.viewWrapper.transform = CGAffineTransform(translationX: 0, y: 0-CGFloat(self.calFoldDepth*54))
            
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.8, animations: {
                self.view.layoutIfNeeded()
                self.viewWrapper.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion:{ (finished) in
                print("frame = ", self.viewWrapper.frame)
            })

            
            
            
            
            break
        case.month:
            calMode = .week
            UIView.animate(withDuration: 0.8, animations: {
                self.viewWrapper.transform = CGAffineTransform(translationX: 0, y: 0-CGFloat(self.calFoldDepth*54))
            }, completion: { (finished) in

//                self.viewWrapper.frame = CGRect(x:0,y:120,width:self.viewWrapper.frame.width,height:54)
//                self.viewWrapper.transform = CGAffineTransform(translationX: 0, y: 0-CGFloat(self.calFoldDepth*54))
                
                print("frame week = ", self.viewWrapper.frame)
            })
            break
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
