//
//  String+Extension.swift
//  XCAInventoryTracker
//
//  Created by Victoria De Palma and Diana Silva
//

import Foundation

extension String: Error, LocalizedError {
    
    public var errorDescription: String? { self }
}
