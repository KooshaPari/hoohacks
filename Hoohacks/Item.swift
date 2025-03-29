//
//  Item.swift
//  Hoohacks
//
//  Created by Koosha Paridehpour on 3/29/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
