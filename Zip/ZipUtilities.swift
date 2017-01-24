//
//  ZipUtilities.swift
//  Zip
//
//  Created by Roy Marmelstein on 26/01/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

extension FileManager {
    //returns true if the url points to a directory that exists
    func isDirectory( atPath path : String ) -> Bool {
        var isDirectory: ObjCBool = false
        let _ = fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
}

internal class ZipUtilities {
    
    // File manager
    let fileManager = FileManager.default

    /**
     *  ProcessedFilePath struct
     */
    internal struct ProcessedFilePath {
        let filePathURL: URL
        let fileName: String?
        
        func filePath() -> String {
            return filePathURL.path
        }
    }
    
    //MARK: Path processing
    
    /**
    Process zip paths
    
    - parameter paths: Paths as NSURL.
    
    - returns: Array of ProcessedFilePath structs.
    */
    internal func processZipPaths(_ paths: [URL]) -> [ProcessedFilePath]{
        var processedFilePaths = [ProcessedFilePath]()
        for path in paths {
            
            if fileManager.isDirectory( atPath: path.path ) {
                
                let directoryContents = expandDirectoryFilePath(path)
                processedFilePaths.append(contentsOf: directoryContents)
                
            } else {
                
                let processedPath = ProcessedFilePath(filePathURL: path, fileName: path.lastPathComponent)
                processedFilePaths.append(processedPath)
                
            }
        }
        return processedFilePaths
    }
    
    
    /**
     Recursive function to expand directory contents and parse them into ProcessedFilePath structs.
     
     - parameter directory: Path of folder as NSURL.
     
     - returns: Array of ProcessedFilePath structs.
     */
    internal func expandDirectoryFilePath(_ directory: URL) -> [ProcessedFilePath] {
        
        guard let subpaths = fileManager.subpaths(atPath: directory.path) else { return [] }
        
        let processedFilePaths = subpaths.flatMap { (path:String) -> ProcessedFilePath? in
            
            guard let url = URL( string: path, relativeTo: directory ), !fileManager.isDirectory(atPath: url.path) else {
                return nil
            }
            
            let relativeURL = (directory.lastPathComponent as NSString).appendingPathComponent(path)
            
            return ProcessedFilePath(filePathURL: url, fileName: relativeURL)
        }
        return processedFilePaths
    }

}
