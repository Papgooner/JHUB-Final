//
//  ReceiptImage.swift
//  JHUB final
//
//  Created by Thomas Perkes on 09/04/2025.
//

import Foundation
import SwiftData

@Model
final class ReceiptImage {
    var id = UUID()
    @Attribute(.externalStorage) var image: Data?
    var receipt: Receipt?
    var metaData: Data?
    
    init(id: UUID = UUID(), image: Data, receipt: Receipt? = nil, metaData: Data? = nil) {
        self.id = id;
        self.image = image;
        self.receipt = receipt;
        self.metaData = metaData;
    }
}
