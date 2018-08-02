//
//  BuilderInterfaceVC.swift
//  PTVN Builder
//
//  Created by Fool on 3/13/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Cocoa
import Quartz

protocol ptvnDelegate: class {
    var currentData:ChartData { get set }
    var saveLocation:String { get set }
    var ptVisitDate:Int { get }
    var visitTime:String { get }
}

class BuilderInterfaceVC: NSViewController, ptvnDelegate {

    @IBOutlet weak var visitTimeView: NSTextField!
    @IBOutlet weak var visitDayView: NSPopUpButton!
    
    var saveLocation = "Desktop"
    var ptVisitDate = 0
    var currentData = ChartData(chartData: "")
    var visitTime = "00"
    
    //let previewController = QLPreviewPanel()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func processInitialData() {
        //Get the clipboard to process
        let pasteBoard = NSPasteboard.general
        guard let theText = pasteBoard.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) else { return }
        
        //Make sure the clipboard contents are from PF
        if !theText.contains("Flowsheets") {
            //Create an alert to let the user know the clipboard doesn't contain
            //the correct PF data
            print("You broke it!")
            //After notifying the user, break out of the program
            let theAlert = NSAlert()
            theAlert.messageText = "It doesn't look like you've copied the correct bits out of Practice Fusion.\nPlease try again or click the help button for complete instructions.\nIf the problem continues, please contact the administrator."
            theAlert.beginSheetModal(for: self.view.window!) { (NSModalResponse) -> Void in
                let returnCode = NSModalResponse
                print(returnCode)}
        }
        
        //Make sure the diagnosis are set to ICD-10 format
        if !theText.contains("ICD-10") {
            //Create an alert to let the user know the diagnoses are not set to ICD10
            print("Not set to ICD10")
            //After notifying the user, break out of the program
            let theAlert = NSAlert()
            theAlert.messageText = "It appears Practice Fusion is not set to show ICD-10 diagnoses codes.  Please set the Show by option in the Diagnoses section to ICD-10 and try again."
            theAlert.beginSheetModal(for: self.view.window!) { (NSModalResponse) -> Void in
                _ = NSModalResponse
            }
        }
        
        //Create a ChartData struct with the clipboard data
        currentData = ChartData(chartData: theText)
        
        //Get the info from the date scheduled popup menu
        ptVisitDate = visitDayView.indexOfSelectedItem
        print("Day index selected: \(ptVisitDate)")
        
        //Set the files save location based on the users selection
        //var saveLocation = "Desktop"
        switch ptVisitDate {
        case 0:
            saveLocation = "WPCMSharedFiles/zDoctor Review/06 Dummy Files"
        case 1...4:
            saveLocation = "WPCMSharedFiles/zruss Review/Tomorrows Files"
        default:
            saveLocation = "Desktop"
        }
        
        visitTime = visitTimeView.stringValue
        
//        //Search for PTVN from last visit
//        //Set the search directory to the PTVN folder
//        let originFolderURL = URL(fileURLWithPath: "\(NSHomeDirectory())/WPCMSharedFiles/zDonna Review/01 PTVN Files")
//        //Search for files with the same visit date
//        let ptvnList = originFolderURL.getFilesInDirectoryWhereNameContains(["\(currentData.lastAppointment)"])
//        //Create a the smallest likely unique version of the pt name
//        //to search with
//        let filterName = getFileLabellingNameFrom(currentData.ptName, ofType: FileLabelType.firstLast)
//        //Use that search name to filter the PTVNs whose date matched
//        let shortList = ptvnList.filter { $0.absoluteString.removingPercentEncoding!.contains(filterName) }
//        //Create an OldNoteData object from the text of the matching file
//        //and pull out just the charge information to be inserted into
//        //the saved file
//        var lastCharge = "Last PTVN not found."
//        var pharmacy = String()
//        if shortList.count > 0 {
//            lastCharge = OldNoteData(fileURL: shortList[0]).oldAssessment
//            pharmacy = OldNoteData(fileURL: shortList[0]).pharmacy
//        }
        
    }
    
//    @IBAction func processButton(_ sender: AnyObject) {
//        //Get the clipboard to process
//        let pasteBoard = NSPasteboard.general
//        guard let theText = pasteBoard.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) else { return }
//        
//        //Make sure the clipboard contents are from PF
//        if !theText.contains("Flowsheets") {
//            //Create an alert to let the user know the clipboard doesn't contain
//            //the correct PF data
//            print("You broke it!")
//            //After notifying the user, break out of the program
//            let theAlert = NSAlert()
//            theAlert.messageText = "It doesn't look like you've copied the correct bits out of Practice Fusion.\nPlease try again or click the help button for complete instructions.\nIf the problem continues, please contact the administrator."
//            theAlert.beginSheetModal(for: self.view.window!) { (NSModalResponse) -> Void in
//                let returnCode = NSModalResponse
//                print(returnCode)}
//        }
//        
//        //Make sure the diagnosis are set to ICD-10 format
//        if !theText.contains("ICD-10") {
//            //Create an alert to let the user know the diagnoses are not set to ICD10
//            print("Not set to ICD10")
//            //After notifying the user, break out of the program
//            let theAlert = NSAlert()
//            theAlert.messageText = "It appears Practice Fusion is not set to show ICD-10 diagnoses codes.  Please set the Show by option in the Diagnoses section to ICD-10 and try again."
//            theAlert.beginSheetModal(for: self.view.window!) { (NSModalResponse) -> Void in
//                _ = NSModalResponse
//            }
//        }
//        
//        //Create a ChartData struct with the clipboard data
//        currentData = ChartData(chartData: theText)
//        
//        //Get the info from the date scheduled popup menu
//        ptVisitDate = visitDayView.indexOfSelectedItem
//        
//        //Set the files save location based on the users selection
//        var saveLocation = "Desktop"
//        switch ptVisitDate {
//        case 0:
//            saveLocation = "WPCMSharedFiles/zDoctor Review/06 Dummy Files"
//        case 1...4:
//            saveLocation = "WPCMSharedFiles/zruss Review/Tomorrows Files"
//        default:
//            saveLocation = "Desktop"
//        }
//    }
        

    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier?.rawValue == "showNoteMeds" {
            if let toViewController = segue.destinationController as? NoteMedsVC {
                processInitialData()
                toViewController.currentPTVNDelegate = self
                toViewController.currentData = currentData
                toViewController.ptVisitDate = ptVisitDate
                toViewController.saveLocation = saveLocation
                toViewController.visitTime = visitTime
            }
        }
    }

}

