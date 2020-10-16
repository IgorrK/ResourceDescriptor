//
//  DataResourceDescriptor.swift
//  ResourceDescriptor
//
//  Created by Igor Kulik on 16.10.2020.
//

import Foundation
import UIKit

// MARK: - Related types

enum DataResourceParsingError: Error {
    case assetNotFound(assetName: String)
    case fileNotFound(fileName: String)
    case dataInconsistency
    case unexpectedType
}

enum DataResourceFileType: String {
    case plist
    case json
}

enum DataResourceStorageType {
    case asset
    case bundle(_ bundle: Bundle)
}

/// Contains info about data resource, required for it's extraction and parsing:
/// name of resource, file type, storage type.
/// Also stores a `parsingClosure` which describes how the `Data` should be parsed into expected `DataType`.
protocol DataResourceDescriptor {
    associatedtype DataType

    // MARK: - Properties

    /// Resource name
    var name: String { get }

    /// Resource file type
    var dataResourceFileType: DataResourceFileType { get }

    /// Resource storage type
    var dataResourceStorageType: DataResourceStorageType { get }

    /// Closure used for parsing the resource data to expected `DataType`
    var parsingClosure: ((_ data: Data) throws -> DataType) { get }

    // MARK: - Lifecycle

    init(name: String, DataResourceFileType: DataResourceFileType, DataResourceStorageType: DataResourceStorageType, parsingClosure: ((_ data: Data) throws -> DataType)?)

    // MARK: - Public methods

    /// Extracts and parses recource data to expected `DataType`
    ///
    /// - Returns: Parsed resource.
    /// - Throws: In case if any extraction or parsing errors appear.
    func parse() throws -> DataType
}

extension DataResourceDescriptor {
    func parse() throws -> DataType {
        let extractor = HelperFactory.extractor(for: dataResourceStorageType)
        let data = try extractor.extract(fileName: name, fileType: dataResourceFileType)
        return try parsingClosure(data)
    }
}

private final class HelperFactory {
    static func extractor(for storageType: DataResourceStorageType) -> DataResourceExtractor {
        switch storageType {
        case .asset: return AssetResourceExtractor()
        case .bundle(let bundle): return BundleResourceExtractor(bundle: bundle)
        }
    }
}

// MARK: - DataResourceExtractor

private protocol DataResourceExtractor {
    /// Extracts a data for the resource with specified name and file type.
    /// - Parameters:
    ///   - fileName: File name.
    ///   - fileType: File type.
    ///
    /// - Returns: Extracted resource data.
    /// - Throws: In case if any extraction error appears.
    func extract(fileName: String, fileType: DataResourceFileType) throws -> Data
}

private struct AssetResourceExtractor: DataResourceExtractor {
    
    // MARK: - DataResourceExtractor
    
    func extract(fileName: String, fileType: DataResourceFileType) throws -> Data {
        if let asset = NSDataAsset(name: fileName) {
            return asset.data
        } else {
            throw DataResourceParsingError.assetNotFound(assetName: fileName)
        }
    }
}

private struct BundleResourceExtractor: DataResourceExtractor {
    
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
