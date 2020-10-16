//
//  DataResourceDescriptorTypes.swift
//  DataResourceDescriptor
//
//  Created by Igor Kulik on 16.10.2020.
//

import Foundation

// MARK: - Related types

public enum DataResourceParsingError: Error {
    case assetNotFound(assetName: String)
    case fileNotFound(fileName: String)
    case dataInconsistency
    case unexpectedType
}

public enum DataResourceFileType: String {
    case plist
    case json
}

public enum DataResourceStorageType {
    case asset
    case bundle(_ bundle: Bundle)
}

