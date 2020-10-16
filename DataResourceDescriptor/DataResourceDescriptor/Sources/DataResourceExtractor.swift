//
//  DataResourceExtractor.swift
//  DataResourceDescriptor
//
//  Created by Igor Kulik on 16.10.2020.
//

import Foundation
import UIKit

// MARK: - DataResourceExtractor

protocol DataResourceExtractor {
    /// Extracts a data for the resource with specified name and file type.
    /// - Parameters:
    ///   - fileName: File name.
    ///   - fileType: File type.
    ///
    /// - Returns: Extracted resource data.
    /// - Throws: In case if any extraction error appears.
    func extract(fileName: String, fileType: DataResourceFileType) throws -> Data
}

struct AssetResourceExtractor: DataResourceExtractor {
    
    // MARK: - DataResourceExtractor
    
    func extract(fileName: String, fileType: DataResourceFileType) throws -> Data {
        if let asset = NSDataAsset(name: fileName) {
            return asset.data
        } else {
            throw DataResourceParsingError.assetNotFound(assetName: fileName)
        }
    }
}

struct BundleResourceExtractor: DataResourceExtractor {
    
    // MARK: - Properties
    
    let bundle: Bundle
    
    // MARK: - DataResourceExtractor
    
    func extract(fileName: String, fileType: DataResourceFileType) throws -> Data {
        guard let path = bundle.path(forResource: fileName, ofType: fileType.rawValue) else {
            throw DataResourceParsingError.fileNotFound(fileName: fileName)
        }
        return try Data(contentsOf: URL(fileURLWithPath: path))
    }
}
