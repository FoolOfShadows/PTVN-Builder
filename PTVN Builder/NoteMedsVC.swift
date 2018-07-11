//
//  NoteMedsVC.swift
//  PTVN Builder
//
//  Created by Fool on 7/11/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Cocoa

class NoteMedsVC: NSViewController {

    weak var currentPTVNDelegate: ptvnDelegate?
    var currentData = ChartData(chartData: "")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
