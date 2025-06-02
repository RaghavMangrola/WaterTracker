import SwiftUI
import SwiftData

struct WaterEntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let entry: WaterEntry
    @State private var amount: Int
    
    init(entry: WaterEntry) {
        self.entry = entry
        _amount = State(initialValue: entry.amount)
    }
    
    var body: some View {
        Form {
            Section("Details") {
                Stepper("Amount: \(amount) oz", 
                       value: $amount, 
                       in: 1...40, 
                       step: 1)
                DatePicker("Time", selection: .constant(entry.timestamp))
                    .disabled(true)
            }
        }
        .navigationTitle("Water Entry Details")
        .toolbar {
            Button("Save") {
                entry.amount = amount
                
                // Save the context
                do {
                    try modelContext.save()
                    print("Successfully updated water entry: \(amount) oz")
                } catch {
                    print("Failed to save water entry changes: \(error)")
                }
                
                dismiss()
            }
        }
    }
} 