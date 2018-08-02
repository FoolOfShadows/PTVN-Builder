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
    var saveLocation = "Desktop"
    var ptVisitDate = 0
    var visitTime = "00"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func finishCreatingPTVN(_ sender: AnyObject) {
        //Get note med data
        //Get the clipboard to process
        let pasteBoard = NSPasteboard.general
        guard let theText = pasteBoard.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) else { return }
        var newMeds = theText.simpleRegExMatch(ChartData.Regexes.newMeds.rawValue).cleanTheTextOf(newMedsBadBits)
        newMeds = newMeds.replaceRegexPattern("(?m)\nEncounter Comments:\n", with: "Sig: ")
        //Process note med data and replace existing med data
        let noteArray = newMeds.convertListToArray()
        var results = [String]()
        var summary = currentData.currentMeds
        summary = summary.replaceRegexPattern("Start: \\d\\d/\\d\\d/\\d\\d", with: "")
        //summary = summary.replaceRegexPattern("Show historical \\(\\d.\\)", with: "")
        let summaryArray = summary.cleanTheTextOf(["- "]).convertListToArray()
        for summaryItem in summaryArray {
            var matched = false
            innerLoop: for noteItem in noteArray {
                if noteItem.contains(summaryItem) {
                    results.append(noteItem)
                    matched = true
                    break innerLoop
                }
            }
            if matched == false {
                results.append(summaryItem)
            }
        }
        let filteredArray = noteArray.filter{ !results.contains($0) }
        results += filteredArray
        var finalMedList = currentData.currentMeds
        if !results.isEmpty {
            finalMedList = results.joined(separator: "\n").addCharacterToBeginningOfEachLine("-")
        }
        
        
        //Finish creating note
        //Get current date and format it
        let theCurrentDate = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        
        //Set the visit date
        guard let visitDate = theCurrentDate.addingDays(ptVisitDate) else { return }
        print("Days out: \(ptVisitDate)")
        let internalVisitDate = formatter.string(from: visitDate)
        let labelDateFormatter = DateFormatter()
        labelDateFormatter.dateFormat = "yyMMdd"
        let labelVisitDate = labelDateFormatter.string(from: visitDate)
        
        //Search for PTVN from last visit
        //Set the search directory to the PTVN folder
        let originFolderURL = URL(fileURLWithPath: "\(NSHomeDirectory())/WPCMSharedFiles/zDonna Review/01 PTVN Files")
        //Search for files with the same visit date
        let ptvnList = originFolderURL.getFilesInDirectoryWhereNameContains(["\(currentData.lastAppointment)"])
        //Create a the smallest likely unique version of the pt name
        //to search with
        let filterName = getFileLabellingNameFrom(currentData.ptName, ofType: FileLabelType.firstLast)
        //Use that search name to filter the PTVNs whose date matched
        let shortList = ptvnList.filter { $0.absoluteString.removingPercentEncoding!.contains(filterName) }
        //Create an OldNoteData object from the text of the matching file
        //and pull out just the charge information to be inserted into
        //the saved file
        var lastCharge = "Last PTVN not found."
        var pharmacy = String()
        if shortList.count > 0 {
            lastCharge = OldNoteData(fileURL: shortList[0]).oldAssessment
            pharmacy = OldNoteData(fileURL: shortList[0]).pharmacy
        }
        
        
        let finalResults = """
        #PTVNFILE#
        \(SectionDelimiters.planStart.rawValue)
        
        \(SectionDelimiters.planEnd.rawValue)
        
        \(SectionDelimiters.pharmacyStart.rawValue)
        \(pharmacy)
        \(SectionDelimiters.pharmacyEnd.rawValue)
        
        \(SectionDelimiters.assessmentStart.rawValue)
        
        \(SectionDelimiters.assessmentEND.rawValue)
        
        \(SectionDelimiters.objectiveStart.rawValue)
        
        \(SectionDelimiters.objectiveEnd.rawValue)
        
        \(SectionDelimiters.ccStart.rawValue)
        
        \(SectionDelimiters.ccEnd.rawValue)
        
        \(SectionDelimiters.subjectiveStart.rawValue)
        Problems**
        \(lastCharge)
        *problems*
        \(SectionDelimiters.subjectiveEnd.rawValue)
        
        \(SectionDelimiters.rosStart.rawValue)
        
        \(SectionDelimiters.rosEnd.rawValue)
        
        \(SectionDelimiters.medStart.rawValue)
        \(finalMedList)
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
        """
        
        
        //finalResults.copyToPasteboard()
        //Generate a properly formated name for the file from exisiting data
        let fileName = "\(visitTime) \(getFileLabellingNameFrom(currentData.ptName, ofType: FileLabelType.full)) PTVN \(labelVisitDate).txt"
        
        //Creates a file with the final output to the chosen location
        let ptvnData = finalResults.data(using: String.Encoding.utf8)
        let newFileManager = FileManager.default
        let savePath = NSHomeDirectory()
        newFileManager.createFile(atPath: "\(savePath)/\(saveLocation)/\(fileName)", contents: ptvnData, attributes: nil)
        
        self.dismiss(self)
    }
    
}

//The delimiters used to separate the data sections in the file
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
    case pharmacyStart = "#PHARMACY"
    case pharmacyEnd = "PHARMACY#"
    case otherStart = "#OTHER"
    case otherEnd = "OTHER#"
}
