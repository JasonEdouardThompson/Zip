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
//changes the name of the file to something different before it is placed
//into the zip, or returns nil if we are to ignore the file
public typealias FileNameTransform = (String) -> String?

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
    
    private func apply( fileNameTransform: FileNameTransform?, to fileName: String ) -> String? {
        
        guard let ft = fileNameTransform else {
            return fileName
        }
        
        return ft(fileName)
    }
    
    //MARK: Path processing
    
    /**
     Process zip paths
     
     - parameter paths: Paths as NSURL.
     - parameter fileNameTransform: transforms filenames before they are stored in the zip.
     
     - returns: Array of ProcessedFilePath structs.
     */
    internal func processZipPaths(_ paths: [URL], fileNameTransform : FileNameTransform? = nil ) -> [ProcessedFilePath]{
        var processedFilePaths = [ProcessedFilePath]()
        for path in paths {
            
            if fileManager.isDirectory( atPath: path.path ) {
                
                let directoryContents = expandDirectoryFilePath(path, fileNameTransform: fileNameTransform)
                processedFilePaths.append(contentsOf: directoryContents)
                
            } else {
                
                guard let fileName = apply( fileNameTransform: fileNameTransform, to: path.path ) else {
                    continue
                }
                
                let processedPath = ProcessedFilePath(filePathURL: path, fileName: fileName )
                processedFilePaths.append(processedPath)
                
            }
        }
        return processedFilePaths
    }
    
    
    /**
     Recursive function to expand directory contents and parse them into ProcessedFilePath structs.
     
     - parameter directory: Path of folder as NSURL.
     - parameter fileNameTransform: transforms filenames before they are stored in the zip.
     
     - returns: Array of ProcessedFilePath structs.
     */
    internal func expandDirectoryFilePath(_ directory: URL, fileNameTransform : FileNameTransform?) -> [ProcessedFilePath] {
        
        guard let subpaths = fileManager.subpaths(atPath: directory.path) else { return [] }
        
        let processedFilePaths = subpaths.flatMap { (path:String) -> ProcessedFilePath? in
            
            guard let url = URL( string: path, relativeTo: directory ), !fileManager.isDirectory(atPath: url.path) else {
                return nil
            }
            
            let relativeURL = (directory.lastPathComponent as NSString).appendingPathComponent(path)
            
            guard let fileName = apply( fileNameTransform: fileNameTransform, to: relativeURL ) else {
                return nil
            }
            
            return ProcessedFilePath(filePathURL: url, fileName: fileName)
        }
        return processedFilePaths
    }

}
