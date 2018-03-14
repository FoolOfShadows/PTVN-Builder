//
//  DateExtensions.swift
//  PTVN Builder
//
//  Created by Fool on 3/13/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Cocoa

extension Date {
    func addingDays(_ daysToAdd: Int) -> Date? {
        var components = DateComponents()
        components.setValue(daysToAdd, for: .day)
        let newDate = Calendar.current.date(byAdding: components, to: self)
        return newDate
    }
}
