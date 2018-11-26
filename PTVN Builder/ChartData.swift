//
//  ChartData.swift
//  PTVN Builder
//
//  Created by Fool on 3/13/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Foundation

//Struct to hold the data from the file
struct ChartData {
    //This string will be populated later with data on the clipboard pulled from PF
    var chartData = String()
    
    
    //Use closures to populate the relevant vars with the desired data copied from PF
    var ptName: String {return nameAgeDOB(chartData).0}
    var ptDOB: String {return nameAgeDOB(chartData).2}
    var ptAge: String {return nameAgeDOB(chartData).1}
    var currentMeds: String {return chartData.simpleRegExMatch(Regexes.medications.rawValue).cleanTheTextOf(medBadBits).addCharacterToBeginningOfEachLine("-")}
    var diagnoses: String {return chartData.simpleRegExMatch(Regexes.diagnoses.rawValue).cleanTheTextOf(dxBadBits)}
    var allergies: String {return chartData.simpleRegExMatch(Regexes.allergies.rawValue).cleanTheTextOf(basicAllergyBadBits)}
    var nutritionalHistory: String { var theRegex = ""
                                    if chartData.contains("Developmental history") {
                                    theRegex = Regexes.nutrition1.rawValue
                                        //print("Found Dev Hx")
                                    } else { theRegex = Regexes.nutrition2.rawValue}
                                    return chartData.simpleRegExMatch(theRegex).cleanTheTextOf(nutritionBadBits)}
    var socialHistory: String {return chartData.simpleRegExMatch(Regexes.social.rawValue).cleanTheTextOf(socialBadBits)}
    var familyHistory: String {return chartData.simpleRegExMatch(Regexes.family1.rawValue).cleanTheTextOf(fmhBadBits)}
    var preventiveCare: String {return chartData.simpleRegExMatch(Regexes.preventive.rawValue).cleanTheTextOf(preventiveBadBits)}
    var psh: String {return chartData.simpleRegExMatch(Regexes.psh.rawValue).cleanTheTextOf(pshBadBits)}
    var pmh: String {return chartData.simpleRegExMatch(Regexes.pmh.rawValue).cleanTheTextOf(pmhBadBits)}
    var lastCharges: String {return chartData.simpleRegExMatch(Regexes.lastCharge.rawValue).cleanTheTextOf(lastChargeBadBits)}
    var lastAppointment:String {return getLastAptInfoFrom(chartData)}
    
    //The regular expressions used to define the desired sections of the text
    enum Regexes:String {
        case social = "(?s)(Social history).*((?<=)Nutrition history)"/*"(?s)(Social history).*((?<=)Past medical history)"*/
        case family1 = "(?s)(Family health history).*(Past medical history)"/*"(?s)(Family health history).*(Preventive care)"*/
        case family2 = "(?s)(Family health history).*(Social history)"
        case nutrition1 = "(?s)(Nutrition history).*((?<=)Family health history)"/*"(?s)(Nutrition history).*((?<=)Developmental history)"*/
        case nutrition2 = "(?s)(Nutrition history).*((?<=)Allergies\\n)"
        case diagnoses = "(?s)Diagnoses.*Social\\shistory(?!\\s\\(free\\stext\\))"/*"(?s)Diagnoses.*Social history*?\\s(?=\\nSmoking status*?\\s)"*/
        case medications = "(?s)\\nMedications*\\s+?\\n.*Screenings/ Interventions" /*"(?s)\\nMedications*\\s+?\\n.*Encounters"*/
        case allergies = "(?s)Developmental history\\n.*(\\nMedications)" /*"(?s)(\\nAllergies\\n).*(\\nMedications)"*/
        case pmh = "(?s)(Ongoing medical problems).*(Preventive care)" /*"(?s)(Ongoing medical problems).*(Family health history)"*/
        case psh = "(?s)(Major events).*(Ongoing medical problems)"
        case preventive = "(?s)(Preventive care).*Developmental history" /*"(?s)(Preventive care).*((?<=)Social history)"*/
        case lastCharge = "(?s)(A\\(Charge\\):).*(Lvl.*\\(done dmw\\))"
        case pharmacy = "(?s)#PHARMACY.*PHARMACY#"
        case newMeds = "(?s)Medications attached to this encounter:.*Orders Print"
        case oldWeight = "Wt:.*lb;\\s*Ht:"
    }
    
    //Get the name, age, and DOB from the text
   private func nameAgeDOB(_ theText: String) -> (String, String, String){
        var ptName = ""
        var ptAge = ""
        var ptDOB = ""
        let theSplitText = theText.components(separatedBy: "\n")
        
        var lineCount = 0
        if !theSplitText.isEmpty {
            for currentLine in theSplitText {
                if currentLine.range(of: "PRN: ") != nil {
                    let ageLine = theSplitText[lineCount + 1]
                    ptName = theSplitText[lineCount - 1]
                    ptAge = ageLine.simpleRegExMatch("^\\d*")
                } else if currentLine.hasPrefix("DOB: "){
                    let dobLine = currentLine
                    ptDOB = dobLine.simpleRegExMatch("\\d./\\d./\\d*")
                }
                lineCount += 1
            }
        }
        return (ptName, ptAge, ptDOB)
    }
    
    //Clean extraneous text from the sections
    private func cleanTheSections(_ theSection:String, badBits:[String]) -> String {
        //var cleanedText = theSection.removeWhiteSpace()
        let textArray = theSection.split(separator: "\n")
        //print(textArray)
        var cleanedText = textArray.filter {$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != ""}.joined(separator: "\n")
        
        for theBit in badBits {
            cleanedText = cleanedText.replacingOccurrences(of: theBit, with: "")
        }
        cleanedText = cleanedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return cleanedText
    }
    
