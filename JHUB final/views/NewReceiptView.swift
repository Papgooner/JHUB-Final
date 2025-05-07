//
//  NewReceiptView.swift
//  JHUB final
//
//  Created by Thomas Perkes on 07/04/2025.
//

import SwiftUI
import PhotosUI

struct NewReceiptView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var title: String = ""
    @State private var cost: Decimal = 0
    @State private var timestamp: Date = Date.now
    @State private var photosPickerItems = [PhotosPickerItem]()
    @State private var selectedImagesData = [Data]()
    @State private var imageMetadata: [[String: Any]?] = []
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                LabeledContent {
                    TextField("Cost", value: $cost, format: .number, prompt: Text("Cost")).keyboardType(.decimalPad) } label: {
                    Text("£").foregroundStyle(.secondary)
                }
                DatePicker("Date", selection: $timestamp, displayedComponents: [.date])
                PhotosPicker("Select an image", selection: $photosPickerItems, matching: .images)

                    ForEach(selectedImagesData, id: \.self) { data in
                        if let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                            }
                    
                }
            }.onChange(of: photosPickerItems) {
                Task {
                    selectedImagesData.removeAll()
                    
                    for item in photosPickerItems {
                        if let loadedImageData = try? await item.loadTransferable(type: Data.self) {
                            selectedImagesData.append(loadedImageData)
                            if let tempURL = saveToTemporaryURL(data: loadedImageData) {
                                imageMetadata.append(extractMetadata(from: tempURL))
                            }
                        }
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        addItem()
                        dismiss()
                    }
                }
            }
        }
    }

    private func addItem() {
        var receiptImages: [ReceiptImage] = []
        let receipt = Receipt(title: title, cost: cost, timestamp: timestamp)
        for (index, imageData) in selectedImagesData.enumerated() {
            var finalisedMetaData: Data? = nil
            if JSONSerialization.isValidJSONObject(imageMetadata[index]) {
                if let metaData = try? JSONSerialization.data(withJSONObject: imageMetadata[index], options: []) {
                    finalisedMetaData = metaData
                }
            } else {
                print("Invalid JSON object at index \(index): \(imageMetadata[index])")
            }

            
            let receiptImage = ReceiptImage(image: imageData, receipt: receipt, metaData: finalisedMetaData)
            receiptImages.append(receiptImage)
        }
        receipt.images = receiptImages

        withAnimation {
            modelContext.insert(receipt)
        }
    }
    
    func saveToTemporaryURL(data: Data) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Error saving image data to file: \(error)")
            return nil
        }
    }
    
    func extractMetadata(from imageURL: URL) -> [String: Any]? {
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil) else {
            print("Unable to create image source")
            return nil
        }
        
        guard let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            print("Unable to get metadata")
            return nil
        }
        
        return metadata
    }
}

#Preview {
    NewReceiptView()
}
