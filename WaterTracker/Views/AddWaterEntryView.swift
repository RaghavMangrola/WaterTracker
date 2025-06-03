import SwiftUI
import SwiftData

struct AddWaterEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var amount: Int = 8
    
    var body: some View {
        NavigationStack {
            Form {
                Stepper("Amount: \(amount) oz", 
                       value: $amount, 
                       in: 1...40, 
                       step: 1)
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
        
        // Save the context
        do {
            try modelContext.save()
            print("Successfully saved water entry: \(amount) oz")
            
            // Immediately update notifications to reflect updated water intake
            let settingsViewModel = SettingsViewModel(modelContext: modelContext)
            settingsViewModel.updateNotificationContentImmediately()
        } catch {
            print("Failed to save water entry: \(error)")
        }
    }
} 