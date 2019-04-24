//
//  ZipTests.swift
//  ZipTests
//
//  Created by Roy Marmelstein on 13/12/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import XCTest
@testable import Zip

class ZipTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testQuickUnzip() {
        do {
            let filePath = Bundle(for: ZipTests.self).url(forResource: "bb8", withExtension: "zip")!
            let destinationURL = try Zip.quickUnzipFile(filePath)
            let fileManager = FileManager.default
            XCTAssertTrue(fileManager.fileExists(atPath: destinationURL.path))
        }
        catch {
            XCTFail()
        }
    }
    
    func testQuickUnzipNonExistingPath() {
        do {
            let filePathURL = Bundle(for: ZipTests.self).resourcePath
            let filePath = NSURL(string:"\(filePathURL!)/bb9.zip")
            let destinationURL = try Zip.quickUnzipFile(filePath! as URL)
            let fileManager = FileManager.default
            XCTAssertFalse(fileManager.fileExists(atPath:destinationURL.path))
        }
        catch {
            XCTAssert(true)
        }
    }
    
    func testQuickUnzipNonZipPath() {
        do {
            let filePath = Bundle(for: ZipTests.self).url(forResource: "3crBXeO", withExtension: "gif")!
            let destinationURL = try Zip.quickUnzipFile(filePath)
            let fileManager = FileManager.default
            XCTAssertFalse(fileManager.fileExists(atPath:destinationURL.path))
        }
        catch {
            XCTAssert(true)
        }
    }
    
    func testQuickUnzipProgress() {
        do {
            let filePath = Bundle(for: ZipTests.self).url(forResource: "bb8", withExtension: "zip")!
            _ = try Zip.quickUnzipFile(filePath, progress: { (progress) -> () in
                XCTAssert(true)
            })
        }
        catch {
            XCTFail()
        }
    }
    
    func testQuickUnzipOnlineURL() {
        do {
            let filePath = NSURL(string: "http://www.google.com/google.zip")!
            let destinationURL = try Zip.quickUnzipFile(filePath as URL)
            let fileManager = FileManager.default
            XCTAssertFalse(fileManager.fileExists(atPath:destinationURL.path))
        }
        catch {
            XCTAssert(true)
        }
    }
    
    func testUnzip() {
        do {
            let filePath = Bundle(for: ZipTests.self).url(forResource: "bb8", withExtension: "zip")!
            let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
            
            try Zip.unzipFile(filePath, destination: documentsFolder as URL, overwrite: true, password: "password", progress: { (progress) -> () in
                print(progress)
            })
            
            let fileManager = FileManager.default
            XCTAssertTrue(fileManager.fileExists(atPath:documentsFolder.path!))
        }
        catch {
            XCTFail()
        }
    }
    
    func testUnzipDeepSubDir() {
        
        
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("testQuickUnzipSubNDir", isDirectory: true)
        
        print( temporaryDirectoryURL.path)
        let archiveURL = temporaryDirectoryURL.appendingPathComponent("archive.zip")
        let archiveOuputURL = temporaryDirectoryURL.appendingPathComponent("archive", isDirectory: true)
        
        var endDirectory = temporaryDirectoryURL
        var endDirectoryUpzipped = archiveOuputURL
        
        for i in 0..<10 {
            let subDir = "sub_dir_\(i)"
            endDirectory.appendPathComponent(subDir, isDirectory: true)
            endDirectoryUpzipped.appendPathComponent(subDir, isDirectory: true)
        }
        
        let inputTextFileURL = endDirectory.appendingPathComponent("test.txt")
        let outputTextFileURL = endDirectoryUpzipped.appendingPathComponent("test.txt")
        
        do {
            
            try FileManager.default.createDirectory(at: endDirectory, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(at: archiveOuputURL, withIntermediateDirectories: true, attributes: nil)
            
            try "test contents".write(to: inputTextFileURL, atomically: true, encoding: .utf8)
            
            try Zip.zipFiles(paths: [temporaryDirectoryURL.appendingPathComponent("sub_dir_0", isDirectory: true)], zipFilePath: archiveURL, password: nil, progress: nil )
            
            try Zip.unzipFile(archiveURL, destination: archiveOuputURL, overwrite: true, password: nil, progress: nil)
            
            XCTAssertTrue(FileManager.default.fileExists(atPath:outputTextFileURL.path))
            
            try FileManager.default.removeItem(at: temporaryDirectoryURL)
        } catch {
            XCTFail()
        }
    }
   
    func testImplicitProgressUnzip() {
        do {
            let progress = Progress()
            progress.totalUnitCount = 1
            
            let filePath = Bundle(for: ZipTests.self).url(forResource: "bb8", withExtension: "zip")!
            let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
            
            progress.becomeCurrent(withPendingUnitCount: 1)
            try Zip.unzipFile(filePath, destination: documentsFolder as URL, overwrite: true, password: "password", progress: nil)
            progress.resignCurrent()
            
            XCTAssertTrue(progress.totalUnitCount == progress.completedUnitCount)
        }
        catch {
            XCTFail()
        }
        
    }
    
    func testImplicitProgressZip() {
        do {
            let progress = Progress()
            progress.totalUnitCount = 1
            
            let imageURL1 = Bundle(for: ZipTests.self).url(forResource: "3crBXeO", withExtension: "gif")!
            let imageURL2 = Bundle(for: ZipTests.self).url(forResource: "kYkLkPf", withExtension: "gif")!
            let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
            let zipFilePath = documentsFolder.appendingPathComponent("archive.zip")
            
            progress.becomeCurrent(withPendingUnitCount: 1)
            try Zip.zipFiles(paths: [imageURL1, imageURL2], zipFilePath: zipFilePath!, password: nil, progress: nil)
            progress.resignCurrent()
            
            XCTAssertTrue(progress.totalUnitCount == progress.completedUnitCount)
        }
        catch {
            XCTFail()
        }
    }
    
    
    func testQuickZip() {
        do {
            let imageURL1 = Bundle(for: ZipTests.self).url(forResource: "3crBXeO", withExtension: "gif")!
            let imageURL2 = Bundle(for: ZipTests.self).url(forResource: "kYkLkPf", withExtension: "gif")!
            let destinationURL = try Zip.quickZipFiles([imageURL1, imageURL2], fileName: "archive")
            let fileManager = FileManager.default
            XCTAssertTrue(fileManager.fileExists(atPath:destinationURL.path))
        }
        catch {
            XCTFail()
        }
    }
    
    func testQuickZipFolder() {
        do {
            let fileManager = FileManager.default
            let imageURL1 = Bundle(for: ZipTests.self).url(forResource: "3crBXeO", withExtension: "gif")!
            let imageURL2 = Bundle(for: ZipTests.self).url(forResource: "kYkLkPf", withExtension: "gif")!
            let folderURL = Bundle(for: ZipTests.self).bundleURL.appendingPathComponent("Directory")
            let targetImageURL1 = folderURL.appendingPathComponent("3crBXeO.gif")
            let targetImageURL2 = folderURL.appendingPathComponent("kYkLkPf.gif")
            if fileManager.fileExists(atPath:folderURL.path) {
                try fileManager.removeItem(at: folderURL)
            }
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
            try fileManager.copyItem(at: imageURL1, to: targetImageURL1)
            try fileManager.copyItem(at: imageURL2, to: targetImageURL2)
            let destinationURL = try Zip.quickZipFiles([folderURL], fileName: "directory")
            XCTAssertTrue(fileManager.fileExists(atPath:destinationURL.path))
        }
        catch {
            XCTFail()
        }
    }
    
    
    func testZip() {
        do {
            let imageURL1 = Bundle(for: ZipTests.self).url(forResource: "3crBXeO", withExtension: "gif")!
            let imageURL2 = Bundle(for: ZipTests.self).url(forResource: "kYkLkPf", withExtension: "gif")!
            let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
            let zipFilePath = documentsFolder.appendingPathComponent("archive.zip")
            try Zip.zipFiles(paths: [imageURL1, imageURL2], zipFilePath: zipFilePath!, password: nil, progress: { (progress) -> () in
                print(progress)
            })
            let fileManager = FileManager.default
            XCTAssertTrue(fileManager.fileExists(atPath:(zipFilePath?.path)!))
        }
        catch {
            XCTFail()
        }
    }
    
    func testSkipFilesFromFolder() {
        
        
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("testSkipFiles", isDirectory: true)
        
        let documentDirectoryURL = temporaryDirectoryURL.appendingPathComponent("files", isDirectory: true)
        
        let archiveURL = temporaryDirectoryURL.appendingPathComponent("archive.zip")
        let archiveOuputURL = temporaryDirectoryURL.appendingPathComponent("archive", isDirectory: true)
        
        do {
            
            try FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(at: documentDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            
            try "test contents 1".write(to: documentDirectoryURL.appendingPathComponent("file1.txt"), atomically: true, encoding: .utf8)
            try "test contents 2".write(to: documentDirectoryURL.appendingPathComponent("file2.txt"), atomically: true, encoding: .utf8)
            try "test contents 3".write(to: documentDirectoryURL.appendingPathComponent("file3.txt"), atomically: true, encoding: .utf8)
            try "test contents 4".write(to: documentDirectoryURL.appendingPathComponent("file4.txt"), atomically: true, encoding: .utf8)
            
            let fileNameTransform : FileNameTransform = { a, b in a.hasSuffix("file2.txt") || a.hasSuffix("file4.txt") ? nil : a }
            
            try Zip.zipFiles(paths: [documentDirectoryURL], zipFilePath: archiveURL, fileNameTransform: fileNameTransform, password: nil, progress: nil )
            try Zip.unzipFile(archiveURL, destination: archiveOuputURL, overwrite: true, password: nil, progress: nil)
            
            XCTAssertTrue(FileManager.default.fileExists(atPath:archiveOuputURL.appendingPathComponent("files").appendingPathComponent("file1.txt").path))
            XCTAssertTrue(FileManager.default.fileExists(atPath:archiveOuputURL.appendingPathComponent("files").appendingPathComponent("file3.txt").path))
            
            XCTAssertFalse(FileManager.default.fileExists(atPath:archiveOuputURL.appendingPathComponent("files").appendingPathComponent("file2.txt").path))
            XCTAssertFalse(FileManager.default.fileExists(atPath:archiveOuputURL.appendingPathComponent("files").appendingPathComponent("file4.txt").path))
            
            try FileManager.default.removeItem(at: temporaryDirectoryURL)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testSkipFilesIndividually() {
        
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("testRenameFiles", isDirectory: true)
        
        let documentDirectoryURL = temporaryDirectoryURL.appendingPathComponent("files", isDirectory: true)
        
        let archiveURL = temporaryDirectoryURL.appendingPathComponent("archive.zip")
        let archiveOuputURL = temporaryDirectoryURL.appendingPathComponent("archive", isDirectory: true)
        
        do {
            
            try FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(at: documentDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            
            var files : [URL] = []
            
            let n = 5
            
            for i in 0..<n{
                let url = documentDirectoryURL.appendingPathComponent("file\(i)_\(i % 2 == 0 ? "keep" : "skip" ).txt")
                files.append(url)
                try "test contents \(i)".write(to: url, atomically: true, encoding: .utf8)
            }
            
            //skip even files
            let fileNameTransform : FileNameTransform = { a, b in a.hasSuffix("keep.txt") ? a : nil }
            
            try Zip.zipFiles(paths: files, zipFilePath: archiveURL, fileNameTransform: fileNameTransform, password: nil, progress: nil )
            try Zip.unzipFile(archiveURL, destination: archiveOuputURL, overwrite: true, password: nil, progress: nil)
            
            
            for i in 0..<n{
                let shouldExist = (i % 2 == 0)
                let exists = FileManager.default.fileExists(atPath:archiveOuputURL.appendingPathComponent("file\(i)_\(shouldExist ? "keep" : "skip" ).txt").path)
                XCTAssertEqual(shouldExist, exists)
            }
            
            try FileManager.default.removeItem(at: temporaryDirectoryURL)
        } catch let e {
            XCTFail("\(e)")
        }
    }


    
    func testRenameFilesFromFolder() {
        
        
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("testRenameFiles", isDirectory: true)
        
        let documentDirectoryURL = temporaryDirectoryURL.appendingPathComponent("files", isDirectory: true)
        
        let archiveURL = temporaryDirectoryURL.appendingPathComponent("archive.zip")
        let archiveOuputURL = temporaryDirectoryURL.appendingPathComponent("archive", isDirectory: true)
        
        do {
            
            try FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(at: documentDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            
            try "test contents 1".write(to: documentDirectoryURL.appendingPathComponent("file1.txt"), atomically: true, encoding: .utf8)
            try "test contents 2".write(to: documentDirectoryURL.appendingPathComponent("file2.txt"), atomically: true, encoding: .utf8)
            try "test contents 3".write(to: documentDirectoryURL.appendingPathComponent("file3.txt"), atomically: true, encoding: .utf8)
            try "test contents 4".write(to: documentDirectoryURL.appendingPathComponent("file4.txt"), atomically: true, encoding: .utf8)
            
            let fileNameTransform : FileNameTransform = { a, b in a.substring(to: a.index(a.endIndex, offsetBy: -4)) + "_b.txt" }
            
            try Zip.zipFiles(paths: [documentDirectoryURL], zipFilePath: archiveURL, fileNameTransform: fileNameTransform, password: nil, progress: nil )
            try Zip.unzipFile(archiveURL, destination: archiveOuputURL, overwrite: true, password: nil, progress: nil)
            
            XCTAssertTrue(FileManager.default.fileExists(atPath:archiveOuputURL.appendingPathComponent("files").appendingPathComponent("file1_b.txt").path))
            XCTAssertTrue(FileManager.default.fileExists(atPath:archiveOuputURL.appendingPathComponent("files").appendingPathComponent("file2_b.txt").path))
            XCTAssertTrue(FileManager.default.fileExists(atPath:archiveOuputURL.appendingPathComponent("files").appendingPathComponent("file3_b.txt").path))
            XCTAssertTrue(FileManager.default.fileExists(atPath:archiveOuputURL.appendingPathComponent("files").appendingPathComponent("file4_b.txt").path))
            
            try FileManager.default.removeItem(at: temporaryDirectoryURL)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    
    func testRenameFilesIndividual() {
        
        
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("testRenameFiles", isDirectory: true)
        
        let documentDirectoryURL = temporaryDirectoryURL.appendingPathComponent("files", isDirectory: true)
        
        let archiveURL = temporaryDirectoryURL.appendingPathComponent("archive.zip")
        let archiveOuputURL = temporaryDirectoryURL.appendingPathComponent("archive", isDirectory: true)
        
        do {
            
            try FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(at: documentDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            
            var files : [URL] = []
            
            let n = 5
            
            for i in 0..<n{
                let url = documentDirectoryURL.appendingPathComponent("file\(i).txt")
                files.append(url)
                try "test contents \(i)".write(to: url, atomically: true, encoding: .utf8)
            }
            
            let fileNameTransform : FileNameTransform = { a, b in a.substring(to: a.index(a.endIndex, offsetBy: -4)) + "_b.txt" }
            
            try Zip.zipFiles(paths: files, zipFilePath: archiveURL, fileNameTransform: fileNameTransform, password: nil, progress: nil )
            try Zip.unzipFile(archiveURL, destination: archiveOuputURL, overwrite: true, password: nil, progress: nil)
            
            
            for i in 0..<n{
                XCTAssertTrue(FileManager.default.fileExists(atPath:archiveOuputURL.appendingPathComponent("file\(i)_b.txt").path))
            }
            
            try FileManager.default.removeItem(at: temporaryDirectoryURL)
        } catch let e {
            XCTFail("\(e)")
        }
    }

    
    func testFileNameTransformValues() {
        
        
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("testRenameFiles", isDirectory: true)
        let documentDirectoryURL = temporaryDirectoryURL.appendingPathComponent("files", isDirectory: true)
        let archiveURL = temporaryDirectoryURL.appendingPathComponent("archive.zip")
        
        do {
            
            try FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(at: documentDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            
            try "test contents 1".write(to: documentDirectoryURL.appendingPathComponent("fileA.txt"), atomically: true, encoding: .utf8)
            try "test contents 2".write(to: temporaryDirectoryURL.appendingPathComponent("fileB.txt"), atomically: true, encoding: .utf8)
            
            let fileNameTransform : FileNameTransform = { (fileName, directory) in
                if fileName == "files/fileA.txt" {
                    XCTAssertEqual(directory, documentDirectoryURL.path )
                } else if fileName == "fileB.txt" {
                    XCTAssertEqual(directory, temporaryDirectoryURL.path )
                } else {
                    XCTFail("should not make it here with fileName = \(fileName) and directory = \(directory)")
                }
                return fileName
            }
            
            try Zip.zipFiles(paths: [temporaryDirectoryURL.appendingPathComponent("fileB.txt"), documentDirectoryURL], zipFilePath: archiveURL, fileNameTransform: fileNameTransform, password: nil, progress: nil )
            
            
            try FileManager.default.removeItem(at: temporaryDirectoryURL)
        } catch let e {
            XCTFail("\(e)")
        }
    }

    
    func testZipUnzipPassword() {
        do {
            let imageURL1 = Bundle(for: ZipTests.self).url(forResource: "3crBXeO", withExtension: "gif")!
            let imageURL2 = Bundle(for: ZipTests.self).url(forResource: "kYkLkPf", withExtension: "gif")!
            let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
            let zipFilePath = documentsFolder.appendingPathComponent("archive.zip")
            try Zip.zipFiles(paths: [imageURL1, imageURL2], zipFilePath: zipFilePath!, password: "password", progress: { (progress) -> () in
                print(progress)
            })
            let fileManager = FileManager.default
            XCTAssertTrue(fileManager.fileExists(atPath:(zipFilePath?.path)!))
            guard let fileExtension = zipFilePath?.pathExtension, let fileName = zipFilePath?.lastPathComponent else {
                throw ZipError.unzipFail
            }
            let directoryName = fileName.replacingOccurrences(of: ".\(fileExtension)", with: "")
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
            let destinationUrl = documentsUrl.appendingPathComponent(directoryName, isDirectory: true)
            try Zip.unzipFile(zipFilePath!, destination: destinationUrl!, overwrite: true, password: "password", progress: nil)
            XCTAssertTrue(fileManager.fileExists(atPath:(destinationUrl?.path)!))
        }
        catch {
            XCTFail()
        }
    }

    
    func testQuickUnzipSubDir() {
        do {
            let bookURL = Bundle(for: ZipTests.self).url(forResource: "bb8", withExtension: "zip")!
            let unzipDestination = try Zip.quickUnzipFile(bookURL)
            let fileManager = FileManager.default
            let subDir = unzipDestination.appendingPathComponent("subDir")
            let imageURL = subDir.appendingPathComponent("r2W9yu9").appendingPathExtension("gif")
            
            XCTAssertTrue(fileManager.fileExists(atPath:unzipDestination.path))
            XCTAssertTrue(fileManager.fileExists(atPath:subDir.path))
            XCTAssertTrue(fileManager.fileExists(atPath:imageURL.path))
        } catch {
            XCTFail()
        }
    }

    func testFileExtensionIsNotInvalidForValidUrl() {
        let fileUrl = NSURL(string: "file.cbz")
        let result = Zip.fileExtensionIsInvalid(fileUrl?.pathExtension)
        XCTAssertFalse(result)
    }
    
    func testFileExtensionIsInvalidForInvalidUrl() {
        let fileUrl = NSURL(string: "file.xyz")
        let result = Zip.fileExtensionIsInvalid(fileUrl?.pathExtension)
        XCTAssertTrue(result)
    }
    
    func testAddedCustomFileExtensionIsValid() {
        let fileExtension = "cstm"
        Zip.addCustomFileExtension(fileExtension)
        let result = Zip.isValidFileExtension(fileExtension)
        XCTAssertTrue(result)
        Zip.removeCustomFileExtension(fileExtension)
    }
    
    func testRemovedCustomFileExtensionIsInvalid() {
        let fileExtension = "cstm"
        Zip.addCustomFileExtension(fileExtension)
        Zip.removeCustomFileExtension(fileExtension)
        let result = Zip.isValidFileExtension(fileExtension)
        XCTAssertFalse(result)
    }
    
    func testDefaultFileExtensionsIsValid() {
        XCTAssertTrue(Zip.isValidFileExtension("zip"))
        XCTAssertTrue(Zip.isValidFileExtension("cbz"))
    }
    
    func testDefaultFileExtensionsIsNotRemoved() {
        Zip.removeCustomFileExtension("zip")
        Zip.removeCustomFileExtension("cbz")
        XCTAssertTrue(Zip.isValidFileExtension("zip"))
        XCTAssertTrue(Zip.isValidFileExtension("cbz"))
    }
    
}
