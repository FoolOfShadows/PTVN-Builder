//
//  GeneralExtensions.swift
//  Labs Injections ROS
//
//  Created by Fool on 10/5/16.
//  Copyright © 2016 Fulgent Wake. All rights reserved.
//

import Cocoa

protocol StructsWithDescriptionOutput {
    func getOutputFor(_ id:Int) -> String?
}

protocol PopulateComboBoxProtocol {
	func matchValuesFrom(_ id:Int) -> [String]?
}

protocol ProcessTabProtocol {
	var selfView:NSView { get set }
	func processTab() -> String
	func clearTab(_ sender: Any)
	func selectNorms(_ sender: NSButton)
}

func getDescriptionOfItem(_ items:[(Int, String?)], fromStruct theStruct:StructsWithDescriptionOutput) -> [String]? {
    var resultsArray = [String]()
    
    for item in items {
        if var description = theStruct.getOutputFor(item.0) {
            if let itemVerbiage = item.1 {
                description = "\(description)\(itemVerbiage)"
            }
            resultsArray.append(description)
        }
    }
    
    return resultsArray
    
}

extension NSButton {
    
}


extension NSTextView {
	func addToViewsExistingText(_ text:String) {
		if !self.string.isEmpty {
			self.string += "\n\(text)"
		} else {
			self.string = text
		}
	}
}

extension NSComboBox {
    func clearComboBox(menuItems: [String]) {
        self.removeAllItems()
        self.addItems(withObjectValues: menuItems)
        self.selectItem(at: 0)
		self.completes = true
    }
}

extension NSPopUpButton {
    func clearPopUpButton(menuItems: [String]) {
        self.removeAllItems()
        self.addItems(withTitles: menuItems)
        self.selectItem(at: 0)
    }
}

func makeFirstCharacterInStringArrayUppercase(_ theArray: [String])->[String] {
    var changedArray = theArray
    var firstItem = theArray[0]
    //Added this check to avoid an error in cases where the first item in a passed array is an empty string
    if firstItem != "" {
        firstItem.replaceSubrange(firstItem.startIndex...firstItem.startIndex, with: String(firstItem[firstItem.startIndex]).uppercased())
    }
    changedArray[0] = firstItem
    return changedArray
}

func getMatricesIn(view: NSView) -> [NSMatrix] {
    var results = [NSMatrix]()
    
        for item in view.subviews {
            if let isMatrix = item as? NSMatrix {
                results.append(isMatrix)
            } else {
                results += getMatricesIn(view: item)
            }
    }
    //print("getMatricesIn: \(results)")
    return results
}

func getActiveCellsFromMatrix(_ matrix:NSMatrix) -> [Int] {
    var results = [Int]()
    for item in matrix.cells {
            if item.state == .on {
                results.append(item.tag)
        }
    }
    //print("getActiveCellsFromMatrix: \(results)")
    return results
}

func getButtonsInView(_ view:NSView) -> [NSButton] {
	var results = [NSButton]()
	for item in view.subviews {
		if let button = item as? NSButton {
			results.append(button)
		} else {
			results += getButtonsInView(item)
		}
	}
	return results
}

func getButtonsIn(view: NSView) -> [(Int, String?)]{
    var results = [(Int, String?)]()
    for item in view.subviews {
        //print(item.tag)
        if let isButton = item as? NSButton {
            //if item is NSButton {
            if isButton.state == .on {
                switch isButton {
                case is NSPopUpButton:
                    if !(isButton as! NSPopUpButton).titleOfSelectedItem!.isEmpty {
                        results.append((isButton.tag, (isButton as! NSPopUpButton).titleOfSelectedItem))
                    }
                default:
                    results.append((item.tag, nil))
                }
            } else if isButton.state == .mixed {
                results.append((item.tag + 20, nil))
            }
            //If we don't check tags here we end up with an entry for the NSBox and it's title
        } else if item is NSTextField && item.tag > 0 {
            if (item as! NSTextField).stringValue != "" {
                results.append((item.tag, (item as! NSTextField).stringValue))
            }
        } else {
            results += getButtonsIn(view: item)
        }
    }
    return results.sorted(by: {$0.0 < $1.0})
}

func getActiveButtonInfoIn(view: NSView) -> [(Int, String?)]{
    var results = [(Int, String?)]()
    for item in view.subviews {
        //print(item.tag)
        if let isButton = item as? NSButton {
            //if item is NSButton {
            if isButton.state == .on {
                switch isButton {
                case is NSPopUpButton:
                    if !(isButton as! NSPopUpButton).titleOfSelectedItem!.isEmpty {
                        results.append((isButton.tag, (isButton as! NSPopUpButton).titleOfSelectedItem))
                    }
                default:
                    results.append((isButton.tag, isButton.title))
                }
            } else if isButton.state == .mixed {
                results.append((isButton.tag + 30, isButton.title))
            }
            //If we don't check tags here we end up with an entry for the NSBox and it's title
        } else if item is NSTextField && item.tag > 0 {
            if (item as! NSTextField).stringValue != "" {
                results.append((item.tag, (item as! NSTextField).stringValue))
            }
        } else {
            results += getActiveButtonInfoIn(view: item)
        }
    }
    return results.sorted(by: {$0.0 < $1.0})
}

func getStringsForButtonsIn(view: NSView) -> [String]{
    var results = [String]()
    for item in view.subviews {
        //print(item.tag)
        if let isButton = item as? NSButton {
            //if item is NSButton {
            if isButton.state == .on {
                switch isButton {
                case is NSPopUpButton:
                    if !(isButton as! NSPopUpButton).titleOfSelectedItem!.isEmpty {
                        results.append((isButton as! NSPopUpButton).titleOfSelectedItem!.lowercased())
                    }
                default:
                    results.append(isButton.title.lowercased())
                }
            }
            //If we don't check tags here we end up with an entry for the NSBox and it's title
        } else if item is NSTextField && item.tag > 0 {
            if (item as! NSTextField).stringValue != "" {
                results.append((item as! NSTextField).stringValue)
            }
        } else {
            results += getStringsForButtonsIn(view: item)
        }
    }
    return results
}

func processAndContinue() {
	let apps = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.TextEdit")
	if let mainAPP = apps.first {
		mainAPP.activate(options: .activateIgnoringOtherApps)
	}
}

func turnButtons(_ buttons:[NSButton], InRange range:[Int], ToState state:NSButton.StateValue) {
	for button in buttons {
		if range.contains(button.tag) {
			button.state = state
		}
	}
}

extension Date {
    func addingDays(_ daysToAdd: Int) -> Date? {
        var components = DateComponents()
        components.setValue(daysToAdd, for: .day)
        let newDate = Calendar.current.date(byAdding: components, to: self)
        return newDate
    }
}


