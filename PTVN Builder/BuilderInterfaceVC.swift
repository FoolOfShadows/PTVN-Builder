//
//  BuilderInterfaceVC.swift
//  PTVN Builder
//
//  Created by Fool on 3/13/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Cocoa

class BuilderInterfaceVC: NSViewController {

    @IBOutlet weak var visitTimeView: NSTextField!
    @IBOutlet weak var visitDayView: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    @IBAction func processButton(_ sender: AnyObject) {
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
        let currentData = ChartData(chartData: theText)
        
        //Get the info from the date scheduled popup menu
        let ptVisitDate = visitDayView.indexOfSelectedItem
        
        //Where to save the file
        var saveLocation = "Desktop"
        switch ptVisitDate {
        case 0:
            saveLocation = "WPCMSharedFiles/zDoctor Review/06 Dummy Files"
        case 1...4:
            saveLocation = "WPCMSharedFiles/zruss Review/Tomorrows Files"
        default:
            saveLocation = "Desktop"
        }
        
        //Get current date and format it
        let theCurrentDate = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        
        //Get the visit date
        guard let visitDate = theCurrentDate.addingDays(ptVisitDate) else { return }
        let internalVisitDate = formatter.string(from: visitDate)
        let labelDateFormatter = DateFormatter()
        labelDateFormatter.dateFormat = "yyMMdd"
        let labelVisitDate = labelDateFormatter.string(from: visitDate)
        
        let finalResults = "\(currentData.ptName)\nDOB:  \(currentData.ptDOB)     Age: \(currentData.ptAge)\nDate: \(internalVisitDate)\n\n\(visitBoilerplateText)CURRENT MEDICATIONS:\n\(medKey)\(currentData.currentMeds)\n\nALLERGIES:\n\(currentData.allergies)\n\nPREVENTIVE CARE:\n\(currentData.preventiveCare)\n\nPAST MEDICAL HISTORY:\n\(currentData.pmh)\n\nPAST SURGICAL HISTORY:\n\(currentData.psh)\n\nNUTRITION:\n\(currentData.nutritionalHistory)\n\nSOCIAL HISTORY:\n\(currentData.socialHistory)\n\nFAMILY HISTORY:\n\(currentData.familyHistory)\n\nDIAGNOSES:\n\(currentData.diagnoses)"
        
        //print(currentData.diagnoses)
        finalResults.copyToPasteboard()
        
        let fileName = "\(visitTimeView.stringValue) \(getFileLabellingName(currentData.ptName)) PTVN \(labelVisitDate).txt"
        //print(fileName)
        //Creates a file with the final output on the desktop
        let ptvnData = finalResults.data(using: String.Encoding.utf8)
        let newFileManager = FileManager.default
        let savePath = NSHomeDirectory()
        newFileManager.createFile(atPath: "\(savePath)/\(saveLocation)/\(fileName)", contents: ptvnData, attributes: nil)
    }

}
