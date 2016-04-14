//
//  DailyDappStartTimeVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/14/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class DailyDappStartTimeVC: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initDatePicker()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - @IBActions
    
    @IBAction func save(sender: AnyObject) {
        let dailyDappStartTime = self.time()
        
        LocalStorage.saveDailyDappStartTime(dailyDappStartTime)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: -
    
    private func initDatePicker() {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "HH:mm"
        
        if let dailyDappStartTime = LocalStorage.dailyDappStartTime() {
            let (hour, minute) = dailyDappStartTime
            let dateString = "\(hour):\(minute)"
            
            if let date = dateFormatter.dateFromString(dateString) {
                self.datePicker.date = date
            }
        }
    }
    
    private func time() -> Time {
        let currentCalendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [.Hour, .Minute]
        let components = currentCalendar.components(unitFlags, fromDate: self.datePicker.date)
        let time = (components.hour, components.minute)
        
        return time
    }
}
