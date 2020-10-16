//
//  DecodableResourceDescriptor.swift
//  ResourceDescriptor
//
//  Created by Igor Kulik on 16.10.2020.
//

import Foundation

/// Contains info about resource file storing data of Decodable object of specific type.
/// Resource info consists of name of resource, file type, storage type.
/// Also stores a `parsingClosure` which describes how the `Data` should be parsed into expected `DataType`.
struct DecodableResourceDescriptor<T: Decodable>: DataResourceDescriptor {
    var parsingClosure: ((Data) throws -> T)

    // MARK: - Properties

    var name: String
    var dataResourceFileType: DataResourceFileType
    var dataResourceStorageType: DataResourceStorageType
    typealias DataType = T

    // MARK: - Lifecycle

    /// Creates an instance with resource descriptor with specifiedProperties.
    /// - note: In case if `parsingClosure` paramater is not passed, default decoding approach
    /// for  `DataResourceFileType` will be used.
    ///
    /// - Parameters:
    ///   - name: Resource name.
    ///   - DataResourceFileType: Resource file type.
    ///   - DataResourceStorageType: Resource storage type.
    ///   - parsingClosure: Optional closure used for parsing the resource data to expected `DataType`. If `nil`, default decoding approach is used.
    init(name: String, DataResourceFileType: DataResourceFileType, DataResourceStorageType: DataResourceStorageType, parsingClosure: ((_ data: Data) throws -> T)? = nil) {
        self.name = name
        self.dataResourceFileType = DataResourceFileType
        self.dataResourceStorageType = DataResourceStorageType

        if let parsingClosure = parsingClosure {
            self.parsingClosure = parsingClosure
        } else {
            switch DataResourceFileType {
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

