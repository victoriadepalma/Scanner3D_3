//
//  URL+Extension.swift
//  XCAInventoryTrackerVision
//
//  Created by Victoria De Palma and Diana Silva
//

import Foundation

extension URL {
    
    var usdzFileCacheURL: URL? {
        guard
            let urlComps = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let cacheDirURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let token = urlComps.queryItems?.first(where: { $0.name == "token" })?.value ?? UUID().uuidString
        let fileCacheURL = cacheDirURL.appending(
            path: "\(token)_\(lastPathComponent)")
        return fileCacheURL
    }
    
}
