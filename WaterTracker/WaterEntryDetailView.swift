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
                Stepper("Amount: \(amount)ml", value: $amount, in: 50...1000, step: 50)
                DatePicker("Time", selection: .constant(entry.timestamp))
                    .disabled(true)
            }
        }
        .navigationTitle("Water Entry Details")
        .toolbar {
            Button("Save") {
                entry.amount = amount
                dismiss()
            }
        }
    }
} 