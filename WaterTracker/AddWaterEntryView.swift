import SwiftUI
import SwiftData

struct AddWaterEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var amount = 250
    
    var body: some View {
        NavigationStack {
            Form {
                Stepper("Amount: \(amount)ml", value: $amount, in: 50...1000, step: 50)
            }
            .navigationTitle("Add Water")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addEntry()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addEntry() {
        let entry = WaterEntry(amount: amount)
        modelContext.insert(entry)
    }
} 