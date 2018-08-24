//
//  URLExtensions.swift
//  PTVN Builder
//
//  Created by Fool on 5/15/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Cocoa

extension URL {
    func urlIntoCleanString() -> String? {
        return self.deletingPathExtension().absoluteString.removingPercentEncoding
    }
    
    func splitFileNameIntoComponents() -> [String]? {
        if let nameWithoutPercentEncoding = self.urlIntoCleanString() {
            return nameWithoutPercentEncoding.components(separatedBy: " ")
        }
        return nil
    }
    
    //Return a list of URLs for files in the directory which contain the passed in string
    func getFilesInDirectoryWhereNameContains(_ criteria:[String]) -> [URL] {
        let fileManager = FileManager.default
        var results = [URL]()
        
        let enumeratorOptions: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants]
        let theEnumerator = fileManager.enumerator(at: self, includingPropertiesForKeys: nil, options: enumeratorOptions, errorHandler: nil)
        for item in theEnumerator!.allObjects {
            //print(item)
            if let itemURL = item as? URL {
                for crit in criteria {
                    print(crit)
                    //Have to remove percent encoding to check for naming
                    //convention items with spaces on either side
                    if itemURL.absoluteString.removingPercentEncoding!.contains(crit) {
                        results.append(itemURL)
                    }
                }
            }
        }
        //print("Directory Files:\n\n\n\(results.count)\n\n\n")
        return results
    }
    
    //Try to get the data from the file and return it as a string
    func getTextFromFile() -> String {
        var results = String()
            do {
                results = try String(contentsOf: self, encoding: .utf8)
            } catch {
                print("Ended up in the CATCH clause. Failed to extract text from file \(String(describing: self.absoluteString.removingPercentEncoding))")
                results = "Failed to extract text from file \(String(describing: self.absoluteString.removingPercentEncoding))"
            }
        return results
    }
}
