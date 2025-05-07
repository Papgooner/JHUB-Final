//
//  Item.swift
//  JHUB final
//
//  Created by Thomas Perkes on 04/04/2025.
//

import Foundation
import SwiftData

@Model
final class Receipt {
    var title: String
    var cost: Decimal
    var timestamp: Date
    
    @Relationship(deleteRule: .cascade, inverse: \ReceiptImage.receipt) var images: [ReceiptImage] = []
    
    init(title: String, cost: Decimal, timestamp: Date) {
        self.title = title;
        self.cost = cost;
        self.timestamp = timestamp;
    }
}

