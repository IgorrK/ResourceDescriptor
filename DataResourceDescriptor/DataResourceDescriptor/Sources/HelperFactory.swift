//
//  HelperFactory.swift
//  DataResourceDescriptor
//
//  Created by Igor Kulik on 16.10.2020.
//

import Foundation

final class HelperFactory {
    static func extractor(for storageType: DataResourceStorageType) -> DataResourceExtractor {
        switch storageType {
        case .asset: return AssetResourceExtractor()
        case .bundle(let bundle): return BundleResourceExtractor(bundle: bundle)
        }
    }
}
