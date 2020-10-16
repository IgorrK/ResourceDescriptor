//
//  JSONResourceDescriptor.swift
//  ResourceDescriptor
//
//  Created by Igor Kulik on 16.10.2020.
//

import Foundation

/// Contains info about resource file storing data of serializable object of specific type, i.e. JSON dictionary, JSON array, etc.
/// Resource info consists of name of resource, file type, storage type.
/// Also stores a `parsingClosure` which describes how the `Data` should be parsed into expected `DataType`.
struct JSONResourceDescriptor<T>: DataResourceDescriptor {
    typealias DataType = T

    // MARK: - Properties

    var name: String
    var DataResourceFileType: DataResourceFileType
    var DataResourceStorageType: DataResourceStorageType
    var parsingClosure: ((Data) throws -> T)

     // MARK: - Lifecycle

    /// Creates an instance with resource descriptor with specifiedProperties.
    /// - note: In case if `parsingClosure` paramater is not passed, default serialization approach
    /// for `DataResourceFileType` will be used.
    ///
    /// - Parameters:
    ///   - name: Resource name.
    ///   - DataResourceFileType: Resource file type.
    ///   - DataResourceStorageType: Resource storage type.
    ///   - parsingClosure: Optional closure used for parsing the resource data to expected `DataType`. If `nil`, default serialization approach is used.
    init(name: String, DataResourceFileType: DataResourceFileType, DataResourceStorageType: DataResourceStorageType, parsingClosure: ((Data) throws -> T)? = nil) {
        self.name = name
        self.DataResourceFileType = DataResourceFileType
        self.DataResourceStorageType = DataResourceStorageType

        if let parsingClosure = parsingClosure {
            self.parsingClosure = parsingClosure
        } else {
            switch DataResourceFileType {
            case .plist:
                self.parsingClosure = { data throws -> T in
                    let serializedObject = try PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.ReadOptions(), format: nil)
                    if let object = serializedObject as? T {
                        return object
                    } else {
                        throw DataResourceParsingError.unexpectedType
                    }
                }
            case .json:
                self.parsingClosure = { data throws -> T in
                    let serializedObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                    if let object = serializedObject as? T {
                        return object
                    } else {
                        throw DataResourceParsingError.unexpectedType
                    }
                }
            }
        }
    }
}
