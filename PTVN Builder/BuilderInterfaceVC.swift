//
//  BuilderInterfaceVC.swift
//  PTVN Builder
//
//  Created by Fool on 3/13/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Cocoa
import Quartz

class BuilderInterfaceVC: NSViewController {

    @IBOutlet weak var visitTimeView: NSTextField!
    @IBOutlet weak var visitDayView: NSPopUpButton!
    
    //let previewController = QLPreviewPanel()
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
        
        let finalResults = """
        \(SectionDelimiters.patientNameStart.rawValue)
        \(currentData.ptName)
        \(SectionDelimiters.patientNameEnd.rawValue)
        
        \(SectionDelimiters.patientDOBStart.rawValue)
        \(currentData.ptDOB)
        \(SectionDelimiters.patientDOBEnd.rawValue)
        
        \(SectionDelimiters.patientAgeStart.rawValue)
        \(currentData.ptAge)
        \(SectionDelimiters.patientAgeEnd.rawValue)
        
        \(SectionDelimiters.visitDateStart.rawValue)
        \(internalVisitDate)
        \(SectionDelimiters.visitDateEnd.rawValue)
        
        \(SectionDelimiters.medStart.rawValue)
        \(currentData.currentMeds)
        \(SectionDelimiters.medEnd.rawValue)
        
        \(SectionDelimiters.allergiesStart.rawValue)
        \(currentData.allergies)
        \(SectionDelimiters.allergiesEnd.rawValue)
        
        \(SectionDelimiters.preventiveStart.rawValue)
        \(currentData.preventiveCare)
        \(SectionDelimiters.preventiveEnd.rawValue)
        
        \(SectionDelimiters.pmhStart.rawValue)
        \(currentData.pmh)
        \(SectionDelimiters.pmhEnd.rawValue)
        
        \(SectionDelimiters.pshStart.rawValue)
        \(currentData.psh)
        \(SectionDelimiters.pshEnd.rawValue)
        
        \(SectionDelimiters.nutritionStart.rawValue)
        \(currentData.nutritionalHistory)
        \(SectionDelimiters.nutritionEnd.rawValue)
        
        \(SectionDelimiters.socialStart.rawValue)
        \(currentData.socialHistory)
        \(SectionDelimiters.socialEnd.rawValue)
        
        \(SectionDelimiters.familyStart.rawValue)
        \(currentData.familyHistory)
        \(SectionDelimiters.familyEnd.rawValue)
        
        \(SectionDelimiters.diagnosisStart.rawValue)
        \(currentData.diagnoses)
        \(SectionDelimiters.diagnosisEnd.rawValue)
        
        \(SectionDelimiters.rosStart.rawValue)
        
        \(SectionDelimiters.rosEnd.rawValue)
        
        \(SectionDelimiters.assessmentStart.rawValue)
        
        \(SectionDelimiters.assessmentEND.rawValue)
        
        \(SectionDelimiters.objectiveStart.rawValue)
        
        \(SectionDelimiters.objectiveEnd.rawValue)
        
        \(SectionDelimiters.subjectiveStart.rawValue)
        
        \(SectionDelimiters.subjectiveEnd.rawValue)
        
        \(SectionDelimiters.planStart.rawValue)
        
        \(SectionDelimiters.planEnd.rawValue)
        """
        
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


enum SectionDelimiters:String {
    case patientNameStart = "#PATIENTNAME"
    case patientNameEnd = "PATIENTNAME#"
    case patientDOBStart = "#PATIENTDOB"
    case patientDOBEnd = "PATIENTDOB#"
    case patientAgeStart = "#PATIENTAGE"
    case patientAgeEnd = "PATIENTAGE#"
    case ccStart = "#CC"
    case ccEnd = "CC#"
    case problemsStart = "#PROBLEMS"
    case problemEnd = "PROBLEMS#"
    case subjectiveStart = "#SUBJECTIVE"
    case subjectiveEnd = "SUBJECTIVE#"
    case newPMHStart = "#NEWPMH"
    case newPMHEnd = "NEWPMH#"
    case assessmentStart = "#ASSESSMENT"
    case assessmentEND = "ASSESSMENT#"
    case planStart = "#PLAN"
    case planEnd = "PLAN#"
    case objectiveStart = "#OBJECTIVE"
    case objectiveEnd = "OBJECTIVE#"
    case medStart = "#MEDICATIONS"
    case medEnd = "MEDICATIONS#"
    case allergiesStart = "#ALLERGIES"
    case allergiesEnd = "ALLERGIES#"
    case preventiveStart = "#PREVENTIVE"
    case preventiveEnd = "PREVENTIVE#"
    case pmhStart = "#PMH"
    case pmhEnd = "PMH#"
    case pshStart = "#PSH"
    case pshEnd = "PSH#"
    case nutritionStart = "#NUTRITION"
    case nutritionEnd = "NUTRITION#"
    case socialStart = "#SOCIAL"
    case socialEnd = "SOCIAL#"
    case familyStart = "#FAMILY"
    case familyEnd = "FAMILY#"
    case diagnosisStart = "#DIAGNOSIS"
    case diagnosisEnd = "DIAGNOSIS#"
    case rosStart = "#ROS"
    case rosEnd = "ROS#"
    case visitDateStart = "#VISITDATE"
    case visitDateEnd = "VISITDATE#"
    case otherStart = "#OTHER"
    case otherEnd = "OTHER#"
}