    //Get the date of the patients last appointment
    private func getLastAptInfoFrom(_ theText: String) -> String {
        guard let baseSection = theText.findRegexMatchFrom("Encounters", to: "Appointments") else {return ""}
        //print(baseSection)
        guard let encountersSection = baseSection.findRegexMatchBetween("Encounters", and: "Messages") else {return ""}
        //print(encountersSection)
        let dateToDateRegex = "(?s)(\\d./\\d./\\d*)(.*?)(\\n)(?=\\d./\\d./\\d*)"
        let dateToEndOfCCLine = "(?m)(\\d./\\d./\\d*)(.*?)(\\n)(CC:.*)"
        let activeEncounters = encountersSection.ranges(of: dateToEndOfCCLine, options: .regularExpression).map{encountersSection[$0]}.map{String($0)}.filter {!$0.contains("No chief complaint recorded") && !$0.contains("CC: Epogen inj") && !$0.contains("CC: Testosterone inj") && !$0.contains("CC: Flu inj")}
        print(activeEncounters)
        if activeEncounters.count > 0 {
            let date = activeEncounters[0].simpleRegExMatch("\\d./\\d./\\d*")
            let components = date.components(separatedBy: "/")
            let month = components[0]
            let day = components[1]
            let year = components[2].suffix(2)
            return "\(year)\(month)\(day)"
        } else {
            return "Last apt not found"
        }
    }
}

//A struct to get and hold the assessment data from the patient last note
struct OldNoteData {
    var fileURL:URL
    private var theText:String { return fileURL.getTextFromFile() }
    private let lastChargeOld = "(?s)(A\\(Charge\\):).*(Lvl.*\\(done dmw\\))"
    private let lastChargeNew = "(?s)#ASSESSMENT.*ASSESSMENT#"
    //private let lastChargeNew = "(?s)(Problems\\*\\*).*(\\*problems\\*)"
    var pharmacy:String { return theText.simpleRegExMatch(ChartData.Regexes.pharmacy.rawValue).cleanTheTextOf(["#PHARMACY", "PHARMACY#"])}
    var oldAssessment:String {
        var problem = String()
        if theText.contains("#PTVNFILE#") {
            problem = theText.simpleRegExMatch(lastChargeNew).cleanTheTextOf(lastChargeBadBits)
//            let levelBit = problem.simpleRegExMatch("Lvl.*\\(done dmw\\)")
//            problem = problem.replacingOccurrences(of: levelBit, with: "")
        } else {
        problem = theText.simpleRegExMatch(lastChargeOld).cleanTheTextOf(lastChargeBadBits)
//        let levelBit = problem.simpleRegExMatch("Lvl.*\\(done dmw\\)")
//        problem = problem.replacingOccurrences(of: levelBit, with: "")
        }
        let levelBit = problem.simpleRegExMatch("(?s)Lvl.*\\(done dmw\\)")
        problem = problem.replacingOccurrences(of: levelBit, with: "")
        problem = problem.cleanTheTextOf(lastChargeBadBits)
        return problem
    }
    var lastWeight:String { return theText.simpleRegExMatch(ChartData.Regexes.oldWeight.rawValue).cleanTheTextOf(["Wt:", "lb;", "Ht:"])}
}

//Choices to pass into the getFileLabellingNameFrom function
//for how you want the name returned
enum FileLabelType {
    case full
    case firstLast
}

//Using the name line from the PTVN, break it into it's components
//then return it in the format requested per the FileLabelType enum
func getFileLabellingNameFrom(_ name: String, ofType type: FileLabelType) -> String {
    var fileLabellingName = String()
    var ptFirstName = ""
    var ptLastName = ""
    var ptMiddleName = ""
    var ptExtraName = ""
    let extraNameBits = ["Sr", "Jr", "II", "III", "IV", "MD"]
    
    func checkForMatchInSets(_ arrayToCheckIn: [String], arrayToCheckFor: [String]) -> Bool {
        var result = false
        for item in arrayToCheckIn {
            if arrayToCheckFor.contains(item) {
                result = true
                break
            }
        }
        return result
    }
    
    let nameComponents = name.components(separatedBy: " ")
    
    let extraBitsCheck = checkForMatchInSets(nameComponents, arrayToCheckFor: extraNameBits)
    
    if extraBitsCheck == true {
        ptLastName = nameComponents[nameComponents.count-2]
        ptExtraName = nameComponents[nameComponents.count-1]
    } else {
        ptLastName = nameComponents[nameComponents.count-1]
        ptExtraName = ""
    }
    
    if nameComponents.count > 2 {
        if nameComponents[nameComponents.count - 2] == "Van" {
            ptLastName = "Van " + ptLastName
        }
    }
    
    //Get first name
    ptFirstName = nameComponents[0]
    
    //Get middle name
    if (nameComponents.count == 3 && extraBitsCheck == true) || nameComponents.count < 3 {
        ptMiddleName = ""
    } else {
        ptMiddleName = nameComponents[1]
    }
    if type == FileLabelType.full {
    fileLabellingName = "\(ptLastName)\(ptFirstName)\(ptMiddleName)\(ptExtraName)"
    } else if type == FileLabelType.firstLast {
        fileLabellingName = "\(ptLastName)\(ptFirstName)"
    }
    let badNameBits = [" ", "-", "'", "(", ")", "\""]
    for bit in badNameBits {
        fileLabellingName = fileLabellingName.replacingOccurrences(of: bit, with: "")
    }
    
    return fileLabellingName
}

