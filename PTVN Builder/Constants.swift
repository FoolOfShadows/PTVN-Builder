//
//  Constants.swift
//  PTVN Builder
//
//  Created by Fool on 2/1/16.
//  Copyright © 2016 Fulgent Wake. All rights reserved.
//

import Foundation

let dxBadBits = ["Chronic diagnoses", "No active Acute diagnoses.", "Acute diagnoses", "Diagnoses", "Social history", "Term", "Show by", "ICD-10"]

let medBadBits = ["Medications", "Encounters", " Show historical"]

let nutritionBadBits = ["Nutrition history", "Advanced directives", "Developmental history"]

let socialBadBits = ["Past medical history", "Social history \\(free text\\)", "Social history", "Smoking status", "Gender identity", "No gender identity recorded", "Sexual orientation", "No sexual orientation recorded"]

let fmhBadBits = ["Family health history", "Preventive care", "Social history"]

let basicAllergyBadBits = ["Drug allergies", "Environmental allergies", "No environmental allergies recorded", "Food allergies", "Allergies\\n", "Medications(\\s{2,}|\\n|$)", "You have previously recorded allergies in a free-text note", "To receive interaction alerts, record the note in a structured format here. Record",  "\\(free-text note\\) Delete", "Environmental Allergies: No Known Environmental Allergies"]

let freeAllergyBadBits = ["Allergies \\(free text\\)", "ALLERGIES:", "ALLERGIES", "Use structured allergies to receive interaction alerts", "Food allergies:", "Food Allergies:", "Food Allergies", "Food allergies", "Food Allergies", "Environmental allergies:", "Environmental allergies: ", "Environmental allergies", "Environmental Allergies", "Drug allergies:", "Drug allergies-", "Drug allergies", "No Known Drug Allergies", "No Known", "Drug Allergies:", "Drug Allergies", "Family health history", "Preventive care", "No food allergies recorded\n", "Allergies"]

let preventiveBadBits = ["Preventive care", "Social history", "Advance directives"]

let pshBadBits = ["Major events", "Ongoing medical problems", "PSH:", "PHS:"]

let pmhBadBits = ["Ongoing medical problems", "Allergies \\(free text\\)", "Allergies", "PMH:", "PHM:", "Preventive care", "Family health history"]

let lastChargeBadBits = ["A\\(Charge\\):", "Problems\\*\\*", "\\*problems\\*", "#ASSESSMENT", "ASSESSMENT#"]

let visitBoilerplateText = "CC:  \nProblems:  \n\n\nS:  \n\nLocation:  \nSeverity:  \nQuality:  \nDuration:  \nTiming:  \nContext:  \nModifying factors:  \nAssociated symptoms:  \n\n\nNEW PMH:  \n\n\nA(Charge):  \n\n\nP(lan):  \n\n**Rx**  \n\n\nO(PE):  \n\n\n"

let medKey = "(- = currently taking; x = not currently taking; ? = unsure)\n"

