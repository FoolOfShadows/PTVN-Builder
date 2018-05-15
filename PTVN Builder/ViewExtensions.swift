//
//  ViewExtensions.swift
//  PTVN Builder
//
//  Created by Fool on 5/15/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Cocoa

extension NSView {
    func clearControllers() {
        func clearChecksTextfields(theView: NSView) {
            for item in theView.subviews {
                if item is NSButton {
                    let checkbox = item as? NSButton
                    if (checkbox?.isEnabled)! {
                        checkbox?.state = .off
                    }
                } else if item is NSTextField {
                    let textfield = item as? NSTextField
                    if (textfield?.isEditable)!{
                        textfield?.stringValue = ""
                    }
                } else if item is NSMatrix {
                    let matrix = item as? NSMatrix
                    matrix?.deselectAllCells()
                } else if item is NSTextView {
                    let textView = item as? NSTextView
                    if (textView?.isEditable)! {
                        textView?.string = ""
                    }
                } else {
                    clearChecksTextfields(theView: item)
                }
            }
        }
        clearChecksTextfields(theView: self)
    }
    
    //Populates the choices of the comboboxes and popup buttons in a view based on matching
    //the items tag with a switching function in the selected struct
    func populateSelectionsInViewUsing(_ theStruct: PopulateComboBoxProtocol) {
        for item in self.subviews {
            if let isCombobox = item as? NSComboBox {
                if let selections = theStruct.matchValuesFrom(isCombobox.tag) {
                    isCombobox.removeAllItems()
                    isCombobox.addItems(withObjectValues: selections)
                    isCombobox.selectItem(at: 0)
                    isCombobox.completes = true
                }
            } else if let isPopup = item as? NSPopUpButton {
                if let selections = theStruct.matchValuesFrom(isPopup.tag) {
                    isPopup.removeAllItems()
                    isPopup.addItems(withTitles: selections)
                    isPopup.selectItem(at: 0)
                }
            } else {
                item.populateSelectionsInViewUsing(theStruct)
            }
        }
        
    }
    
    func makeButtonsInViewInactive() {
        for item in self.subviews {
            if let isButton = item as? NSButton {
                isButton.state = .off
                isButton.isEnabled = false
            } else {
                item.makeButtonsInViewInactive()
            }
        }
    }
    
    func makeButtonsInViewActive() {
        for item in self.subviews {
            if let isButton = item as? NSButton {
                isButton.isEnabled = true
            } else {
                item.makeButtonsInViewActive()
            }
        }
    }
    
    func getButtonsInView() -> [NSButton] {
        var results = [NSButton]()
        for item in self.subviews {
            if let button = item as? NSButton {
                results.append(button)
            } else {
                results += item.getButtonsInView()
            }
        }
        return results
    }
    
    func getNormalButtonsInView() -> [NSButton] {
        var results = [NSButton]()
        for item in self.subviews {
            if let button = item as? NSButton, button.title == "N:"{
                results.append(item as! NSButton)
            } else {
                results += item.getNormalButtonsInView()
            }
        }
        return results
    }
    
    
    func getComboBoxesInView() -> [NSComboBox] {
        var results = [NSComboBox]()
        for item in self.subviews {
            if let box = item as? NSComboBox {
                results.append(box)
            } else {
                results += item.getComboBoxesInView()
            }
        }
        return results
    }
    
    func getContainingBox() -> NSBox? {
        var theView:NSView?
        
        if self is NSBox {
            return self as? NSBox
        } else {
            theView = self.superview?.getContainingBox()
        }
        
        return theView as? NSBox
    }
}
