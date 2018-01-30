//
//  SourceEditorCommand.swift
//  ClangFormat
//
//  Created by Boris Bügling on 21/06/16.
//  Copyright © 2016 🚀. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {

    // max bytes of config file.  default: 100 KB.
    static let plkConfigMaxSizeBytes = 100 * 1000
    // max bytes of source file.  default: 500 KB.
    static let plkSourceFileSizeBytes = 500 * 1000

    // Support source-code.
    let plSupportSourceTypes = ["public.objective-c-source",
        "public.c-header",
        "public.c-source",
        "public.objective-c-plus-plus-source",
        "public.c-plus-plus-source"]

    enum codeSourceError: Error {
        case notSupport
        case configFileInvalid
        case codeSourceMaxSizeLimit
    }

    let plConfig = FormatConfig()

    var commandPath: String {
        return Bundle.main.path(forResource: "clang-format", ofType: nil)!
    }

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {

        if (plSupportSourceTypes.contains(invocation.buffer.contentUTI))
            {
            SourceEditorCommand.runCommand(commandPath: commandPath,
                                           arguments: ["-style=file", "-assume-filename=\(plConfig.language)"],
                                           stdin: invocation.buffer.completeBuffer) { (content, err) in

                if err == nil, content!.count > 0 {

                    invocation.buffer.completeBuffer = content!
                }

                DispatchQueue.main.async {

                    completionHandler(err)
                }
            }

        }
        else
        {
            completionHandler(codeSourceError.notSupport)
        }

    }

    static func runCommand(commandPath: String,
                           arguments: [String],
                           stdin: String,
                           completion: @escaping (String?, Error?) -> Void) -> Void {
        
        let task = Process()
//        let errorPipe = Pipe()
//        task.standardError = errorPipe

        task.launchPath = commandPath
        task.arguments = arguments

        if !SourceEditorCommand.updateConfigIfNeeded(currentDirectory: task.currentDirectoryPath) {

            completion(nil, codeSourceError.configFileInvalid)
            return
        }

        let inputPipe = Pipe()
        task.standardInput = inputPipe
        let inHandle = inputPipe.fileHandleForWriting

        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        let outHandle = outputPipe.fileHandleForReading

        inHandle.writeabilityHandler = { file -> Void in

            if let data = stdin.data(using: .utf8) {
                
                if data.count > plkSourceFileSizeBytes {
                    
                    completion(nil, codeSourceError.codeSourceMaxSizeLimit)
                    inHandle.writeabilityHandler = nil
                    return
                }
                
                file.write(data)
                file.closeFile()
            }

            inHandle.writeabilityHandler = nil
        }

        outHandle.readabilityHandler = { file -> Void in

            let outputData = outHandle.readDataToEndOfFile()
            let str = String(data: outputData, encoding: .utf8)
            completion(str, nil)

            outHandle.readabilityHandler = nil
        }

        task.launch()
    }

    // MARK: -
    static func updateConfigIfNeeded (currentDirectory: String) -> Bool {

        let formatConfig = FormatConfig()
        let fileManager = FileManager()

        let plOriginFormatFile = Bundle.main.path(forResource: formatConfig.filename, ofType: nil)!
        // check clang-format config file.
        let usedFormatConfigFile = "\(currentDirectory)/\(formatConfig.filenameDefault)"
        let copyFormatConfigFile = "\(currentDirectory)/\(formatConfig.filename)"

        if fileManager.fileExists(atPath: plOriginFormatFile),
            let originConfigData = fileManager.contents(atPath: plOriginFormatFile),
            originConfigData.count > plkConfigMaxSizeBytes {
            // current config max size `plkConfigMaxSizeBytes`
            return false
        }

        let plOriginConfigFileMd5 = fileManager.contents(atPath: plOriginFormatFile)?.md5()
        let plUsedConfigFileMd5 = fileManager.contents(atPath: usedFormatConfigFile)?.md5()

        if fileManager.fileExists(atPath: copyFormatConfigFile) {

            try? File(path: copyFormatConfigFile).delete()
        }

        let plOriginFile = try! File(path: plOriginFormatFile)
        // print("origin file md5 = \(plOriginConfigFileMd5)\nused file md5 = \(plUsedConfigFileMd5)")

        if plUsedConfigFileMd5 == nil {

            let plDoc = try! Folder(path: currentDirectory)
            if let configFile = try? plOriginFile.copy(to: plDoc) {
                print("#1 copy file success.")

                try? configFile.rename(to: formatConfig.filenameDefault)
            }
            else {
                print("#1 err : copy file failed!")
            }
        }
        else if plUsedConfigFileMd5 != plOriginConfigFileMd5 {

            let plDoc = try! Folder(path: currentDirectory)
            if let configFile = try? plOriginFile.copy(to: plDoc) {
                print("#2 copy file success.")

                try? File(path: usedFormatConfigFile).delete()
                try? configFile.rename(to: formatConfig.filenameDefault)
            }
            else {
                print("#2 err : copy file failed!")
            }
        }

        return true
    }

}

