//
//  DataResourceDescriptor.swift
//  ResourceDescriptor
//
//  Created by Igor Kulik on 16.10.2020.
//

import Foundation
import UIKit

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
    var DataResourceFileType: DataResourceFileType { get }

    /// Resource storage type
    var DataResourceStorageType: DataResourceStorageType { get }

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
    /// Common impleentation for resource extraction,
    /// based on its `name`, `DataResourceFileType` and `DataResourceStorageType`.
    ///
    /// - Returns: Extracted resource data.
    /// - Throws: In case if any extraction errors appear.
    private func extract() throws -> Data {
        switch DataResourceStorageType {
        case .asset:
            guard let asset = NSDataAsset(name: name) else {
                throw DataResourceParsingError.assetNotFound(assetName: name)
            }
            return asset.data
        case .bundle(let bundle):
            guard let path = bundle.path(forResource: name, ofType: DataResourceFileType.rawValue) else {
                throw DataResourceParsingError.fileNotFound(fileName: name)
            }
            return try Data(contentsOf: URL(fileURLWithPath: path))
        }
    }

    func parse() throws -> DataType {
        let data = try extract()
        return try parsingClosure(data)
    }
}

