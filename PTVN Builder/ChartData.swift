//
//  ChartData.swift
//  PTVN Builder
//
//  Created by Fool on 3/13/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Foundation

struct ChartData {
    var chartData = String()
    var ptName: String {return nameAgeDOB(chartData).0}
    var ptDOB: String {return nameAgeDOB(chartData).2}
    var ptAge: String {return nameAgeDOB(chartData).1}
    //var fileName: String {return ""}
    var currentMeds: String {return chartData.simpleRegExMatch(Regexes.medications.rawValue).cleanTheTextOf(medBadBits).addCharacterToBeginningOfEachLine("- ")}
    var diagnoses: String {return chartData.simpleRegExMatch(Regexes.diagnoses.rawValue).cleanTheTextOf(dxBadBits)}
    var allergies: String {return chartData.simpleRegExMatch(Regexes.allergies.rawValue).cleanTheTextOf(basicAllergyBadBits)}
    var nutritionalHistory: String { var theRegex = ""
                                    if chartData.contains("Developmental history") {
                                    theRegex = Regexes.nutrition1.rawValue
                                        print("Found Dev Hx")
                                    } else { theRegex = Regexes.nutrition2.rawValue}
                                    return chartData.simpleRegExMatch(theRegex).cleanTheTextOf(nutritionBadBits)}
    var socialHistory: String {return chartData.simpleRegExMatch(Regexes.social.rawValue).cleanTheTextOf(socialBadBits)}
    var familyHistory: String {return chartData.simpleRegExMatch(Regexes.family1.rawValue).cleanTheTextOf(fmhBadBits)}
    var preventiveCare: String {return chartData.simpleRegExMatch(Regexes.preventive.rawValue).cleanTheTextOf(preventiveBadBits)}
    var psh: String {return chartData.simpleRegExMatch(Regexes.psh.rawValue).cleanTheTextOf(pshBadBits)}
    var pmh: String {return chartData.simpleRegExMatch(Regexes.pmh.rawValue).cleanTheTextOf(pmhBadBits)}
    
    enum Regexes:String {
        case social = "(?s)(Social history).*((?<=)Past medical history)"
        case family1 = "(?s)(Family health history).*(Preventive care)"
        case family2 = "(?s)(Family health history).*(Social history)"
        case nutrition1 = "(?s)(Nutrition history).*((?<=)Developmental history)"
        case nutrition2 = "(?s)(Nutrition history).*((?<=)Allergies\\n)"
        case diagnoses = "(?s)Diagnoses.*Social history*?\\s(?=\\nSmoking status*?\\s)"
        case medications = "(?s)\\nMedications*\\s+?\\n.*Encounters"
        case allergies = "(?s)(\\nAllergies\\n).*(\\nMedications)"
        case pmh = "(?s)(Ongoing medical problems).*(Family health history)"
        case psh = "(?s)(Major events).*(Ongoing medical problems)"
        case preventive = "(?s)(Preventive care).*((?<=)Social history)"
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
}

//Parse a string containing a full name into it's components and returns
//the version of the name we use to label files
func getFileLabellingName(_ name: String) -> String {
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
    
    fileLabellingName = "\(ptLastName)\(ptFirstName)\(ptMiddleName)\(ptExtraName)"
    let badNameBits = [" ", "-", "'", "(", ")", "\""]
    for bit in badNameBits {
        fileLabellingName = fileLabellingName.replacingOccurrences(of: bit, with: "")
    }
    
    return fileLabellingName
}
