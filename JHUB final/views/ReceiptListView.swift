//
//  ReceiptListView.swift
//  JHUB final
//
//  Created by Thomas Perkes on 04/04/2025.
//

import SwiftUI
import SwiftData
import StoreKit
struct ReceiptListView: View {
    @AppStorage("themeColour") private var themeColor = "0.98,0.9,0.2"
    @Environment(\.modelContext) private var modelContext
    @Query private var receipts: [Receipt]
    @State private var showAlert = false
    @State private var showNewReceiptListViewSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(receipts) { receipt in
                    NavigationLink {
                        ScrollView {
                            Text("\(receipt.title) Cost: £\(receipt.cost)")
                            ForEach(receipt.images, id: \.self) { image in
                                if let imageData = image.image {
                                    if let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage).resizable().scaledToFit().frame(maxWidth: .infinity).padding()
                                    }
                                }
                                showMetaData(metaData: image.metaData).font(.caption).padding(.horizontal)
                            }
                        }
                    }label: {
                        Text(receipt.title)
                        Text(receipt.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                        
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: "trash") {
                        showAlert = true
                    }.alert("Delete all items?", isPresented: $showAlert) {
                        Button("Delete all", role: .destructive) {
                            deleteAllItems()
                            showAlert = false
                        }
                        Button ("Cancel", role: .cancel) { showAlert = false}
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button("", systemImage: "plus") {
                        showNewReceiptListViewSheet.toggle()
                    }
                }
            }.sheet(isPresented: $showNewReceiptListViewSheet) {
                NewReceiptView()
            }.navigationTitle("Total: £\(receipts.reduce(0) { $0 + $1.cost })")
        }
    }
    func getImagesFromData(imageDataArray: [Data]) -> [Image] {
        var images = [Image]()
        
        for data in imageDataArray {
            if let uiImage = UIImage(data: data) {
                let swiftUIImage = Image(uiImage: uiImage)
                images.append(swiftUIImage)
            } else {
                print("Failed to create UIImage from Data.")
            }
        }
        
        return images
    }
    private func deleteAllItems() {
        for receipt in receipts {
            modelContext.delete(receipt)
        }
    }
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(receipts[index])
            }
        }
    }
    
//    private func showMetaData(metaData: Data?) -> Text {
//        if let data = metaData,
//           let metadata = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//            return Text("\(metadata)")
//        } else {
//            return Text("No metadata")
//        }
//    }
    
    private func showMetaData(metaData: Data?) -> Text {
        if let data = metaData,
           let metadata = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let exif = metadata["{Exif}"] as? [String: Any],
           let rawDate = exif["DateTimeOriginal"] as? String {
            
            // Format the raw date string
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            
            if let date = formatter.date(from: rawDate) {
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                let formatted = formatter.string(from: date)
                return Text("Captured on: \(formatted)")
            } else {
                return Text("Captured on: \(rawDate)")
            }
        } else {
            return Text("No metadata")
        }
    }
    
}

#Preview {
    ReceiptListView()
}
