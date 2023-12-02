//
//  Item.swift
//  DayTracer
//
//  Created by murate on 2023/12/02.
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
