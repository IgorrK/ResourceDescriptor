//
//  DataResourceDescriptor.swift
//  ResourceDescriptor
//
//  Created by Igor Kulik on 16.10.2020.
//

import Foundation
import UIKit

enum ResourceParsingError: Error {
    case assetNotFound(assetName: String)
    case fileNotFound(fileName: String)
    case dataInconsistency
    case unexpectedType
}

enum FileType: String {
    case plist
    case json
}

enum StorageType {
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
    var fileType: FileType { get }

    /// Resource storage type
    var storageType: StorageType { get }

    /// Closure used for parsing the resource data to expected `DataType`
    var parsingClosure: ((_ data: Data) throws -> DataType) { get }

    // MARK: - Lifecycle

    init(name: String, fileType: FileType, storageType: StorageType, parsingClosure: ((_ data: Data) throws -> DataType)?)

    // MARK: - Public methods

    /// Extracts and parses recource data to expected `DataType`
    ///
    /// - Returns: Parsed resource.
    /// - Throws: In case if any extraction or parsing errors appear.
    func parse() throws -> DataType
}

extension DataResourceDescriptor {
    /// Common impleentation for resource extraction,
    /// based on its `name`, `filetype` and `storageType`.
    ///
    /// - Returns: Extracted resource data.
    /// - Throws: In case if any extraction errors appear.
    private func extract() throws -> Data {
        switch storageType {
        case .asset:
            guard let asset = NSDataAsset(name: name) else {
                throw ResourceParsingError.assetNotFound(assetName: name)
            }
            return asset.data
        case .bundle(let bundle):
            guard let path = bundle.path(forResource: name, ofType: fileType.rawValue) else {
                throw ResourceParsingError.fileNotFound(fileName: name)
            }
            return try Data(contentsOf: URL(fileURLWithPath: path))
        }
    }

    func parse() throws -> DataType {
        let data = try extract()
        return try parsingClosure(data)
    }
}

/// Contains info about resource file storing data of Decodable object of specific type.
/// Resource info consists of name of resource, file type, storage type.
/// Also stores a `parsingClosure` which describes how the `Data` should be parsed into expected `DataType`.
struct DecodableResourceDescriptor<T: Decodable>: DataResourceDescriptor {
    var parsingClosure: ((Data) throws -> T)

    // MARK: - Properties

    var name: String
    var fileType: FileType
    var storageType: StorageType
    typealias DataType = T

    // MARK: - Lifecycle

    /// Creates an instance with resource descriptor with specifiedProperties.
    /// - note: In case if `parsingClosure` paramater is not passed, default decoding approach
    /// for the used `fileType` will be used.
    ///
    /// - Parameters:
    ///   - name: Resource name.
    ///   - fileType: Resource file type.
    ///   - storageType: Resource storage type.
    ///   - parsingClosure: Optional closure used for parsing the resource data to expected `DataType`. If `nil`, default decoding approach is used.
    init(name: String, fileType: FileType, storageType: StorageType, parsingClosure: ((_ data: Data) throws -> T)? = nil) {
        self.name = name
        self.fileType = fileType
        self.storageType = storageType

        if let parsingClosure = parsingClosure {
            self.parsingClosure = parsingClosure
        } else {
            switch fileType {
            case .plist:
                self.parsingClosure = { data throws -> T in
                    return try PropertyListDecoder().decode(T.self, from: data)
                }
            case .json:
                self.parsingClosure = { data throws -> T in
                    return try JSONDecoder().decode(T.self, from: data)
                }
            }
        }
    }
}

/// Contains info about resource file storing data of serializable object of specific type, i.e. JSON dictionary, JSON array, etc.
/// Resource info consists of name of resource, file type, storage type.
/// Also stores a `parsingClosure` which describes how the `Data` should be parsed into expected `DataType`.
struct SerializableResourceDescriptor<T>: DataResourceDescriptor {
    typealias DataType = T

    // MARK: - Properties

    var name: String
    var fileType: FileType
    var storageType: StorageType
    var parsingClosure: ((Data) throws -> T)

     // MARK: - Lifecycle

    /// Creates an instance with resource descriptor with specifiedProperties.
    /// - note: In case if `parsingClosure` paramater is not passed, default serialization approach
    /// for the used `fileType` will be used.
    ///
    /// - Parameters:
    ///   - name: Resource name.
    ///   - fileType: Resource file type.
    ///   - storageType: Resource storage type.
    ///   - parsingClosure: Optional closure used for parsing the resource data to expected `DataType`. If `nil`, default serialization approach is used.
    init(name: String, fileType: FileType, storageType: StorageType, parsingClosure: ((Data) throws -> T)? = nil) {
        self.name = name
        self.fileType = fileType
        self.storageType = storageType

        if let parsingClosure = parsingClosure {
            self.parsingClosure = parsingClosure
        } else {
            switch fileType {
            case .plist:
                self.parsingClosure = { data throws -> T in
                    let serializedObject = try PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.ReadOptions(), format: nil)
                    if let object = serializedObject as? T {
                        return object
                    } else {
                        throw ResourceParsingError.unexpectedType
                    }
                }
            case .json:
                self.parsingClosure = { data throws -> T in
                    let serializedObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                    if let object = serializedObject as? T {
                        return object
                    } else {
                        throw ResourceParsingError.unexpectedType
                    }
                }
            }
        }
    }
}

/// Contains info about resource file storing data of Decodable object of specific type.
/// Resource info consists of name of resource, file type, storage type.
/// Also stores a `parsingClosure` which describes how the `Data` should be parsed into expected `DataType`.
struct JSONResourceDescriptor<T>: DataResourceDescriptor {
    var parsingClosure: ((Data) throws -> T)

    // MARK: - Properties

    var name: String
    var fileType: FileType
    var storageType: StorageType
    typealias DataType = T

    // MARK: - Lifecycle

    /// Creates an instance with resource descriptor with specifiedProperties.
    /// - note: In case if `parsingClosure` paramater is not passed, default decoding approach
    /// for the used `fileType` will be used.
    ///
    /// - Parameters:
    ///   - name: Resource name.
    ///   - fileType: Resource file type.
    ///   - storageType: Resource storage type.
    ///   - parsingClosure: Optional closure used for parsing the resource data to expected `DataType`. If `nil`, default decoding approach is used.
    init(name: String, fileType: FileType, storageType: StorageType, parsingClosure: ((_ data: Data) throws -> T)? = nil) {
        self.name = name
        self.fileType = fileType
        self.storageType = storageType

        if let parsingClosure = parsingClosure {
            self.parsingClosure = parsingClosure
        } else {
            self.parsingClosure = { data throws -> T in
                if case let StorageType.bundle(bundle) = storageType {
                    guard let path = bundle.path(forResource: name, ofType: fileType.rawValue) else {
                        throw ResourceParsingError.fileNotFound(fileName: name)
                    }
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    if let object = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? T {
                        return object
                    } else {
                        throw ResourceParsingError.unexpectedType
                    }
                }
                throw ResourceParsingError.fileNotFound(fileName: name)
            }
        }
    }
}
